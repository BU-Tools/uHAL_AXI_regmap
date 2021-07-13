#!/usr/bin/python
"""
usage: gen_ipus_addr_decode [options] <uhal_address_table.xml>

The script generates the address select logic in the
file for the ipbus system.

The script takes an uHAL compliant XML input file and prints out the vhdl module.

Note that full address decoding is not performed (would be very
inefficient with 32b address space), so slaves will appear at many
locations.

options:
    -c, --custom                             custom parser
    -v, --verbose                            verbose
    -d, --debug                              debug output
    -t <file>, --template=<file>             uses a different vhdl template file
                                            (default
                                            /opt/cactus/etc/uhal/tools/ipbus_addr_decode.vhd)
"""
from __future__ import print_function
import customParser
import getopt
import sys
import os
import time
import logging
import math
import argparse
import shutil
from tree import *  # import node,arraynode,tree
try:
    from StringIO import StringIO  # for Python 2
except ImportError:
    from io import StringIO  # for Python 3
uhalFlag = True
try:
    import uhal
except ImportError:
    uhalFlag = False


# ===========================================================================================
# In Python 3 "xrange" doesn't exist, since Python 3's "range" is just as efficient as Python 2's "xrange"
if (sys.version_info[0] > 2):
    xrange = range


# ===========================================================================================

EXIT_CODE_INCORRECT_ARGUMENTS = 1
EXIT_CODE_ARG_PARSING_ERROR = 2
EXIT_CODE_NODE_ADDRESS_ERRORS = 3


template_file = "templates/axi_generic/template_map.vhd"


def findArrayType(n):
    if n.isArray():
        print("found array-type reg: "+n.id)
        print("indices are: "+str(n.entries.keys()))
    for i in n.children:
        findArrayType(i)
    return


def useCustomParser(topFile, HDLPath="CParser"):
    root = customParser.ParserNode(name='Root')
    cTree = customParser.ParserTree(root)
    cTree.buildTree(root, topFile)

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
        mytree = tree(child)
        mytree.generatePkg()
        mytree.generateRegMap()
        child.setParent(root)

    print("done")
    os.chdir(cwd)


def useUhalParser(topFile, HDLPath="UParser", opts=[]):
    # configure logger
    global log
    log = logging.getLogger("main")
    formatter = logging.Formatter('%(name)s %(levelname)s: %(message)s')
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)
    log.addHandler(handler)
    log.setLevel(logging.WARNING)
    uhal.setLogLevelTo(uhal.LogLevel.WARNING)

    for o, a in opts:
        if o in ("-v", "--verbose"):
            log.setLevel(logging.INFO)
            uhal.setLogLevelTo(uhal.LogLevel.INFO)
        elif o in ("-d", "--debug"):
            log.setLevel(logging.DEBUG)
            uhal.setLogLevelTo(uhal.LogLevel.DEBUG)
        elif o in ("-h", "--help"):
            print(__doc__)
            sys.exit(0)

    try:
        device = uhal.getDevice(
            "dummy", "ipbusudp-1.3://localhost:12345", "file://" + topFile)
    except Exception:
        raise Exception(
            "File '%s' does not exist or has incorrect format" % topFile)

    if not os.path.exists(HDLPath):
        os.makedirs(HDLPath)
    else:
        shutil.rmtree(HDLPath)
        os.makedirs(HDLPath)
    cwd = os.getcwd()
    os.chdir(cwd+"/"+HDLPath)

    for i in device.getNodes():
        if i.count('.') == 0:
            mytree = tree(device.getNode(i), log)
            mytree.generatePkg()
            mytree.generateRegMap(regMapTemplate=template_file)

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

    try:
        opts, args = getopt.getopt(sys.argv[1:], "cvdh:", [
                                   "custom", "verbose", "debug", "help"])
    except getopt.GetoptError as err:
        print("error")
        # log.critical(__doc__)
        sys.exit(EXIT_CODE_ARG_PARSING_ERROR)

    # make sure that exactly one argument was given, later assumed to be the xml file name
    if len(args) == 0:
        print("Incorrect usage - invalid number of arguments! Make sure that options come before argument.\n")
        # log.critical(
        #     "Incorrect usage - invalid number of arguments! Make sure that options come before argument.\n" + __doc__)
        sys.exit(EXIT_CODE_INCORRECT_ARGUMENTS)
    else:
        top_file = args[0]
        if len(args) > 1:
            template_file = args[1]
        else:
            template_file = "templates/axi_generic/template_map.vhd"

    customParserFlag = False
    for o, a in opts:
        if o in ("-c", "--custom"):
            customParserFlag = True

    if customParserFlag:
        useCustomParser(args[0])
    else:
        useUhalParser(args[0], opts=opts)
