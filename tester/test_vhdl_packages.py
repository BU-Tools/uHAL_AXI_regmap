import unittest
import subprocess
import shutil

import sys
sys.path.append(r"..")

from build_vhdl_packages import useSimpleParser, useUhalParser


class UnitTest(unittest.TestCase):
    def assertCompareDir(self, dir1, dir2):
        p = subprocess.Popen(["diff", "-r", dir1, dir2],
                             stdout=subprocess.PIPE)
        out = p.communicate()[0].decode("utf-8")
        if len(out) != 0:
            failMsg = '\n' + out
            self.fail(failMsg)
        p.terminate()

    def test_parser(self):
        useSimpleParser(test_xml="../example_xml/MEM_TEST.xml",
                        HDLPath="CParserTest",
                        regMapTemplate="../templates/axi_generic/template_map_withbram.vhd",
                        pkgTemplate="",
                        )
        useUhalParser(test_xml="../example_xml/MEM_TEST.xml",
                      regMapTemplate="../templates/axi_generic/template_map_withbram.vhd",
                      pkgTemplate="",
                      HDLPath="UParserTest")
        self.assertCompareDir("CParserTest", "UParserTest")
        shutil.rmtree("CParserTest")
        shutil.rmtree("UParserTest")


if __name__ == "__main__":
    unittest.main()
