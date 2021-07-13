import unittest
import shutil
from build_vhdl_packages import useCustomParser, useUhalParser


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
        useCustomParser("addressTable/address_apollo.xml",
                        HDLPath="CParserTest")
        useUhalParser("addressTable/address_apollo.xml", HDLPath="UParserTest")
        self.assertCompareDir("CParserTest", "UParserTest")
        shutil.rmtree("CParserTest")
        shutil.rmtree("UParserTest")


if __name__ == "__main__":
    unittest.main()
