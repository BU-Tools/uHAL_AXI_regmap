# uHAL Register Map Tool

This is a python package designed to convert a uHAL-compatible XML address table
into a set of hierarchical VHDL records who structure mirrors the XML address
table itself.

It runs on python2 or python3 and can create either AXI or Wishbone decoders.

### Required packages

```
lxml argparse
```

### Basic Usage

```
build_vhdl_packages.py
    [--simple SIMPLE]
    [--verbose VERBOSE]
    [--debug DEBUG]
    [--mapTemplate MAPTEMPLATE]
    [--pkgTemplate PKGTEMPLATE]
    [--outpath OUTPATH]
    [--xmlpath XMLPATH] name
```

### Examples

#### MEM_TEST.xml

Generate `MEM_TEST_map.vhd` and `MEM_TEST_pkg.vhd` in `./test/simple`
  using the xmlfile `./example_xml/MEM_TEST.xml`
  using the map template file `templates/axi_generic/template_map_withbram.vhd`

- with the simple parser (i.e. no uHAL)

``` sh
./build_vhdl_packages.py -s True -x example_xml/MEM_TEST.xml -o test/simple \
    --mapTemplate templates/axi_generic/template_map_withbram.vhd MEM_TEST
```

- with the normal uHAL parser (working python uHAL must be installed)

``` sh
./build_vhdl_packages.py -x example_xml/MEM_TEST.xml -o test/uHAL/ \
    --mapTemplate templates/axi_generic/template_map_withbram.vhd MEM_TEST
```

#### CM_USP.xml

Generate `CM_USP_map.vhd` and `CM_USP_pkg.vhd` in `./test/simple` using the
  xmlfile `./example_xml/CM_USP.xml` using the map template file
  `templates/axi_generic/template_map_withbram.vhd`

- with the simple parser (i.e. no uHAL)

``` sh
./build_vhdl_packages.py -s True -x example_xml/CM_USP.xml -o test/simple  CM_USP
```

- with the normal uHAL parser (working python uHAL must be installed)

``` sh
./build_vhdl_packages.py -x example_xml/CM_USP.xml -o test/uHAL CM_USP
```
