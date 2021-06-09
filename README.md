
Standalone example using the example_xml directory:
This requires uhal installed (usually in /opt/cactus/lib)

git submodule update --init --recursive 
cd example_xml
../generate_test_xml CM_USP
LD_LIBRARY_PATH=/opt/cactus/lib/ ../build_vhdl_packages test.xml templates/axi_generic/template_map.vhd

Now you should have CM_USP_map.vhd and CM_USP_PKG.vhd
