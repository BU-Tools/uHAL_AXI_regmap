#!/usr/bin/python
#################################################################################                                                                                                             
## Force python3                                                                                                                                                                              
#################################################################################                                                                                                             
import sys                                                                                                                                                                                    
if not sys.version_info.major == 3:                                                                                                                                                           
    raise BaseException("Wrong Python version detected.  Please ensure that you are using Python 3.")                                                                                         
#################################################################################              

#usage: ./generate_input_xml [source xml file name]
import sys
import logging
import os.path

def generate_test_xml(pkg_name, address, in_xml_name, test_xml_name="test.xml"):
    outFile=open(test_xml_name,'w')
    #outFile.write("<?This file was auto-generated.?>\n")
    #outFile.write("<?Modifications might be lost.?>\n")
    #outFile.write("<?Modifications might be lost.?>\n")
    outFile.write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n")
    outFile.write("<node id=\"TOP\">\n")
    outFile.write("  <node id=\"" +pkg_name+ "\"    fwInfo=\"uio_endpoint\"    module=\"file://" +in_xml_name+ "\"        address=\"" +str(address)+ "\"/>\n")
    outFile.write("</node>\n")
    outFile.close()

