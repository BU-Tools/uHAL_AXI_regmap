import unittest
import subprocess
import build_vhdl_packages_parserNode
from generate_vhdl import Generate_VHDL


class UnitTest(unittest.TestCase):
    def assertCompareFile(self, targetFile, sampleFile):
        out = ''
        p = subprocess.Popen(
            ["diff", targetFile, sampleFile], stdout=subprocess.PIPE)
        out = p.communicate()[0].decode("utf-8")
        if len(out) != 0:
            failMsg = '\n' + out
            self.fail(failMsg)
        p.terminate()

    def assertCompareDir(self, dir1, dir2):
        out = ''
        with subprocess.Popen(["diff", "-r", dir1, dir2], stdout=subprocess.PIPE) as p:
            out = p.communicate()[0].decode("utf-8")

        if len(out) != 0:
            failMsg = '\n' + out
            self.fail(failMsg)

    def test_PLXVC(self):
        Generate_VHDL("PLXVC", "addressTable/modules/plXVC.xml", "",
                      None, None, False)
        self.assertCompareFile("PLXVC_map_test.vhd", "PLXVC_map.vhd")
        self.assertCompareFile("PLXVC_PKG_test.vhd", "PLXVC_PKG.vhd")


if __name__ == "__main__":
    unittest.main()
