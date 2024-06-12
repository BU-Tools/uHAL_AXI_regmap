--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package MEM_TEST_CTRL is
  type MEM_TEST_BUILD_DATE_MON_t is record
    DAY                        :std_logic_vector( 7 downto 0);
    MONTH                      :std_logic_vector( 7 downto 0);
    YEAR                       :std_logic_vector(15 downto 0);
  end record MEM_TEST_BUILD_DATE_MON_t;


  type MEM_TEST_BUILD_TIME_MON_t is record
    SEC                        :std_logic_vector( 7 downto 0);
    MIN                        :std_logic_vector( 7 downto 0);
    HOUR                       :std_logic_vector( 7 downto 0);
  end record MEM_TEST_BUILD_TIME_MON_t;


  type MEM_TEST_FPGA_MON_t is record
    WORD_00                    :std_logic_vector(31 downto 0);
    WORD_01                    :std_logic_vector(31 downto 0);
    WORD_02                    :std_logic_vector(31 downto 0);
    WORD_03                    :std_logic_vector(31 downto 0);
    WORD_04                    :std_logic_vector(31 downto 0);
    WORD_05                    :std_logic_vector(31 downto 0);
    WORD_06                    :std_logic_vector(31 downto 0);
    WORD_07                    :std_logic_vector(31 downto 0);
    WORD_08                    :std_logic_vector(31 downto 0);
  end record MEM_TEST_FPGA_MON_t;


  type MEM_TEST_MEM1_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(8-1 downto 0);
    wr_data   : std_logic_vector(13-1 downto 0);
  end record MEM_TEST_MEM1_MOSI_t;
  type MEM_TEST_MEM1_MISO_t is record
    rd_data         : std_logic_vector(13-1 downto 0);
    rd_data_valid   : std_logic;
  end record MEM_TEST_MEM1_MISO_t;
  constant Default_MEM_TEST_MEM1_MOSI_t : MEM_TEST_MEM1_MOSI_t := ( 
                                                     clk       => '0',
                                                     reset     => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type MEM_TEST_LEVEL_TEST_MEM_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(8-1 downto 0);
    wr_data   : std_logic_vector(13-1 downto 0);
  end record MEM_TEST_LEVEL_TEST_MEM_MOSI_t;
  type MEM_TEST_LEVEL_TEST_MEM_MISO_t is record
    rd_data         : std_logic_vector(13-1 downto 0);
    rd_data_valid   : std_logic;
  end record MEM_TEST_LEVEL_TEST_MEM_MISO_t;
  constant Default_MEM_TEST_LEVEL_TEST_MEM_MOSI_t : MEM_TEST_LEVEL_TEST_MEM_MOSI_t := ( 
                                                     clk       => '0',
                                                     reset     => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type MEM_TEST_LEVEL_TEST_MON_t is record
    MEM                        :MEM_TEST_LEVEL_TEST_MEM_MISO_t;
  end record MEM_TEST_LEVEL_TEST_MON_t;


  type MEM_TEST_LEVEL_TEST_CTRL_t is record
    THING                      :std_logic_vector(31 downto 0);
    MEM                        :MEM_TEST_LEVEL_TEST_MEM_MOSI_t;
  end record MEM_TEST_LEVEL_TEST_CTRL_t;


  constant DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t : MEM_TEST_LEVEL_TEST_CTRL_t := (
                                                                               THING => (others => '0'),
                                                                               MEM => Default_MEM_TEST_LEVEL_TEST_MEM_MOSI_t
                                                                              );
  type MEM_TEST_FIFO_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    rd_enable : std_logic;
    wr_enable : std_logic;
    wr_data   : std_logic_vector(13-1 downto 0);
  end record MEM_TEST_FIFO_MOSI_t;
  type MEM_TEST_FIFO_MISO_t is record
    rd_data         : std_logic_vector(13-1 downto 0);
    rd_data_valid   : std_logic;
    rd_error        : std_logic;
    wr_error        : std_logic;
  end record MEM_TEST_FIFO_MISO_t;
  constant Default_MEM_TEST_FIFO_MOSI_t : MEM_TEST_FIFO_MOSI_t := ( 
                                                     clk       => '0',
                                                     reset     => '0',
                                                     rd_enable => '0',
                                                     wr_enable => '0',
                                                     wr_data   => (others => '0')
  );
  type MEM_TEST_MON_t is record
    GIT_VALID                  :std_logic;   
    GIT_HASH_1                 :std_logic_vector(31 downto 0);
    GIT_HASH_2                 :std_logic_vector(31 downto 0);
    GIT_HASH_3                 :std_logic_vector(31 downto 0);
    GIT_HASH_4                 :std_logic_vector(31 downto 0);
    GIT_HASH_5                 :std_logic_vector(31 downto 0);
    BUILD_DATE                 :MEM_TEST_BUILD_DATE_MON_t;    
    BUILD_TIME                 :MEM_TEST_BUILD_TIME_MON_t;    
    FPGA                       :MEM_TEST_FPGA_MON_t;          
    MEM1                       :MEM_TEST_MEM1_MISO_t;         
    LEVEL_TEST                 :MEM_TEST_LEVEL_TEST_MON_t;    
    FIFO                       :MEM_TEST_FIFO_MISO_t;         
  end record MEM_TEST_MON_t;


  type MEM_TEST_CTRL_t is record
    THING                      :std_logic_vector(31 downto 0);
    MEM1                       :MEM_TEST_MEM1_MOSI_t;         
    LEVEL_TEST                 :MEM_TEST_LEVEL_TEST_CTRL_t;   
    FIFO                       :MEM_TEST_FIFO_MOSI_t;         
  end record MEM_TEST_CTRL_t;


  constant DEFAULT_MEM_TEST_CTRL_t : MEM_TEST_CTRL_t := (
                                                         THING => (others => '0'),
                                                         MEM1 => Default_MEM_TEST_MEM1_MOSI_t,
                                                         LEVEL_TEST => DEFAULT_MEM_TEST_LEVEL_TEST_CTRL_t,
                                                         FIFO => Default_MEM_TEST_FIFO_MOSI_t
                                                        );


end package MEM_TEST_CTRL;