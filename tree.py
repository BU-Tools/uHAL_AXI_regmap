from node import *


class tree(object):
    def __init__(self, root, logger=None):
        self.read_ops = dict(list())
        self.readwrite_ops = str()
        self.write_ops = dict(list())
        self.action_ops = str()
        self.default_ops = str()
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
                array_index_string = "array(" + str(min(current_node.entries.keys())) + " to " + str(max(current_node.entries.keys()))+") of "
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
        ##### TODO: return value here?
        return 

    ##### TODO: array type for default records?
    def generateDefaultRecord(self, baseName, defaults):
        with open(self.outFileName,'a') as outfile:
            outfile.write("  constant DEFAULT_" + baseName + " : " + baseName +" := (\n")
            padding_size = 27 + (2 * len(baseName))
            firstLine=True
            for keys,values in defaults.items():
                if firstLine:
                    firstLine=False
                else:
                    outfile.write(",\n")
                outfile.write(" ".ljust(padding_size,' ')+keys+" => "+values)
            outfile.write("\n ".ljust(padding_size,' ')+");\n")
            outfile.close()
        return "DEFAULT_"+baseName

    ### Traverse through the tree and generate records in the PKG vhdl
    ### note the padding is not implemented yet
    def traverse(self, current_node=None, padding='\t'):
        if not current_node:
            current_node = self.root
        package_mon_entries = dict()
        package_ctrl_entries = dict()
        package_ctrl_entry_defaults = dict()
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
                if child_records.has_key('ctrl_default'):
                    package_ctrl_entry_defaults[child.id] = "DEFAULT_"+child.getPath().replace('.','_')+"_CTRL_t"
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
                    if self.read_ops.has_key(child.getLocalAddress()):
                        self.read_ops[child.getLocalAddress()] = self.read_ops[child.getLocalAddress()] + str("localRdData("+bits+")")+" <= Mon."+child.id+"; --"+child.description+"\n"
                    else:
                        self.read_ops[child.getLocalAddress()] =                           str("localRdData("+bits+")")+" <= Mon."+child.id+"; --"+child.description+"\n"
                elif child.permission == 'rw':
                    package_ctrl_entries[child.id] = package_entries
                    ##### store data for default signal
                    if child.parameters.has_key("default"):
                        package_ctrl_entry_defaults[child.id] = child.parameters["default"]
                    elif bits.find("downto") > 0:
                        package_ctrl_entry_defaults[child.id] = "(others => '0')"
                    else:
                        package_ctrl_entry_defaults[child.id] = "'0'"
                    if self.read_ops.has_key(child.getLocalAddress()):
                        self.read_ops[child.getLocalAddress()] = self.read_ops[child.getLocalAddress()] + str("localRdData("+bits+")")+" <= "+"reg_data("+str(child.getLocalAddress()).rjust(2)+")("+bits+"); --"+child.description+"\n"
                    else:
                        self.read_ops[child.getLocalAddress()] =                           str("localRdData("+bits+")")+" <= "+"reg_data("+str(child.getLocalAddress()).rjust(2)+")("+bits+"); --"+child.description+"\n"
                    if self.write_ops.has_key(child.getLocalAddress()):
                        self.write_ops[child.getLocalAddress()] = self.write_ops[child.getLocalAddress()] + str("reg_data("+str(child.getLocalAddress()).rjust(2)+")("+bits+")") + " <= localWrData("+bits+"); --"+child.description+"\n"
                    else:
                        self.write_ops[child.getLocalAddress()] =                            str("reg_data("+str(child.getLocalAddress()).rjust(2)+")("+bits+")") + " <= localWrData("+bits+"); --"+child.description+"\n"
                    self.readwrite_ops+=("Ctrl."+child.id) + " <= reg_data("+str(child.getLocalAddress()).rjust(2)+")("+bits+");\n"
                    self.default_ops+="reg_data("+str(child.getLocalAddress()).rjust(2)+")("+bits+") <= "+("CTRL_t."+child.id)+";\n"
                elif child.permission == 'w':
                    ##### store data for default signal
                    if child.parameters.has_key("default"):
                        package_ctrl_entry_defaults[child.id] = child.parameters["default"]
                    elif bits.find("downto") > 0:
                        package_ctrl_entry_defaults[child.id] = "(others => '0')"
                    else:
                        package_ctrl_entry_defaults[child.id] = "'0'"
                    package_ctrl_entries[child.id] = package_entries
                    if self.write_ops.has_key(child.getLocalAddress()):
                        self.write_ops[child.getLocalAddress()] = self.write_ops[child.getLocalAddress()] + ("Ctrl."+child.id) + " <= localWrData("+bits+");\n"
                    else:                                                     
                        self.write_ops[child.getLocalAddress()] =                            ("Ctrl."+child.id) + " <= localWrData("+bits+");\n"
                    #determin if this is a vector or a single entry
                    if bits.find("downto") > 0:
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
            ret["ctrl_default"] = self.generateDefaultRecord(baseName, package_ctrl_entry_defaults)
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
            output.write("        when "+str(addr)+" => --"+hex(addr)+"\n");
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

    def generate_def_ops_output(self):
        output = StringIO.StringIO()
        for line in self.default_ops.split("\n"):
            if(len(line)):
                output.write("      "+line.split("<")[0])
                output.write(" <= DEFAULT_"+self.root.id+"_"+line.split("=")[1].strip())
                output.write("\n")
        return output.getvalue()

    ### This should only be called after generatePkg is called
    def generateRegMap(self, outFileName=None, regMapTemplate="template_map.vhd"):
        if (not self.read_ops) and (not self.write_ops):
            self.log.critical("generateRegMap must be called after generatePkg!")
            return
        outFileBase = self.root.id
        if not outFileName:
            outFileName = outFileBase+"_map.vhd"
        ##### calculate regMapSize and regAddrRange
        regMapSize=0
        if len(self.read_ops) and max(self.read_ops,key=int) > regMapSize:
            regMapSize = max(self.read_ops,key=int)
        if len(self.write_ops) and max(self.write_ops,key=int) > regMapSize:
            regMapSize = max(self.write_ops,key=int)
        if regMapSize>0:
            regAddrRange=str(int(math.floor(math.log(regMapSize,2))))
        else:
            regAddrRange='0'
        ##### read the template from template file
        with open(os.path.join(sys.path[0],regMapTemplate)) as template_input_file:
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
            "def_ops_output": self.generate_def_ops_output(),
        }
        RegMapOutput = RegMapOutput.substitute(substitute_mapping)
        ##### output to file
        with open(outFileName,'w') as outFile:
            outFile.write(RegMapOutput)
            outFile.close()
        return
