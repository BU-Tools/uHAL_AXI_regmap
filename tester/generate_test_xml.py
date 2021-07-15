#!/usr/bin/python
#usage: ./generate_input_xml [source xml file name]
import sys
import logging
import os.path

def generate_test_xml(pkg_name, address, in_xml_name, test_xml_name="test.xml"):
    print("opeing file"+test_xml_name)
    outFile=open(test_xml_name,'w')
    #outFile.write("<?This file was auto-generated.?>\n")
    #outFile.write("<?Modifications might be lost.?>\n")
    #outFile.write("<?Modifications might be lost.?>\n")
    outFile.write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n")
    outFile.write("<node id=\"TOP\">\n")
    outFile.write("  <node id=\"" +pkg_name+ "\"        module=\"file://" +in_xml_name+ "\"        address=\"" +str(address)+ "\"/>\n")
    outFile.write("</node>\n")
    outFile.close()

