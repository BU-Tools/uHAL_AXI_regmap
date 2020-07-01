#################################################################################
# Generate MAP and PKG files from address table
#################################################################################
export LD_LIBRARY_PATH=/opt/cactus/lib
XML2VHD_PATH=$(shell pwd)
SYM_LNK_XMLS=$(shell find ../ -type l -name "*.xml")
include xml_regmap.mk
.DEFAULT_GOAL := xml_regmap
clean: clean_regmap
