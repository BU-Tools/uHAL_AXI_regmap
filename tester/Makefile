test: clean_simple clean_uhal
	python generate_test_xml.py
	python test_vhdl_packages.py

test_simple_parser:  clean_simple
	python generate_test_xml.py
	python test_vhdl_packages.py simple

test_uhal_parser:  clean_uhal
	python generate_test_xml.py
	python test_vhdl_packages.py uhal

clean_simple:
	rm -rf CParserTest  CParserTest_wishbone

clean_uhal:
	rm -rf UParserTest UParserTest_wishbone
