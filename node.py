from __future__ import print_function
import getopt
import sys
import os.path
import time
import logging
import math
import uhal
from string import Template

import StringIO
EXIT_CODE_INCORRECT_ARGUMENTS = 1
EXIT_CODE_ARG_PARSING_ERROR   = 2
EXIT_CODE_NODE_ADDRESS_ERRORS = 3
EXIT_CODE_NODE_INCONTINUITY = 4

class node(object):
    def __init__(self, uhalNode, baseAddress, tree=None, parent=None, index=None):
        self.parent = parent
        self.tree = tree
        ##### reference to the tree class through parent
        if self.parent and not self.tree:
            self.tree = self.parent.tree
        self.children = []
        #####
        self.id = uhalNode.getId()
        self.mask = uhalNode.getMask()
        self.description = uhalNode.getDescription()
        self.permission = self.readpermission(uhalNode.getPermission())
        self.fwinfo = uhalNode.getFirmwareInfo()
        absolute_address = uhalNode.getAddress()
        self.address = absolute_address - baseAddress
        ##### add children
        for childName in uhalNode.getNodes():
            ### TODO: are we filtering out registers whose ID contains a '.'?
            if childName.count('.')>0: continue
            childNode = uhalNode.getNode(childName)
            self.addChild(node(childNode, absolute_address, parent=self))
        ##### validate array type
        for child in self.children:
            if not child.checkContinuity(): 
                self.tree.log.critical("Critical: Attempting to register multiple array type registers but the indices are not continuous!")
                sys.exit(EXIT_CODE_NODE_INCONTINUITY)
        ##### sort children by address and mask
        self.children = sorted(self.children, key=lambda child: child.address << 32 + child.mask)

    ### usually allow first layer nodes to have different address etc. but require all children to be exactly same
    def isIdentical(self,other,compareAll=False):
        ##### check attributes for the first level
        if not self.tree == other.tree: return False
        if not self.permission == other.permission: return False
        if not self.fwinfo == other.fwinfo: return False
        ##### stricter check for deeper levels
        if compareAll:
            if not self.id == other.id: return False
            if not self.address == other.address: return False
            if not self.mask == other.mask: return False
            if not self.description == other.description: return False
        ##### compare children, assuming they are sorted by address and id already!
        if not len(self.children) == len(other.children): return False
        for i_children in range(len(self.children)):
            if not self.children[i_children].isIdentical(other.children[i_children],compareAll=True): return False
        return True

    def addChild(self,child):
        array_index = child.extract_index()
        if array_index >= 0: #### treat it as an array type
            ##### check if it should be appended to an existing child
            for other_child in self.children:
                if other_child.isArray() and other_child.checkAppend(child):
                    return
            ##### otherwise create a new array 
            self.children.append(array_node(child))
            return
        self.children.append(child)
        return

    def isArray(self):
        return self.__class__ == array_node

    def getPath(self):
        if self.parent:
            return self.parent.getPath()+'.'+self.id
        else:
            return self.id

    ### re-implemented in array_node class
    def checkContinuity(self):
        return True
    
    ### returns the array index if id in the format "name_index" and has "type=array" in fw info, otherwise -1
    ### example: <node id="CM_1" fwinfo="type=array">
    def extract_index(self):
        if not 'type' in self.fwinfo.keys():
            return -1
        if not "array" in self.fwinfo['type']:
            return -1
        index_string = self.id[self.id.rfind('_')+1:]
        try:
            index=int(index_string)
        except ValueError:
            return -1
        return index

    ### get child by name, return None if no result found
    def getChild(self, childName):
        for child in self.children:
            if child.id == childName:
                return child
        return None
        
    @staticmethod
    def readpermission(permission):
        if permission == uhal.NodePermission.READ: 
            return 'r'
        elif permission == uhal.NodePermission.READWRITE: 
            return 'rw'
        elif permission == uhal.NodePermission.WRITE: 
            return 'w'
        else:
            return ""

    def getBitRange(self, mask=None):
        if not mask:
            mask = self.mask
        bits = bin(mask)[2:].zfill(32)[::-1]
        start = -1
        end = -1    
        for i in range(len(bits)-1,-1,-1):
            if start == -1:
                if bits[i] == '1':
                    start = i
            elif end == -1:
                if bits[i] == '0' :
                    end = i+1
                    break
        if end == -1:
            end = 0
        if start == end:
            return str(start).rjust(2)
        else:
            return str(start).rjust(2,' ') +" downto "+str(end).rjust(2,' ')

class array_node(node):
    ##### initialized with the first entry
    def __init__(self, first_entry):
        first_index = first_entry.extract_index()
        assert first_index >= 0
        self.id = first_entry.id[:first_entry.id.rfind('_')]
        self.description = "Array of " + self.id
        self.address = first_entry.address
        self.mask = 0xffffffff
        self.fwinfo = first_entry.fwinfo
        self.permission = first_entry.permission
        self.parent = first_entry.parent
        self.tree = first_entry.tree
        self.children = first_entry.children
        self.entries = {first_index : first_entry}
    
    def isCompatible(self, new_entry):
        new_index = new_entry.extract_index()
        ##### TODO: probably should throw an excetion if attempting to add noncompatible array with compatible id?
        if (new_index < 0) or (new_index in self.entries.keys()): return False
        if not self.id == new_entry.id[:new_entry.id.rfind('_')]: return False
        if not self.isIdentical(new_entry): return False 
        return True

    ### If new entry is compatible, add it to the array and return True, otherwise return False
    def checkAppend(self, new_entry):
        if self.isCompatible(new_entry):
            new_index = new_entry.extract_index()
            self.entries[new_index] = new_entry
            return True
        return False

    def checkContinuity(self):
        keys = list(self.entries.keys())
        return ( sorted(keys) == list(range(min(keys),max(keys)+1)) )


        

class tree(object):
    def __init__(self, root, logger=None):
        self.read_ops = dict(list())
        self.readwrite_ops = str()
        self.write_ops = dict(list())
        self.action_ops = str()
        ##### setup logger
        self.log = logger
        if not self.log:
            self.log = logging.getLogger("main")
            formatter = logging.Formatter('%(name)s %(levelname)s: %(message)s')
            handler = logging.StreamHandler(sys.stdout)
            handler.setFormatter(formatter)
            self.log.addHandler(handler)
            self.log.setLevel(logging.WARNING)
            uhal.setLogLevelTo(uhal.LogLevel.WARNING)
        ##### read the root node
        self.root = node(root,baseAddress=0,tree=self)

    def generateRecord(self, baseName, current_node, members, description):
        with open(self.outFileName,'a') as outFile:
            ##### Generate and print a VHDL record
            array_index_string = ""
            if current_node.isArray():
                array_index_string = "arrray(" + str(min(current_node.entries.keys())) + " to " + str(max(current_node.entries.keys()))+") of "
            outFile.write("  type " + baseName + " is " + array_index_string + "record\n")
            maxNameLength = 25
            maxTypeLength = 12
            sorted_members = sorted(members.items(), key=lambda item: (current_node.getChild(item[0]).address<<32) + current_node.getChild(item[0]).mask)
            for memberName,member in sorted_members:
                if len(memberName) > maxNameLength:
                    maxNameLength = len(memberName)
                if len(member) > maxTypeLength:
                    maxTypeLength = len(member)
                outFile.write("    " + memberName + "".ljust(maxNameLength-len(memberName),' ') + "  :")
                outFile.write((member+';').ljust(maxTypeLength+1,' '))
                if len(description[memberName]) > 0:
                    outFile.write("  -- " + description[memberName])
                outFile.write('\n')
            outFile.write("  end record " + baseName + ";\n\n")
            outFile.close()
        return

    ### Traverse through the tree and generate records in the PKG vhdl
    ### note the padding is not implemented yet
    def traverse(self, current_node=None, padding='\t'):
        if not current_node:
            current_node = self.root
        package_mon_entries = dict()
        package_ctrl_entries = dict()
        package_description = dict()
        package_addr_order = dict()
        for child in current_node.children:
            if len(child.children) != 0:
                child_records = self.traverse(child, padding+'\t')
                package_description[child.id] = ""
                if child_records.has_key('mon'):
                    package_mon_entries[child.id] = child.getPath().replace('.','_')+'_MON_t'
                if child_records.has_key('ctrl'):
                    package_ctrl_entries[child.id] = child.getPath().replace('.','_') + '_CTRL_t'
            else:
                bitCount = bin(child.mask)[2:].count('1')
                package_entries = ""
                if child.isArray():
                    package_entries = "array("+str(min(child.entries.keys())) + ' to ' + str(max(child.entries.keys())) + ') of '
                if bitCount == 1:
                    package_entries += "std_logic"
                else:
                    package_entries += "std_logic_vector(" + str(bitCount-1).rjust(2,' ') + " downto 0)"
                
                package_description[child.id] = child.description
                bits = child.getBitRange()
                if child.permission == 'r':
                    package_mon_entries[child.id] = package_entries
                    if self.read_ops.has_key(child.address):
                        self.read_ops[child.address] = self.read_ops[child.address] + str("localRdData("+bits+")")+" <= Mon."+child.id+"; --"+child.description+"\n"
                    else:
                        self.read_ops[child.address] =                           str("localRdData("+bits+")")+" <= Mon."+child.id+"; --"+child.description+"\n"
                elif child.permission == 'rw':
                    package_ctrl_entries[child.id] = package_entries
                    if self.read_ops.has_key(child.address):
                        self.read_ops[child.address] = self.read_ops[child.address] + str("localRdData("+bits+")")+" <= "+"reg_data("+str(child.address).rjust(2)+")("+bits+"); --"+child.description+"\n"
                    else:
                        self.read_ops[child.address] =                           str("localRdData("+bits+")")+" <= "+"reg_data("+str(child.address).rjust(2)+")("+bits+"); --"+child.description+"\n"
                    if self.write_ops.has_key(child.address):
                        self.write_ops[child.address] = self.write_ops[child.address] + str("reg_data("+str(child.address).rjust(2)+")("+bits+")") + " <= localWrData("+bits+"); --"+child.description+"\n"
                    else:
                        self.write_ops[child.address] =                            str("reg_data("+str(child.address).rjust(2)+")("+bits+")") + " <= localWrData("+bits+"); --"+child.description+"\n"

                    self.readwrite_ops+=("Ctrl."+child.id) + " <= reg_data("+str(child.address).rjust(2)+")("+bits+");\n"
                elif child.permission == 'w':
                    package_ctrl_entries[child.id] = package_entries
                    if self.write_ops.has_key(child.address):
                        self.write_ops[child.address] = self.write_ops[child.address] + ("Ctrl."+child.id) + " <= localWrData("+bits+");\n"
                    else:                                                     
                        self.write_ops[child.address] =                            ("Ctrl."+child.id) + " <= localWrData("+bits+");\n"
                    #determin if this is a vector or a single entry
                    if bits.find(" ") > 0:
                        self.action_ops+="Ctrl." + child.id + " <= (others => '0');\n"
                    else:
                        self.action_ops+="Ctrl." + child.id + " <= '0';\n"

        ret = {}
        if package_mon_entries:
            baseName = current_node.getPath().replace('.','_')+'_MON_t'
            ret['mon'] = self.generateRecord(baseName, current_node, package_mon_entries, package_description)
        if package_ctrl_entries:
            baseName = current_node.getPath().replace('.','_')+'_CTRL_t'
            ret['ctrl'] = self.generateRecord(baseName, current_node, package_ctrl_entries, package_description)
        return ret

    def generatePkg(self, outFileName=None):
        self.read_ops = dict(list())
        self.readwrite_ops = str()
        self.write_ops = dict(list())
        self.action_ops = str()
        outFileBase = self.root.id
        self.outFileName = outFileName
        if not self.outFileName:
            self.outFileName = outFileBase + "_PKG.vhd"
        with open(self.outFileName, 'w') as outFile:
            outFile.write("--This file was auto-generated.\n")
            outFile.write("--Modifications might be lost.\n")
            outFile.write("library IEEE;\n")
            outFile.write("use IEEE.std_logic_1164.all;\n")
            outFile.write("\n\npackage "+outFileBase+"_CTRL is\n")
            outFile.close()
        self.traverse()
        with open(self.outFileName, 'a') as outFile:
            outFile.write("\n\nend package "+outFileBase+"_CTRL;")
            outFile.close()
        return

    @staticmethod
    def sortByBit(line):
        assignmentPos = line.find("<=")
        if assignmentPos < 0:
            return assignmentPos
        numberStart = line[0:assignmentPos].rfind("(")+1
        numberEnd = line[numberStart:assignmentPos].find("downto");
        if numberEnd < 0:        
            numberEnd = line[numberStart:assignmentPos].find(")");
        if numberEnd < 0:
            return 0
        numberEnd+=numberStart
        return int(line[numberStart:numberEnd])

    @staticmethod
    def generateAlignedCase(operations):
        output = StringIO.StringIO()
        newAssignmentPos = 0
        newAssignmentLength = 0
        for addr in operations:
            #find the position of the "<=" in each line so we can align them
            #find the max length of assignment names so we can align to that as well
            for line in operations[addr].split('\n'):
                assignmentPos = line.find("<=")
                if assignmentPos > newAssignmentPos:
                    newAssignmentPos = assignmentPos;            
                assignmentLength = line[assignmentPos:].find(";")
                if assignmentLength > newAssignmentLength:
                    newAssignmentLength = assignmentLength;            
        for addr in operations:
            output.write("        when x\""+hex(addr)[2:]+"\" =>\n");                    
            for line in sorted(operations[addr].split('\n'),key = tree.sortByBit):                
                if line.find("<=") > 0:
                    preAssignment = line[0:line.find("<=")-1]
                    line=line[line.find("<=")+2:]
                    assignment = line[0:line.find(";")]
                    line=line[line.find(";")+1:]
                    output.write("          "+
                             preAssignment.ljust(newAssignmentPos)+
                             " <= "+
                             str(assignment+";").ljust(newAssignmentLength)+
                             "    "+
                             line+
                             "\n")
        return output.getvalue()

    def generate_r_ops_output(self):
        return self.generateAlignedCase(self.read_ops)

    def generate_w_ops_output(self):
        return self.generateAlignedCase(self.write_ops)

    def generate_rw_ops_output(self):
        output = StringIO.StringIO()
        output.write("  -- Register mapping to ctrl structures\n")
        newAssignmentPos = 0
        newAssignmentLength = 0
        for line in self.readwrite_ops.split("\n"):
            assignmentPos = line.find("<=")
            if assignmentPos > newAssignmentPos:
                newAssignmentPos = assignmentPos;            
            assignmentLength = line[assignmentPos:].find(";")
            if assignmentLength > newAssignmentLength:
                newAssignmentLength = assignmentLength
        for line in self.readwrite_ops.split("\n"):
            if line.find("<=") > 0:
                preAssignment = line[0:line.find("<=")-1]
                line=line[line.find("<=")+2:]
                assignment = line[0:line.find(";")]
                line=line[line.find(";")+1:]
                output.write("  "+
                              preAssignment.ljust(newAssignmentPos)+
                              " <= "+
                              str(assignment+";").ljust(newAssignmentLength)+
                              "    "+
                              line+
                              "\n")
        return output.getvalue()

    def generate_a_ops_output(self):
        output = StringIO.StringIO()
        for line in self.action_ops.split("\n"):
            output.write("      "+line+"\n")
        return output.getvalue()

    ### This should only be called after generatePkg is called
    def generateRegMap(self, outFileName=None, regMapTemplate="template_map.vhd"):
        if (not self.read_ops) or (not self.write_ops):
            self.log.critical("generateRegMap must be called after generatePkg!")
            return
        outFileBase = self.root.id
        if not outFileName:
            outFileName = outFileBase+"_map.vhd"
        ##### calculate regMapSize and regAddrRange
        regMapSize=0
        if max(self.read_ops,key=int) > regMapSize:
            regMapSize = max(self.read_ops,key=int)
        if max(self.write_ops,key=int) > regMapSize:
            regMapSize = max(self.write_ops,key=int)
        regAddrRange=str(int(math.floor(math.log(regMapSize,2))))
        ##### read the template from template file
        with open(regMapTemplate) as template_input_file:
            RegMapOutput = template_input_file.read()
            RegMapOutput = Template(RegMapOutput)
            template_input_file.close()
        ##### Substitute keywords in the template
        substitute_mapping = {
            "baseName"      : outFileBase,
            "regMapSize"    : regMapSize,
            "regAddrRange"  : regAddrRange,
            "r_ops_output"  : self.generate_r_ops_output(),
            "rw_ops_output" : self.generate_rw_ops_output(),
            "a_ops_output"  : self.generate_a_ops_output(),
            "w_ops_output"  : self.generate_w_ops_output(),
        }
        RegMapOutput = RegMapOutput.safe_substitute(substitute_mapping)
        ##### output to file
        with open(outFileName,'w') as outFile:
            outFile.write(RegMapOutput)
            outFile.close()
        return
