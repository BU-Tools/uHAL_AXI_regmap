import unittest
import subprocess
import shutil
import time
import generate_test_xml
import os

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

    def assertGitNoDiff(self, dirname):
        p = subprocess.Popen(["git", "diff", dirname], stdout=subprocess.PIPE)
        out = p.communicate()[0].decode("utf-8")
        if len(out) != 0:
            failMsg = '\n' + out
            self.fail(failMsg)
        p.terminate()

    def test_parser(self):

        test_xml="test_"+str(int(time.time()))+".xml"
        xmlpath = "../example_xml/MEM_TEST.xml"
        generate_test_xml.generate_test_xml("MEM_TEST", 0x0, os.path.abspath(xmlpath), test_xml)
        regMapTemplate="../templates/axi_generic/template_map_withbram.vhd"

        useSimpleParser(test_xml=test_xml, HDLPath="CParserTest", regMapTemplate=regMapTemplate)
        useUhalParser(test_xml=test_xml, HDLPath="UParserTest", regMapTemplate=regMapTemplate)

        self.assertCompareDir("CParserTest", "UParserTest")
        for i in ["CParserTest", "UParserTest"]:
            self.assertGitNoDiff(i)

        os.remove(test_xml)
        #shutil.rmtree("CParserTest")
        #shutil.rmtree("UParserTest")


if __name__ == "__main__":
    unittest.main()
