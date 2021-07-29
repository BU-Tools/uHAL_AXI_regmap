# import unittest
import subprocess
import shutil
import argparse

# import build_vhdl_packages

# import sys
# sys.path.append("../")
# import build_vhdl_packages

# from .. import build_vhdl_packages

# from uHAL_AXI_regmap.build_vhdl_packages import useCustomParser, useUhalParser
# import uHAL_AXI_regmap.build_vhdl_packages


def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate VHDL decoder from XML address table")
    parser.add_argument("--verbose","-v",type=str2bool,help="Turn on verbose output",required=False,default=False)
    parser.add_argument("--debug","-d",type=str2bool,help="Turn on debugging info",required=False,default=False)
    parser.add_argument("--mapTemplate","-m",help="Template to use for decoder map file",required=False,default="templates/axi_generic/template_map.vhd")
    parser.add_argument("--pkgTemplate","-p",help="Template to use for PKG file (not supported yet)",required=False)
    parser.add_argument("--outpath","-o",help="output path to use",required=False,default="autogen")
    parser.add_argument("--xmlpath","-x",help="Path where first xml file is found and its included xml files",required=False,default="")
    parser.add_argument("name",help="base name of decoder xml file (no .xml)")

    args=parser.parse_args()
    build_vhdl_packages.build_vhdl_packages(False,
                        args.verbose,
                        args.debug,
                        args.mapTemplate,
                        args.pkgTemplate,
                        args.outpath + "_uhal",
                        args.xmlpath,
                        args.name)
    build_vhdl_packages.build_vhdl_packages(True,
                        args.verbose,
                        args.debug,
                        args.mapTemplate,
                        args.pkgTemplate,
                        args.outpath + "_simple",
                        args.xmlpath,
                        args.name)

    p = subprocess.Popen(["diff", "-r", args.outpath + "_uhal", args.outpath + "_simple"],
                        stdout=subprocess.PIPE)
    out = p.communicate()[0].decode("utf-8")
    if len(out) != 0:
        print(out)
    else:
        print("test past!")

    shutil.rmtree("CParserTest")
    shutil.rmtree("UParserTest")


