--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MEM_TEST_Ctrl.all;
entity MEM_TEST_wb_map is
  port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    wb_addr     : in  std_logic_vector(31 downto 0);
    wb_wdata    : in  std_logic_vector(31 downto 0);
    wb_strobe   : in  std_logic;
    wb_write    : in  std_logic;
    wb_rdata    : out std_logic_vector(31 downto 0);
    wb_ack      : out std_logic;
    wb_err      : out std_logic;
    mon         : in  MEM_TEST_Mon_t;
    ctrl        : out MEM_TEST_Ctrl_t
    );
end entity MEM_TEST_wb_map;
architecture behavioral of MEM_TEST_wb_map is
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  signal localRdData : std_logic_vector (31 downto 0) := (others => '0');
  signal localWrData : std_logic_vector (31 downto 0) := (others => '0');
  signal reg_data :  slv32_array_t(integer range 0 to 1280);
  constant DEFAULT_REG_DATA : slv32_array_t(integer range 0 to 1280) := (others => x"00000000");
begin  -- architecture behavioral

  wb_rdata <= localRdData;
  localWrData <= wb_wdata;

  -- acknowledge
  process (clk) is
  begin
    if (rising_edge(clk)) then
      if (reset='1') then
        wb_ack  <= '0';
      else
        wb_ack  <= wb_strobe;
      end if;
    end if;
  end process;

  -- reads from slave
  reads: process (clk) is
  begin  -- process reads
    if rising_edge(clk) then  -- rising clock edge
      localRdData <= x"00000000";
      if wb_strobe='1' then
        case to_integer(unsigned(wb_addr(10 downto 0))) is
          when 0 => --0x0
          localRdData( 1)            <=  Mon.GIT_VALID;                    --
        when 1 => --0x1
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_1;                   --
        when 2 => --0x2
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_2;                   --
        when 3 => --0x3
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_3;                   --
        when 4 => --0x4
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_4;                   --
        when 5 => --0x5
          localRdData(31 downto  0)  <=  Mon.GIT_HASH_5;                   --
        when 16 => --0x10
          localRdData( 7 downto  0)  <=  Mon.BUILD_DATE.DAY;               --
          localRdData(15 downto  8)  <=  Mon.BUILD_DATE.MONTH;             --
          localRdData(31 downto 16)  <=  Mon.BUILD_DATE.YEAR;              --
        when 17 => --0x11
          localRdData( 7 downto  0)  <=  Mon.BUILD_TIME.SEC;               --
          localRdData(15 downto  8)  <=  Mon.BUILD_TIME.MIN;               --
          localRdData(23 downto 16)  <=  Mon.BUILD_TIME.HOUR;              --
        when 18 => --0x12
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_00;                 --
        when 19 => --0x13
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_01;                 --
        when 20 => --0x14
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_02;                 --
        when 21 => --0x15
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_03;                 --
        when 22 => --0x16
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_04;                 --
        when 23 => --0x17
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_05;                 --
        when 24 => --0x18
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_06;                 --
        when 25 => --0x19
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_07;                 --
        when 26 => --0x1a
          localRdData(31 downto  0)  <=  Mon.FPGA.WORD_08;                 --
        when 32 => --0x20
          localRdData(31 downto  0)  <=  reg_data(32)(31 downto  0);       --
        when 768 => --0x300
          localRdData(31 downto  0)  <=  reg_data(768)(31 downto  0);      --

        when others =>
          localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -- Register mapping to ctrl structures
  Ctrl.THING             <=  reg_data(32)(31 downto  0);      
  Ctrl.LEVEL_TEST.THING  <=  reg_data(768)(31 downto  0);     


  -- writes to slave
  reg_writes: process (clk) is
  begin  -- process reg_writes
    if (rising_edge(clk)) then  -- rising clock edge

      -- Write on strobe=write=1
      if wb_strobe='1' and wb_write = '1' then
        case to_integer(unsigned(wb_addr(10 downto 0))) is
        when 32 => --0x20
          reg_data(32)(31 downto  0)   <=  localWrData(31 downto  0);      --
        when 768 => --0x300
          reg_data(768)(31 downto  0)  <=  localWrData(31 downto  0);      --

        when others => null;

        end case;
      end if; -- write

      -- synchronous reset (active high)
      if reset = '1' then
      reg_data(32)(31 downto  0)  <= DEFAULT_MEM_TEST_CTRL_t.THING;
      reg_data(768)(31 downto  0)  <= DEFAULT_MEM_TEST_CTRL_t.LEVEL_TEST.THING;

      

      

      end if; -- reset
    end if; -- clk
  end process reg_writes;


end architecture behavioral;