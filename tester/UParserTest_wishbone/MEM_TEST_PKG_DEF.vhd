--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;
library ctrl_lib;
use ctrl_lib.MEM_TEST_CTRL.all;


package MEM_TEST_CTRL_DEF is
  constant DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t : MEM_TEST_LEVEL_TEST_CTRL_t := (
                                                                               THING => (others => '0'),
                                                                               MEM => Default_MEM_TEST_LEVEL_TEST_MEM_MOSI_t
                                                                              );
  constant DEFAULT_MEM_TEST_CTRL_t : MEM_TEST_CTRL_t := (
                                                         THING => (others => '0'),
                                                         MEM1 => Default_MEM_TEST_MEM1_MOSI_t,
                                                         LEVEL_TEST => DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t,
                                                         FIFO => Default_MEM_TEST_FIFO_MOSI_t
                                                        );

end package MEM_TEST_CTRL_DEF;
