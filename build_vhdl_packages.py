#!/usr/bin/python
"""
The script takes an uHAL compliant XML input file and prints out the vhdl module.

Note that full address decoding is not performed (would be very
inefficient with 32b address space), so slaves will appear at many
locations.

"""
from __future__ import print_function
from parsers import simpleParser,tree,node
import sys
import os
import time
import logging
import math
import argparse
import shutil
#from tree import *  # import node,arraynode,tree
try:
    from StringIO import StringIO  # for Python 2
except ImportError:
    from io import StringIO  # for Python 3
uhalFlag = True
try:
    import uhal
except ImportError:
    uhalFlag = False

from tester import generate_test_xml


# ===========================================================================================
# In Python 3 "xrange" doesn't exist, since Python 3's "range" is just as efficient as Python 2's "xrange"
if (sys.version_info[0] > 2):
    xrange = range


# ===========================================================================================

EXIT_CODE_INCORRECT_ARGUMENTS = 1
EXIT_CODE_ARG_PARSING_ERROR = 2
EXIT_CODE_NODE_ADDRESS_ERRORS = 3


def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def findArrayType(n):
    if n.isArray():
        print("found array-type reg: "+n.id)
        print("indices are: "+str(n.entries.keys()))
    for i in n.children:
        findArrayType(i)
    return


def useSimpleParser(test_xml,HDLPath,regMapTemplate,pkgTemplate,verbose,debug):
    root = simpleParser.ParserNode(name='Root')
    cTree = simpleParser.ParserTree(root)
    cTree.buildTree(root,test_xml)

    if not os.path.exists(HDLPath):
        os.makedirs(HDLPath)
    else:
        shutil.rmtree(HDLPath)
        os.makedirs(HDLPath)
    cwd = os.getcwd()
    os.chdir(cwd+"/"+HDLPath)

    for child in root.getChildren():
        child.setParent(None)
        print("Generating:", child.getName())
        mytree = tree.tree(child)
        mytree.generatePkg()
        mytree.generateRegMap(regMapTemplate=regMapTemplate)
        child.setParent(root)

    print("done")
    os.chdir(cwd)


def useUhalParser(test_xml,HDLPath,regMapTemplate,pkgTemplate,verbose,debug):
    # configure logger
    global log
    log = logging.getLogger("main")
    formatter = logging.Formatter('%(name)s %(levelname)s: %(message)s')
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)
    log.addHandler(handler)
    log.setLevel(logging.WARNING)
    uhal.setLogLevelTo(uhal.LogLevel.WARNING)

    if verbose:
        log.setLevel(logging.INFO)
        uhal.setLogLevelTo(uhal.LogLevel.INFO)
    if debug:
        log.setLevel(logging.DEBUG)
        uhal.setLogLevelTo(uhal.LogLevel.DEBUG)

    try:
        device = uhal.getDevice(
            "dummy", "ipbusudp-1.3://localhost:12345", "file://" + test_xml)
    except Exception:
        raise Exception(
            "File '%s' does not exist or has incorrect format" % test_xml)

    if not os.path.exists(HDLPath):
        os.makedirs(HDLPath)
    else:
        shutil.rmtree(HDLPath)
        os.makedirs(HDLPath)
    cwd = os.getcwd()
    os.chdir(cwd+"/"+HDLPath)

    for i in device.getNodes():
        if i.count('.') == 0:
            mytree = tree.tree(device.getNode(i), log)
            mytree.generatePkg()
            mytree.generateRegMap(regMapTemplate=regMapTemplate)

            # test array-type
            # findArrayType(mytree.root)

    os.chdir(cwd)


if __name__ == '__main__':
    global read_ops
    global write_ops
    global action_ops
    global readwrite_ops

    read_ops = dict(list())
    readwrite_ops = str()
    write_ops = dict(list())
    action_ops = str()

    parser = argparse.ArgumentParser(description="Generate VHDL decoder from XML address table")
    parser.add_argument("--simple","-s",type=str2bool,help="Use simple XML parser (no uHAL)",required=False,default=False)
    parser.add_argument("--verbose","-v",type=str2bool,help="Turn on verbose output",required=False,default=False)
    parser.add_argument("--debug","-d",type=str2bool,help="Turn on debugging info",required=False,default=False)
    parser.add_argument("--mapTemplate","-m",help="Template to use for decoder map file",required=False,default="templates/axi_generic/template_map.vhd")
    parser.add_argument("--pkgTemplate","-p",help="Template to use for PKG file (not supported yet)",required=False)
    parser.add_argument("--outpath","-o",help="output path to use",required=False,default="autogen")
    parser.add_argument("--xmlpath","-x",help="Path where \"name\" xml file is found and its included xml files",required=False,default="")
    parser.add_argument("name",help="base name of decoder xml file (no .xml)")

    args=parser.parse_args()
    
    #build the temp file
    try:
        os.mkdir(args.outpath) #create outpath
    except:
        pass
        
    #check that the path was created
    if not os.path.exists(args.outpath):
        print("Cannont create "+args.outpath)
        exit

    if len(args.xmlpath) > 0:
        args.xmlpath = os.path.abspath(args.xmlpath)+"/"
    else:
        pass
        #assumed to be in output path

    #generate unique(ish) filename for testxml
    test_xml=""
    if len(args.outpath) > 0:
        test_xml=args.outpath+"/"
    test_xml=test_xml+"test_"+str(int(time.time()))+".xml"
    
    generate_test_xml.generate_test_xml(args.name, 0x0, args.xmlpath+args.name+".xml", test_xml)

    if args.simple:
        print("Using simple parser")
        useSimpleParser(test_xml,
                        args.outpath,
                        args.mapTemplate,
                        args.pkgTemplate,
                        args.verbose,
                        args.debug)
    else:
        print("Using uHAL parser")
        useUhalParser(test_xml,
                      args.outpath,
                      args.mapTemplate,
                      args.pkgTemplate,
                      args.verbose,
                      args.debug)
    
    #delete test file
#    os.remove(test_xml)
