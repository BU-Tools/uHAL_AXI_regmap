#################################################################################                                                                                                             
## Force python3                                                                                                                                                                              
#################################################################################                                                                                                             
import sys                                                                                                                                                                                    
if not sys.version_info.major == 3:                                                                                                                                                           
    raise BaseException("Wrong Python version detected.  Please ensure that you are using Python 3.")                                                                                         
#################################################################################              

""""""
import unittest
import subprocess
import time
import os
import sys
import generate_test_xml
import tempfile
sys.path.append(r"..")

from build_vhdl_packages import parse_xml

class UnitTest(unittest.TestCase):
    """Unit test class for """

    def assert_compare_dir(self, dir1, dir2):
        """Assert that two directories are identical"""
        process = subprocess.Popen(["diff", "-r", dir1, dir2],
                                   stdout=subprocess.PIPE)
        out = process.communicate()[0].decode("utf-8")
        if len(out) != 0:
            fail_msg = '\n' + out
            self.fail(fail_msg)
        process.terminate()

    def assert_git_no_diff(self, dirname):
        """Assert that a given directory does not have any changes relative to
        what is committed in Git"""
        process = subprocess.Popen(["git", "diff", dirname],
                                   stdout=subprocess.PIPE)
        out = process.communicate()[0].decode("utf-8")
        if len(out) != 0:
            fail_msg = '\n' + out
            self.fail(fail_msg)
        process.terminate()

    def test_parser(self):
        """Test the parser and XML to VHDL generation"""

        for xml in ["CM_USP", "MEM_TEST"]:

            # Generate a dummy top level ipbus XML file for the parser
            (fd, test_xml_name) = tempfile.mkstemp()
            test_xml_name = test_xml_name + ".xml"

            try:

                xml_path = "../example_xml/" + xml + ".xml"
                generate_test_xml.generate_test_xml(xml, 0x0,
                                                    os.path.abspath(xml_path),
                                                    test_xml_name)

                wishbone = "../templates/wishbone/template_map.vhd"
                axi = "../templates/axi_generic/template_map_withbram.vhd"

                tests = [{"path": "CParserTest",          "parser": "simple", "template": axi},
                         {"path": "UParserTest",          "parser": "uhal",   "template": axi},
                         {"path": "CParserTest_wishbone", "parser": "simple", "template": wishbone},
                         {"path": "UParserTest_wishbone", "parser": "simple", "template": wishbone}
                         ]

                # Generate the VHDL Outputs
                for test in tests:
                    for yml2hdl in [True, False]:

                        print("Tester:: %s (testxml=%s) with %s parser to %s" %
                            (xml, test_xml_name, test["parser"], test["path"]))

                        parse_xml(test_xml=test_xml_name, HDLPath=test["path"],
                                parser=test["parser"],
                                regMapTemplate=test["template"],
                                yml2hdl=yml2hdl)
            finally:
                os.remove(test_xml_name)

        # Check that they are equal
        self.assert_compare_dir(tests[0]["path"], tests[1]["path"])
        self.assert_compare_dir(tests[2]["path"], tests[3]["path"])

        # Check that there is no Git diff
        for test in tests:
            self.assert_git_no_diff(test["path"])


if __name__ == "__main__":
    unittest.main()
