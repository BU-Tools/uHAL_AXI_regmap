#################################################################################
# Generate MAP and PKG files from address table
#################################################################################
export LD_LIBRARY_PATH=/opt/cactus/lib
SRC_PATH=src
XML2VHD_PATH=xml_regmap

SYM_LNK_XMLS = $(shell find . -type l)
MAP_OBJS = $(patsubst %.xml, %_map.vhd, $(SYM_LNK_XMLS))
PKG_OBJS = $(patsubst %.xml, %_PKG.vhd, $(SYM_LNK_XMLS))

.PHONY: xml_regmap clean_regmap

clean_regmap:
	@rm -rf $(MAP_OBJS) $(PKG_OBJS)

xml_regmap : $(MAP_OBJS)
# need to extract dir name and path name here

%_map.vhd %_PKG.vhd : %.xml
	@cd $(dir $<) &&\
	../../$(XML2VHD_PATH)/generate_test_xml $(basename $(notdir $<)) &&\
	../../$(XML2VHD_PATH)/build_vhdl_packages test.xml &&\
	rm test.xml

