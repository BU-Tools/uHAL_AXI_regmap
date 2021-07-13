from __future__ import print_function
import os
from tree import *
from parserNode import *


# useUhal should be a boolean
def Generate_VHDL(name, XMLFile, HDLPath, map_template_file, pkg_template_file, useUhal):
    print("Generate VHDL for", name, "from", XMLFile)
    # get working directory
    wd = os.getcwd()

    # move into the output HDL directory
    os.chdir(wd+"/"+HDLPath)

    # make a symlink to the XML file
    fullXMLFile = wd+"/"+XMLFile

    # generate a fake top address table
    slaveAddress = "0x"+hex(0x00000000)[2:]
    topXMLFile = "top.xml"

    outXMLFile = open(topXMLFile, 'w')
    outXMLFile.write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n")
    outXMLFile.write("<node id=\"TOP\">\n")
    outXMLFile.write("  <node id=\"" + name + "\"        module=\"file://" +
                     fullXMLFile + "\"        address=\"" + slaveAddress + "\"/>\n")
    outXMLFile.write("</node>\n")
    outXMLFile.close()

    # generate the VHDL
    if useUhal:
        try:
            import uhal
            device = uhal.getDevice(
                "dummy", "ipbusudp-1.3://localhost:12345", "file://" + topXMLFile)
            for i in device.getNodes():
                if i.count('.') == 0:
                    mytree = tree(device.getNode(i), log)
                    mytree.generatePkg()
                    mytree.generateRegMap(
                        regMapTemplate=wd+"/"+map_template_file)
        except ImportError:
            print("uhal is not installed")
    else:
        root = ParserNode(name='TOP')
        buildTree(root, topXMLFile, init=True)
        for child in root.getChildren():
            child.setParent(None)
            mytree = tree(child)
            mytree.generatePkg()
            mytree.generateRegMap()
            child.setParent(root)

    # cleanup
    os.remove(topXMLFile)
    os.chdir(wd)  # go back to original path
