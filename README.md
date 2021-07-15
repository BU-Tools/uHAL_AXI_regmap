required package:
lxml
argparse

usage:
python new_parser.py -ifs path_to_entry_file.xml


Examples:

Generate MEM_TEST_map.vhd and MEM_TEST_pkg.vhd in ./test/simple 
  using the xmlfiles in ./exmple_xml with top file as MEM_TEST
  using the map template file templates/axi_generic/template_map_withbram.vhd
  with the simple parser (i.e. no uHAL)
  
./build_vhdl_packages.py -s False -x example_xml/ -o test/simple --mapTemplate templates/axi_generic/template_map_withbram.vhd MEM_TEST

Generate MEM_TEST_map.vhd and MEM_TEST_pkg.vhd in ./test/uHAL
  using the xmlfiles in ./exmple_xml with top file as MEM_TEST
  using the map template file templates/axi_generic/template_map_withbram.vhd
  with the normal uHAL parser (working python uHAL must be installed)
  
./build_vhdl_packages.py -x example_xml/ -o test/uHAL --mapTemplate templates/axi_generic/template_map_withbram.vhd MEM_TEST



Generate CM_USP_map.vhd and CM_USP_pkg.vhd in ./test/simple 
  using the xmlfiles in ./exmple_xml with top file as CM_USP
  using the map template file templates/axi_generic/template_map_withbram.vhd
  with the simple parser (i.e. no uHAL)
  
./build_vhdl_packages.py -s False -x example_xml/ -o test/simple  CM_USP

Generate CM_USP_map.vhd and CM_USP_pkg.vhd in ./test/uHAL
  using the xmlfiles in ./exmple_xml with top file as CM_USP
  using the map template file templates/axi_generic/template_map_withbram.vhd
  with the normal uHAL parser (working python uHAL must be installed)
  
./build_vhdl_packages.py -x example_xml/ -o test/uHAL CM_USP
