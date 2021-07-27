  constant DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t : MEM_TEST_LEVEL_TEST_CTRL_t := (
                                                                               THING => (others => '0'),
                                                                               MEM => Default_MEM_TEST_LEVEL_TEST_MEM_MOSI_t
                                                                              );
  constant DEFAULT_MEM_TEST_CTRL_t : MEM_TEST_CTRL_t := (
                                                         THING => (others => '0'),
                                                         MEM1 => Default_MEM_TEST_MEM1_MOSI_t,
                                                         LEVEL_TEST => DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t
                                                        );
