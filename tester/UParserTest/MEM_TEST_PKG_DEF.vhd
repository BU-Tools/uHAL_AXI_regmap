--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;
library ctrl_lib;
use ctrl_lib.MEM_TEST.all;
library shared_lib;
use shared_lib.common_ieee.all;


package MEM_TEST_DEF is
  constant DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t : MEM_TEST_LEVEL_TEST_CTRL_t := (
                                                                               THING => (others => '0'),
                                                                               MEM => Default_MEM_TEST_LEVEL_TEST_MEM_MOSI_t
                                                                              );
  constant DEFAULT_MEM_TEST_CTRL_t : MEM_TEST_CTRL_t := (
                                                         THING => (others => '0'),
                                                         MEM1 => Default_MEM_TEST_MEM1_MOSI_t,
                                                         LEVEL_TEST => DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t
                                                        );

end package;
