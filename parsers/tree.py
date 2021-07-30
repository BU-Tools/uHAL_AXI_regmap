from . import node
import math
import os
import sys
import re

from jinja2 import Template
from collections import OrderedDict
try:
    from StringIO import StringIO  # for Python 2
except ImportError:
    from io import StringIO  # for Python 3


class tree(object):
    def __init__(self, root, logger=None, debug=False, yml2hdl=0):
        self.read_ops = OrderedDict(list())
        self.readwrite_ops = str()
        self.write_ops = OrderedDict(list())
        self.action_ops = str()
        self.default_ops = str()
        self.debug = debug
        self.bramCount = 0
        self.bramRanges = str()
        self.bramAddrs = str()
        self.bram_MOSI_map = str()
        self.bram_MISO_map = str()
        self.bram_max_addr = int(0)

        # package write selection
        # version of yml2hdl tool type yml output
        # 0=disable yml output
        # 1=yml2hdl v1
        # 2=yml2hdl v2
        # etc...
        #
        # Actually only 1 version is supported right now and I have no idea what
        # it is

        self.yml2hdl = yml2hdl

        # setup logger
        self.log = logger
        # if not self.log:
        #     self.log = logging.getLogger("main")
        #     formatter = logging.Formatter(
        #         '%(name)s %(levelname)s: %(message)s')
        #     handler = logging.StreamHandler(sys.stdout)
        #     handler.setFormatter(formatter)
        #     self.log.addHandler(handler)
        #     self.log.setLevel(logging.WARNING)
        #     uhal.setLogLevelTo(uhal.LogLevel.WARNING)
        # read the root node
        self.root = node.node(root, baseAddress=0, tree=self)

    def generate_yaml (self, baseName, current_node, members, description):
        """ Generate and print a VHDL record into yml2hdl v{x} format"""

        outFileName = self.outFileName.replace("PKG.vhd", "PKG.yml")

        with open(outFileName, 'a') as outFile:

            outFile.write("- " + baseName+":\n")
            sorted_members = sorted(members.items(),
                                    key=lambda item: (current_node.getChild(item[0]).address<<32) + current_node.getChild(item[0]).mask)

            for memberName, member in sorted_members:

                outFile.write("  - " + memberName + " : [ type: ")
                member_type = re.sub("\(.*\\)", "", member.replace("std_logic_vector", "logic").replace("std_logic", "logic"))
                outFile.write(member_type)
                if ("downto" in member):
                    (high, low) = re.search(r'\((.*?)\)', member).group(1).replace("downto", " ").split()
                    length = int(high)-int(low)+1
                    outFile.write(", length: "+str(length))

                # if len(description[memberName]) > 0:
                #     outFile.write(", description: " + description[memberName])

                outFile.write(" ]\n")

            if current_node.isArray():
                array_index_string = "array: " + str(1 + max(current_node.entries.keys()))+", type: "
                # array_index_string = "array: (" + str(min(current_node.entries.keys())) + " to " + str(max(current_node.entries.keys()))+"), type : "
                outFile.write("\n- " + baseName + "_ARRAY: [" + array_index_string + baseName + "]")

            outFile.write("\n\n")
            outFile.close()
            return

    def generateRecord(self, baseName, current_node, members, description):
        with open(self.outFileName, 'a') as outFile:
            # Generate and print a VHDL record
            outFile.write("  type " + baseName + " is record\n")
            maxNameLength = 25
            maxTypeLength = 12
            sorted_members = sorted(members.items(), key=lambda item: (current_node.getChild(
                item[0]).address << 32) + current_node.getChild(item[0]).mask)
            for memberName, member in sorted_members:
                if len(memberName) > maxNameLength:
                    maxNameLength = len(memberName)
                if len(member) > maxTypeLength:
                    maxTypeLength = len(member)
                outFile.write(
                    "    " + memberName + "".ljust(maxNameLength-len(memberName), ' ') + "  :")
                outFile.write((member+';').ljust(maxTypeLength+1, ' '))
                if len(description[memberName]) > 0:
                    outFile.write("  -- " + description[memberName])
                outFile.write('\n')
            outFile.write("  end record " + baseName + ";\n")
            if current_node.isArray():
                array_index_string = " is array(" + str(min(current_node.entries.keys(
                ))) + " to " + str(max(current_node.entries.keys()))+") of "
                outFile.write("  type " + baseName + "_ARRAY" +
                              array_index_string + baseName + ";")
            outFile.write("\n\n")
            outFile.close()
        # TODO: return value here?
        return

    def generateDefaultRecord(self, baseName, defaults, outFileName, ctrl_file_lib="ctrl_lib"):
        with open(outFileName, 'a') as outfile:
            outfile.write("  constant DEFAULT_" + baseName +
                          " : " + baseName + " := (\n")
            padding_size = 27 + (2 * len(baseName))
            firstLine = True
            for keys, values in defaults.items():
                # if the value is in the format of 0x1, translate it into x'1'
                if '0x' in values:
                    values = values.replace('0x', '')
                    if values == '1':
                        values = "'1'"
                    else:
                        values = 'x"'+values+'"'
                if firstLine:
                    firstLine = False
                else:
                    outfile.write(",\n")
                outfile.write(" ".ljust(padding_size, ' ')+keys+" => "+values)
            outfile.write("\n ".ljust(padding_size, ' ')+");\n")
            outfile.close()
        return "DEFAULT_"+baseName

    def buildCustomBRAM_MOSI(self, name, addr_size, data_size):
        fullName = name+"_MOSI_t"
        with open(self.outFileName, 'a') as outFile:
            # Generate and print a VHDL record
            outFile.write("  type " + fullName + " is record\n")
            outFile.write("    clk       : std_logic;\n")
            outFile.write("    enable    : std_logic;\n")
            outFile.write("    wr_enable : std_logic;\n")
            outFile.write("    address   : std_logic_vector(" +
                          str(addr_size)+"-1 downto 0);\n")
            outFile.write("    wr_data   : std_logic_vector(" +
                          str(data_size)+"-1 downto 0);\n")
            outFile.write("  end record " + fullName + ";\n")
            outFile.close()
        return fullName

    def buildCustomBRAM_MISO(self, name, addr_size, data_size):
        fullName = name+"_MISO_t"
        with open(self.outFileName, 'a') as outFile:
            # Generate and print a VHDL record
            outFile.write("  type " + fullName + " is record\n")
            outFile.write("    rd_data         : std_logic_vector("+str(data_size)+"-1 downto 0);\n")
            outFile.write("    rd_data_valid   : std_logic;\n")
            outFile.write("  end record " + fullName + ";\n")
            outFile.close()
        return fullName

    def buildDefaultBRAM_MOSI(self, name, addr_size, data_size):
        fullName = name+"_MOSI_t"
        defaultName = "Default_"+fullName
        with open(self.outFileName, 'a') as outFile:
            # Generate and print a VHDL record
            pad = " "*52
            outFile.write("  constant "+defaultName+" : "+fullName+" := ( \n")
            outFile.write("%s clk       => '0',\n" % pad)
            outFile.write("%s enable    => '0',\n" % pad)
            outFile.write("%s wr_enable => '0',\n" % pad)
            outFile.write("%s address   => (others => '0'),\n" % pad)
            outFile.write("%s wr_data   => (others => '0')\n" % pad)
            outFile.write("  );\n")
            outFile.close()
        return defaultName

    def traversePkg(self, current_node=None, padding='\t'):
        if not current_node:
            current_node = self.root
        #print(padding+current_node.id+': ['+str([i.id for i in current_node.children]))
        package_mon_entries = OrderedDict()
        package_ctrl_entries = OrderedDict()
        package_ctrl_entry_defaults = OrderedDict()
        package_description = OrderedDict()
        package_addr_order = OrderedDict()
        for child in current_node.children:
            if len(child.children) != 0:
                child_records = self.traversePkg(child, padding+'\t')
                package_description[child.id] = ""
                array_postfix = ["", "_ARRAY"][child.isArray()]
                # make the records for package entries
                if 'mon' in child_records:
                    package_mon_entries[child.id] = child.getPath(
                        expandArray=False).replace('.', '_')+'_MON_t'+array_postfix
                if 'ctrl' in child_records:
                    package_ctrl_entries[child.id] = child.getPath(
                        expandArray=False).replace('.', '_') + '_CTRL_t'+array_postfix
                if 'ctrl_default' in child_records:
                    default_package_entries = "DEFAULT_" + \
                        child.getPath(expandArray=False).replace(
                            '.', '_')+"_CTRL_t"
                    if child.isArray():
                        default_package_entries = "(others => " + \
                            default_package_entries+" )"
                    package_ctrl_entry_defaults[child.id] = default_package_entries
            else:
                if child.isMem:
                    package_description[child.id] = ""
                    # get base name for this node
                    bramName = child.getPath(
                        expandArray=False).replace('.', '_')
                    # create the MOSI package as a control package and add it to the list
                    package_ctrl_entries[child.id] = self.buildCustomBRAM_MOSI(bramName,
                                                                               child.addrWidth,
                                                                               child.dataWidth)
                    # create the MISO package as a monitor package and add it to the list
                    package_mon_entries[child.id] = self.buildCustomBRAM_MISO(bramName,
                                                                              child.addrWidth,
                                                                              child.dataWidth)

                    package_ctrl_entry_defaults[child.id] = self.buildDefaultBRAM_MOSI(bramName,
                                                                                       child.addrWidth,
                                                                                       child.dataWidth)
                    self.bramCount = self.bramCount + 1
                    if self.bramCount == 1:
                        self.bramAddrs = str(
                            self.bramCount-1)+" => x\""+hex(child.getLocalAddress())[2:].zfill(8)+"\""
                        self.bramRanges = str(
                            self.bramCount-1)+" => "+str(child.addrWidth)
                    else:
                        self.bramAddrs = self.bramAddrs + "\n,\t\t\t" + \
                            str(self.bramCount-1)+" => x\"" + \
                            hex(child.getLocalAddress())[2:].zfill(8)+"\""
                        self.bramRanges = self.bramRanges+"\n,\t\t\t" + \
                            str(self.bramCount-1)+" => "+str(child.addrWidth)

                    bram_end = child.getLocalAddress() + 2**child.addrWidth
                    if bram_end > self.bram_max_addr:
                        self.bram_max_addr = bram_end
#                    bramTableName=child.getPath(expandArray=False)[(current_node.getPath(expandArray=False)).find("."):]
                    bramTableName = child.getPath(expandArray=False)
                    bramTableName = bramTableName[bramTableName.find(".")+1:]
                    self.bram_MOSI_map = self.bram_MOSI_map+"  Ctrl."+bramTableName + \
                        ".clk       <=  BRAM_MOSI(" + \
                        str(self.bramCount-1)+").clk;\n"
                    self.bram_MOSI_map = self.bram_MOSI_map+"  Ctrl."+bramTableName + \
                        ".enable    <=  BRAM_MOSI(" + \
                        str(self.bramCount-1)+").enable;\n"
                    self.bram_MOSI_map = self.bram_MOSI_map+"  Ctrl."+bramTableName + \
                        ".wr_enable <=  BRAM_MOSI(" + \
                        str(self.bramCount-1)+").wr_enable;\n"
                    self.bram_MOSI_map = self.bram_MOSI_map+"  Ctrl."+bramTableName + \
                        ".address   <=  BRAM_MOSI("+str(self.bramCount-1) + \
                        ").address("+str(child.addrWidth)+"-1 downto 0);\n"
                    self.bram_MOSI_map = self.bram_MOSI_map+"  Ctrl."+bramTableName + \
                        ".wr_data   <=  BRAM_MOSI("+str(self.bramCount-1) + \
                        ").wr_data("+str(child.dataWidth)+"-1 downto 0);\n\n"
                    self.bram_MISO_map = self.bram_MISO_map+"  BRAM_MISO("+str(self.bramCount-1)+").rd_data("+str(
                        child.dataWidth)+"-1 downto 0) <= Mon."+bramTableName+".rd_data;\n"
                    self.bram_MISO_map = self.bram_MISO_map + \
                        "  BRAM_MISO("+str(self.bramCount-1)+").rd_data(31 downto " + \
                        str(child.dataWidth)+") <= (others => '0');\n"
                    self.bram_MISO_map = self.bram_MISO_map + \
                        "  BRAM_MISO("+str(self.bramCount-1)+").rd_data_valid <= Mon." + \
                        bramTableName+".rd_data_valid;\n\n"
                else:
                    bitCount = bin(child.mask)[2:].count('1')
                    package_entries = ""
                    if bitCount == 1:
                        package_entries += "std_logic"
                    else:
                        package_entries += "std_logic_vector(" + str(
                            bitCount-1).rjust(2, ' ') + " downto 0)"

                    package_description[child.id] = child.description
                    bits = child.getBitRange()
                    if child.permission == 'r':
                        package_mon_entries[child.id] = package_entries
                    elif child.permission == 'rw':
                        package_ctrl_entries[child.id] = package_entries
                        # store data for default signal
                        if "default" in child.parameters:
                            intValue = int(child.parameters["default"], 0)
                            if bits.find("downto") > 0:
                                if bitCount % 4 == 0:
                                    package_ctrl_entry_defaults[child.id] = "x\"" + hex(
                                        intValue)[2:].zfill(int(bitCount/4)) + "\""
                                else:
                                    package_ctrl_entry_defaults[child.id] = "\"" + bin(
                                        intValue)[2:].zfill(bitCount) + "\""
                            else:
                                package_ctrl_entry_defaults[child.id] = "'"+str(
                                    intValue)+"'"
                        elif bits.find("downto") > 0:
                            package_ctrl_entry_defaults[child.id] = "(others => '0')"
                        else:
                            package_ctrl_entry_defaults[child.id] = "'0'"
                    elif child.permission == 'w':
                        # store data for default signal
                        if "default" in child.parameters:
                            print("Action register with default value!\n")
                        elif bits.find("downto") > 0:
                            package_ctrl_entry_defaults[child.id] = "(others => '0')"
                        else:
                            package_ctrl_entry_defaults[child.id] = "'0'"
                        package_ctrl_entries[child.id] = package_entries
        ret = {}
        if package_mon_entries:
            baseName = current_node.getPath(
                expandArray=False).replace('.', '_')+'_MON_t'
            # print(padding+baseName)

            if self.yml2hdl == 0:
                ret['mon'] = self.generateRecord(baseName, current_node, package_mon_entries, package_description)
            if self.yml2hdl == 1 or self.yml2hdl == 2:
                self.generate_yaml(baseName, current_node, package_mon_entries,
                                   package_description)

        if package_ctrl_entries:
            baseName = current_node.getPath(
                expandArray=False).replace('.', '_')+'_CTRL_t'

            # print(padding+baseName)

            ret['ctrl'] = self.generateRecord(baseName, current_node, package_ctrl_entries, package_description)

            def_pkg_name = self.outFileName

            if self.yml2hdl > 0:
                def_pkg_name = def_pkg_name.replace("PKG.vhd", "PKG_DEF.vhd")

            ret["ctrl_default"] = self.generateDefaultRecord(baseName, package_ctrl_entry_defaults, def_pkg_name)

            if self.yml2hdl > 0:
                self.generate_yaml(baseName, current_node, package_ctrl_entries, package_description)

        return ret

    def generatePkg(self, outFileName=None, ctrl_file_lib="ctrl_lib"):

        # initialize
        self.read_ops = OrderedDict(list())
        self.readwrite_ops = str()
        self.write_ops = OrderedDict(list())
        self.action_ops = str()
        outFileBase = self.root.id
        self.outFileName = outFileName

        # write the package header
        if not self.outFileName:
            self.outFileName = outFileBase + "_PKG.vhd"
        with open(self.outFileName, 'w') as outFile:
            outFile.write("--This file was auto-generated.\n")
            outFile.write("--Modifications might be lost.\n")
            outFile.write("library IEEE;\n")
            outFile.write("use IEEE.std_logic_1164.all;\n")

            # yml2hdl libraries
            if (self.yml2hdl > 0):
                outFile.write("library shared_lib;\n")
                outFile.write("use shared_lib.common_ieee.all;\n")
            outFile.write("\n\npackage "+outFileBase+"_CTRL is\n")
            outFile.close()

        # write the defaults package header

        def_pkg_name = self.outFileName.replace("PKG.vhd", "PKG_DEF.vhd")

        if (self.yml2hdl > 0):
            with open(def_pkg_name, 'w') as outfile:
                outfile.write("--This file was auto-generated.\n")
                outfile.write("--Modifications might be lost.\n")
                outfile.write("library IEEE;\n")
                outfile.write("use IEEE.std_logic_1164.all;\n")

                outfile.write("library %s;\n" % ctrl_file_lib)
                outfile.write("use %s.%s.all;\n" % (ctrl_file_lib, outFileBase))

                outfile.write("library shared_lib;\n")
                outfile.write("use shared_lib.common_ieee.all;\n")

                outfile.write("\n\npackage "+outFileBase+"_DEF is\n")

        # write the package payload
        self.traversePkg()

        # write the package trailer
        with open(self.outFileName, 'a') as outFile:
            outFile.write("\n\nend package "+outFileBase+"_CTRL;")
            outFile.close()

        if (self.yml2hdl > 0):
            with open(def_pkg_name, 'a') as outfile:
                outfile.write("\nend package;\n");


        return

    @staticmethod
    def sortByBit(line):
        assignmentPos = line.find("<=")
        if assignmentPos < 0:
            return assignmentPos
        numberStart = line[0:assignmentPos].rfind("(")+1
        numberEnd = line[numberStart:assignmentPos].find("downto")
        if numberEnd < 0:
            numberEnd = line[numberStart:assignmentPos].find(")")
        if numberEnd < 0:
            return 0
        numberEnd += numberStart
        return int(line[numberStart:numberEnd])

    @staticmethod
    def generateAlignedCase(operations):
        output = StringIO()
        newAssignmentPos = 0
        newAssignmentLength = 0
        for addr in operations:
            # find the position of the "<=" in each line so we can align them
            # find the max length of assignment names so we can align to that as well
            for line in operations[addr].split('\n'):
                assignmentPos = line.find("<=")
                if assignmentPos > newAssignmentPos:
                    newAssignmentPos = assignmentPos
                assignmentLength = line[assignmentPos:].find(";")
                if assignmentLength > newAssignmentLength:
                    newAssignmentLength = assignmentLength
        for addr in operations:
            output.write("        when "+str(addr)+" => --"+hex(addr)+"\n")
            for line in sorted(operations[addr].split('\n'), key=tree.sortByBit):
                if line.find("<=") > 0:
                    preAssignment = line[0:line.find("<=")-1]
                    line = line[line.find("<=")+2:]
                    assignment = line[0:line.find(";")]
                    line = line[line.find(";")+1:]
                    output.write("          " +
                                 preAssignment.ljust(newAssignmentPos) +
                                 " <= " +
                                 str(assignment+";").ljust(newAssignmentLength) +
                                 "    " +
                                 line +
                                 "\n")
        return output.getvalue()

    def generate_r_ops_output(self):
        return self.generateAlignedCase(self.read_ops)

    def generate_w_ops_output(self):
        return self.generateAlignedCase(self.write_ops)

    def generate_rw_ops_output(self):
        output = StringIO()
        newAssignmentPos = 0
        newAssignmentLength = 0
        for line in self.readwrite_ops.split("\n"):
            assignmentPos = line.find("<=")
            if assignmentPos > newAssignmentPos:
                newAssignmentPos = assignmentPos
            assignmentLength = line[assignmentPos:].find(";")
            if assignmentLength > newAssignmentLength:
                newAssignmentLength = assignmentLength
        for line in self.readwrite_ops.split("\n"):
            if line.find("<=") > 0:
                preAssignment = line[0:line.find("<=")-1]
                line = line[line.find("<=")+2:]
                assignment = line[0:line.find(";")]
                line = line[line.find(";")+1:]
                output.write("  " +
                             preAssignment.ljust(newAssignmentPos) +
                             " <= " +
                             str(assignment+";").ljust(newAssignmentLength) +
                             "    " +
                             line +
                             "\n")
        return output.getvalue()

    def generate_a_ops_output(self):
        output = StringIO()
        for line in self.action_ops.split("\n"):
            output.write("      "+line+"\n")
        return output.getvalue()

    def generate_def_ops_output(self):
        output = StringIO()
        for line in self.default_ops.split("\n"):
            if(len(line)):
                output.write("      "+line.split("<")[0])
                output.write(" <= DEFAULT_"+self.root.id +
                             "_"+line.split("=")[1].strip())
                output.write("\n")
        return output.getvalue()

    def traverseRegMap(self, current_node=None, padding='\t'):
        if not current_node:
            current_node = self.root
        # expand the array entries
        expanded_child_list = []
        for child in current_node.children:
            if child.isArray():
                for entry in child.entries.values():
                    expanded_child_list.append(entry)
            else:
                expanded_child_list.append(child)
        # loop over expanded list
        for child in expanded_child_list:
            if len(child.children) != 0:
                self.traverseRegMap(child, padding+'\t')
            else:
                if child.isMem:
                    continue
                bits = child.getBitRange()

                if child.permission == 'r':

                    # read only

                    read_op = "localRdData(%s) <= Mon.%s; --%s\n" % \
                        (bits, child.getPath(includeRoot=False, expandArray=True),
                         child.description)
                    if child.getLocalAddress() in self.read_ops:
                        self.read_ops[child.getLocalAddress()] += read_op
                    else:
                        self.read_ops[child.getLocalAddress()] = read_op

                elif child.permission == 'rw':

                    # read
                    read_op = "localRdData(%s) <= reg_data(%2d)(%s); --%s\n" % \
                        (bits, child.getLocalAddress(), bits, child.description)
                    if child.getLocalAddress() in self.read_ops:
                        self.read_ops[child.getLocalAddress()] += read_op
                    else:
                        self.read_ops[child.getLocalAddress()] = read_op

                    # write
                    wr_op = "reg_data(%2d)(%s) <= localWrData(%s); --%s\n" % \
                        (child.getLocalAddress(), bits,  bits, child.description)
                    if child.getLocalAddress() in self.write_ops:
                        self.write_ops[child.getLocalAddress()] += wr_op
                    else:
                        self.write_ops[child.getLocalAddress()] = wr_op

                    # read/write
                    self.readwrite_ops += "Ctrl.%s <= reg_data(%2d)(%s);\n" % \
                        (child.getPath(includeRoot=False, expandArray=True),
                         child.getLocalAddress(),bits)

                    # default
                    self.default_ops += "reg_data(%2d)(%s) <= CTRL_t.%s;\n" % \
                        (child.getLocalAddress(),
                         bits,
                         child.getPath(includeRoot=False, expandArray=True))

                elif child.permission == 'w':

                    # action_registers
                    wr_ops_str = "Ctrl.%s <= localWrData(%s);\n" % \
                        (child.getPath(includeRoot=False, expandArray=True), bits)

                    if child.getLocalAddress() in self.write_ops:
                        self.write_ops[child.getLocalAddress()] += wr_ops_str
                    else:
                        self.write_ops[child.getLocalAddress()] = wr_ops_str

                    # determine if this is a vector or a single entry
                    others = "(others => '0')" if bits.find("downto") > 0 else "'0'"
                    self.action_ops += "Ctrl.%s <= %s;\n" % \
                        (child.getPath(includeRoot=False, expandArray=True), others)

        return

    def generateRegMap(self, outFileName=None, regMapTemplate="template_map.vhd"):

        # if an explicit name is not specified, use the basename + _map.vhd
        outFileBase = self.root.id
        if not outFileName:
            outFileName = outFileBase + "_map.vhd"

        # traverse through the tree and fill the ops
        self.traverseRegMap()

        # calculate regMapSize and regAddrRange
        regMapSize = 0

        if len(self.read_ops) and max(self.read_ops, key=int) > regMapSize:
            regMapSize = max(self.read_ops, key=int)
        if len(self.write_ops) and max(self.write_ops, key=int) > regMapSize:
            regMapSize = max(self.write_ops, key=int)
        if self.bram_max_addr > regMapSize:
            regMapSize = self.bram_max_addr

        if regMapSize > 0:
            regAddrRange = str(int(math.floor(math.log(regMapSize, 2))))
        else:
            regAddrRange = '0'

        # read the template from template file
        with open(os.path.join(sys.path[0], regMapTemplate)) as template_input_file:
            RegMapOutput = template_input_file.read()
            RegMapOutput = Template(RegMapOutput)
            template_input_file.close()

        # Substitute keywords in the template
        substitute_mapping = {
            "baseName": outFileBase,
            "regMapSize": regMapSize,
            "regAddrRange": regAddrRange,
            "r_ops_output": self.generate_r_ops_output(),
            "rw_ops_output": self.generate_rw_ops_output(),
            "a_ops_output": self.generate_a_ops_output(),
            "w_ops_output": self.generate_w_ops_output(),
            "def_ops_output": self.generate_def_ops_output(),
            "bram_count": self.bramCount,
            "bram_ranges": self.bramRanges,
            "bram_addrs": self.bramAddrs,
            "bram_MOSI_map": self.bram_MOSI_map,
            "bram_MISO_map": self.bram_MISO_map,
        }

        RegMapOutput = RegMapOutput.render(substitute_mapping)

        # output to file
        with open(outFileName, 'w') as outFile:
            outFile.write(RegMapOutput)
            outFile.close()
        return
