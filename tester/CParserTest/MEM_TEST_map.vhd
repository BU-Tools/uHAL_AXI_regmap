--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.BRAMPortPkg.all;
use work.MEM_TEST_Ctrl.all;



entity MEM_TEST_map is
  generic (
    READ_TIMEOUT     : integer := 2048;
    ALLOCATED_MEMORY_RANGE : integer
    );
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  MEM_TEST_Mon_t;
    Ctrl             : out MEM_TEST_Ctrl_t
        
    
    Mon              : in  MEM_TEST_Mon_t;
    Ctrl             : out MEM_TEST_Ctrl_t
        
    );
end entity MEM_TEST_map;
architecture behavioral of MEM_TEST_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  constant BRAM_COUNT       : integer := 2;
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := (0 => 8
,			1 => 8);
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := (0 => x"00000100"
,			1 => x"00000400");
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  

  
  constant FIFO_COUNT       : integer := 1;
  constant FIFO_range       : int_array_t(0 to FIFO_COUNT-1) := ();
  constant FIFO_addr        : slv32_array_t(0 to FIFO_COUNT-1) := ();
  signal FIFO_MOSI          : FIFOPortMOSI_array_t(0 to FIFO_COUNT-1);
  signal FIFO_MISO          : FIFOPortMISO_array_t(0 to FIFO_COUNT-1);
  

  signal reg_data :  slv32_array_t(integer range 0 to 1280);
  constant Default_reg_data : slv32_array_t(integer range 0 to 1280) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  assert ((4*1280) <= ALLOCATED_MEMORY_RANGE)
    report "MEM_TEST: Regmap addressing range " & integer'image(4*1280) & " is outside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity ERROR;
  assert ((4*1280) > ALLOCATED_MEMORY_RANGE)
    report "MEM_TEST: Regmap addressing range " & integer'image(4*1280) & " is inside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity NOTE;

  AXIRegBridge : entity work.axiLiteRegBlocking
    generic map (
      READ_TIMEOUT => READ_TIMEOUT
      )
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  -------------------------------------------------------------------------------
  -- Record read decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  latch_reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      localRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      localRdAck <= '0';
      
      if regRdAck = '1' then
        localRdData_latch <= localRdData;
        localRdAck <= '1';
      elsif BRAM_MISO(0).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(0).rd_data;
elsif BRAM_MISO(1).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(1).rd_data;

      elsif FIFO_MISO(0).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= FIFO_MISO(0).rd_data;

      end if;
    end if;
  end process latch_reads;

  
  reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      regRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      regRdAck  <= '0';
      localRdData <= x"00000000";
      if localRdReq = '1' then
        regRdAck  <= '1';
        case to_integer(unsigned(localAddress(10 downto 0))) is
          
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
            regRdAck <= '0';
            localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -------------------------------------------------------------------------------
  -- Record write decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  -- Register mapping to ctrl structures
  Ctrl.THING             <=  reg_data(32)(31 downto  0);      
  Ctrl.LEVEL_TEST.THING  <=  reg_data(768)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(32)(31 downto  0)  <= DEFAULT_MEM_TEST_CTRL_t.THING;
      reg_data(768)(31 downto  0)  <= DEFAULT_MEM_TEST_CTRL_t.LEVEL_TEST.THING;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(10 downto 0))) is
        when 32 => --0x20
          reg_data(32)(31 downto  0)   <=  localWrData(31 downto  0);      --
        when 768 => --0x300
          reg_data(768)(31 downto  0)  <=  localWrData(31 downto  0);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;



  
  -------------------------------------------------------------------------------
  -- BRAM decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  BRAM_reads: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_read: process (clk_axi,reset_axi_n) is
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
--        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
--        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
        if localAddress(10 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(10 downto BRAM_range(iBRAM)) then
--          latchBRAM(iBRAM) <= localRdReq;
--          BRAM_MOSI(iBRAM).enable  <= '1';
          BRAM_MOSI(iBRAM).enable  <= localRdReq;
        end if;
      end if;
    end process BRAM_read;
  end generate BRAM_reads;



  BRAM_asyncs: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_MOSI(iBRAM).clk     <= clk_axi;
    BRAM_MOSI(iBRAM).wr_data <= localWrData;
  end generate BRAM_asyncs;
  
  Ctrl.MEM1.clk       <=  BRAM_MOSI(0).clk;
  Ctrl.MEM1.reset       <=  BRAM_MOSI(0).reset;
  Ctrl.MEM1.enable    <=  BRAM_MOSI(0).enable;
  Ctrl.MEM1.wr_enable <=  BRAM_MOSI(0).wr_enable;
  Ctrl.MEM1.address   <=  BRAM_MOSI(0).address(8-1 downto 0);
  Ctrl.MEM1.wr_data   <=  BRAM_MOSI(0).wr_data(13-1 downto 0);

  Ctrl.LEVEL_TEST.MEM.clk       <=  BRAM_MOSI(1).clk;
  Ctrl.LEVEL_TEST.MEM.reset       <=  BRAM_MOSI(1).reset;
  Ctrl.LEVEL_TEST.MEM.enable    <=  BRAM_MOSI(1).enable;
  Ctrl.LEVEL_TEST.MEM.wr_enable <=  BRAM_MOSI(1).wr_enable;
  Ctrl.LEVEL_TEST.MEM.address   <=  BRAM_MOSI(1).address(8-1 downto 0);
  Ctrl.LEVEL_TEST.MEM.wr_data   <=  BRAM_MOSI(1).wr_data(13-1 downto 0);


  BRAM_MISO(0).rd_data(13-1 downto 0) <= Mon.MEM1.rd_data;
  BRAM_MISO(0).rd_data(31 downto 13) <= (others => '0');
  BRAM_MISO(0).rd_data_valid <= Mon.MEM1.rd_data_valid;

  BRAM_MISO(1).rd_data(13-1 downto 0) <= Mon.LEVEL_TEST.MEM.rd_data;
  BRAM_MISO(1).rd_data(31 downto 13) <= (others => '0');
  BRAM_MISO(1).rd_data_valid <= Mon.LEVEL_TEST.MEM.rd_data_valid;

    

  BRAM_writes: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_write: process (clk_axi,reset_axi_n) is    
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress(10 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(10 downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;
        end if;
      end if;
    end process BRAM_write;
  end generate BRAM_writes;



  
  -------------------------------------------------------------------------------
  -- FIFO decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  FIFO_reads: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_read: process (clk_axi,reset_axi_n) is
    begin  -- process FIFO_reads
      if reset_axi_n = '0' then
        FIFO_MOSI(iFIFO).rd_enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        FIFO_MOSI(iFIFO).rd_enable  <= '0';
        if localAddress(10 downto FIFO_range(iFIFO)) = FIFO_addr(iFIFO)(10 downto FIFO_range(iFIFO)) then
          FIFO_MOSI(iFIFO).rd_enable  <= localRdReq;
        end if;
      end if;
    end process FIFO_read;
  end generate FIFO_reads;



  FIFO_asyncs: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_MOSI(iFIFO).clk     <= clk_axi;
    FIFO_MOSI(iFIFO).wr_data <= localWrData;
  end generate FIFO_asyncs;
  
  Ctrl.FIFO.clk       <=  FIFO_MOSI(0).clk;
  Ctrl.FIFO.reset       <=  FIFO_MOSI(0).reset;
  Ctrl.FIFO.rd_enable    <=  FIFO_MOSI(0).rd_enable;
  Ctrl.FIFO.wr_enable <=  FIFO_MOSI(0).wr_enable;
  Ctrl.FIFO.wr_data   <=  FIFO_MOSI(0).wr_data(13-1 downto 0);


  FIFO_MISO(0).rd_data(13-1 downto 0) <= Mon.FIFO.rd_data;
  FIFO_MISO(0).rd_data(31 downto 13) <= (others => '0');
  FIFO_MISO(0).rd_data_valid <= Mon.FIFO.rd_data_valid;

  FIFO_MISO(0).rd_error <= Mon.FIFO.rd_error;

  FIFO_MISO(0).wr_error <= Mon.FIFO.wr_error;

    

  FIFO_writes: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_write: process (clk_axi,reset_axi_n) is    
    begin  -- process FIFO_reads
      if reset_axi_n = '0' then
        FIFO_MOSI(iFIFO).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        FIFO_MOSI(iFIFO).wr_enable   <= '0';
        if localAddress(10 downto FIFO_range(iFIFO)) = FIFO_addr(iFIFO)(10 downto FIFO_range(iFIFO)) then
          FIFO_MOSI(iFIFO).wr_enable   <= localWrEn;
        end if;
      end if;
    end process FIFO_write;
  end generate FIFO_writes;


  
end architecture behavioral;