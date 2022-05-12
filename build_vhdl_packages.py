#!/usr/bin/python3
#################################################################################                                                                                                             
## Force python3                                                                                                                                                                              
#################################################################################                                                                                                             
import sys                                                                                                                                                                                    
if not sys.version_info.major == 3:                                                                                                                                                           
    raise BaseException("Wrong Python version detected.  Please ensure that you are using Python 3.")                                                                                         
#################################################################################              

"""

The script takes an uHAL compliant XML input file
and prints out the vhdl module.

Note that full address decoding is not performed (would be very
inefficient with 32b address space), so slaves will appear at many
locations.

"""
#from __future__ import print_function
from parsers import simpleParser, tree
from tester import generate_test_xml
import sys
import os
import time
import logging
import argparse
import distutils.util

try:
    from StringIO import StringIO  # for Python 2
except ImportError:
    from io import StringIO  # for Python 3

uhalFlag = True

try:
    import uhal
    print(f"INFO: uhal library imported")
except ImportError:
    uhalFlag = False
    print(f"WARNING: failed to import uhal")

EXIT_CODE_INCORRECT_ARGUMENTS = 1
EXIT_CODE_ARG_PARSING_ERROR = 2
EXIT_CODE_NODE_ADDRESS_ERRORS = 3


def str2bool(v):
    return bool(distutils.util.strtobool(v))


def findArrayType(n):
    if n.isArray():
        print("found array-type reg: "+n.id)
        print("indices are: "+str(n.entries.keys()))
    for i in n.children:
        findArrayType(i)
    return


def useSimpleParser(test_xml, HDLPath, regMapTemplate, pkgTemplate="",
                    verbose=False, debug=False, yml2hdl=False):

    root = simpleParser.ParserNode(name='Root')
    cTree = simpleParser.ParserTree(root)
    cTree.buildTree(root, test_xml)

    if not os.path.exists(HDLPath):
        os.makedirs(HDLPath)
    cwd = os.getcwd()

    os.chdir(HDLPath)

    for child in root.getChildren():
        child.setParent(None)
        print("Generating:", child.getName())
        mytree = tree.tree(child, yml2hdl=yml2hdl)
        mytree.generatePkg()
        mytree.generateRegMap(regMapTemplate=regMapTemplate)
        child.setParent(root)

    print("done")
    os.chdir(cwd)


def parse_xml(test_xml, HDLPath, regMapTemplate, pkgTemplate="",
              parser="simple", verbose=False, debug=False, yml2hdl=False):
    if (parser == "simple"):
        func = useSimpleParser
    elif (parser == "uhal"):
        func = useUhalParser
    else:
        print("Unknown parser requested!!")
        sys.exit(1)

    func(test_xml, HDLPath, regMapTemplate, pkgTemplate,
         verbose, debug, yml2hdl)


def useUhalParser(test_xml, HDLPath, regMapTemplate, pkgTemplate="",
                  verbose=False, debug=False, yml2hdl=False):

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
    cwd = os.getcwd()
    os.chdir(os.path.abspath(HDLPath))

    for i in device.getNodes():
        if i.count('.') == 0:
            mytree = tree.tree(device.getNode(i), log, yml2hdl=yml2hdl)
            mytree.generatePkg()
            mytree.generateRegMap(regMapTemplate=regMapTemplate)

            # test array-type
            # findArrayType(mytree.root)

    os.chdir(cwd)


def build_vhdl_packages(simple, verbose, debug, mapTemplate, pkgTemplate,
                        outpath, xmlpath, name, yml2hdl=0, fallback=False):

    if not os.path.exists(outpath):
        print("Creating "+outpath)
        try:
            os.makedirs(outpath)  # create outpath
        except:
            print("Cannot create "+outpath)
            quit()
    # generate unique(ish) filename for testxml
    test_xml = ""
    if len(outpath) > 0:
        test_xml = outpath+"/"
    test_xml = test_xml + "test_" + str(int(time.time())) + ".xml"

    generate_test_xml.generate_test_xml(name, 0x0, os.path.abspath(xmlpath),
                                        test_xml)

    if simple:
        print("Using Standalone parser")
        parser = "simple"
    else:
        if (fallback and not uhalFlag):
            print("uHAL parser selected but not available... falling back to simple parser")
            parser = "simple"
        else:
            print("Using uHAL parser")
            parser = "uhal"

    parse_xml(test_xml, outpath, mapTemplate, pkgTemplate, yml2hdl=yml2hdl,
              parser=parser, verbose=verbose, debug=debug)

    # delete test file
    os.remove(test_xml)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description="Generate VHDL decoder from XML address table")
    parser.add_argument("--simple","-s",type=str2bool,help="Use simple XML parser (no uHAL)",required=False,default=False)
    parser.add_argument("--fallback","-f",type=str2bool,help="Allow fallback to the simple parser if uHAL is not available",required=False,default=False)
    parser.add_argument("--verbose","-v",type=str2bool,help="Turn on verbose output",required=False,default=False)
    parser.add_argument("--debug","-d",type=str2bool,help="Turn on debugging info",required=False,default=False)
    parser.add_argument("--yaml","-y",type=int,help="Enable YAML output",required=False,default=0)
    parser.add_argument("--mapTemplate","-m",help="Template to use for decoder map file",required=False,default="templates/axi_generic/template_map.vhd")
    parser.add_argument("--pkgTemplate","-p",help="Template to use for PKG file (not supported yet)",required=False)
    parser.add_argument("--outpath","-o",help="output path to use",required=False,default="autogen")
    parser.add_argument("--xmlpath","-x",help="Path where first xml file is found and its included xml files",required=False,default="")
    parser.add_argument("name",help="base name of decoder xml file (no .xml)")

    args = parser.parse_args()

    build_vhdl_packages(args.simple,
                        args.verbose,
                        args.debug,
                        args.mapTemplate,
                        args.pkgTemplate,
                        args.outpath,
                        args.xmlpath,
                        args.name,
                        args.yaml,
                        args.fallback
                        )
