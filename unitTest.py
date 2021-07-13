import unittest
import subprocess
import build_vhdl_packages_parserNode
from generate_vhdl import Generate_VHDL


class UnitTest(unittest.TestCase):
    def assertCompareFile(self, targetFile, sampleFile):
        p = subprocess.Popen(
            ["diff", targetFile, sampleFile], stdout=subprocess.PIPE)
        out = p.communicate()[0].decode("utf-8")
        if len(out) != 0:
            failMsg = '\n' + out
            self.fail(failMsg)
        p.terminate()

    def test_PLXVC(self):
        Generate_VHDL("PLXVC", "addressTable/modules/plXVC.xml", "",
                      None, None, False)
        self.assertCompareFile("PLXVC_map_test.vhd", "PLXVC_map.vhd")
        self.assertCompareFile("PLXVC_PKG_test.vhd", "PLXVC_PKG.vhd")


if __name__ == "__main__":
    unittest.main()
