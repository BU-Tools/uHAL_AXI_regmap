--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;

use work.CM_USP_Ctrl.all;

entity CM_USP_map is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  CM_USP_Mon_t;
    Ctrl             : out CM_USP_Ctrl_t
        
    );
end entity CM_USP_map;
architecture behavioral of CM_USP_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  
  signal reg_data :  slv32_array_t(integer range 0 to 346);
  constant Default_reg_data : slv32_array_t(integer range 0 to 346) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteRegBlocking
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
        case to_integer(unsigned(localAddress(8 downto 0))) is
          
        when 0 => --0x0
          localRdData( 0)            <=  reg_data( 0)( 0);                                    --Tell CM uC to power-up
          localRdData( 1)            <=  reg_data( 0)( 1);                                    --Tell CM uC to power-up the rest of the CM
          localRdData( 2)            <=  reg_data( 0)( 2);                                    --Ignore power good from CM
          localRdData( 3)            <=  Mon.CM(1).CTRL.PWR_GOOD;                             --CM power is good
          localRdData( 7 downto  4)  <=  Mon.CM(1).CTRL.STATE;                                --CM power up state
          localRdData( 8)            <=  reg_data( 0)( 8);                                    --CM power is good
          localRdData( 9)            <=  Mon.CM(1).CTRL.PWR_ENABLED;                          --power is enabled
          localRdData(10)            <=  Mon.CM(1).CTRL.IOS_ENABLED;                          --IOs to CM are enabled
        when 16 => --0x10
          localRdData(11)            <=  reg_data(16)(11);                                    --phy_lane_control is enabled
        when 17 => --0x11
          localRdData(31 downto  0)  <=  reg_data(17)(31 downto  0);                          --Contious phy_lane_up signals required to lock phylane control
        when 18 => --0x12
          localRdData(23 downto  0)  <=  reg_data(18)(23 downto  0);                          --Time spent waiting for phylane to stabilize
        when 20 => --0x14
          localRdData( 0)            <=  Mon.CM(1).C2C(1).STATUS.CONFIG_ERROR;                --C2C config error
          localRdData( 1)            <=  Mon.CM(1).C2C(1).STATUS.LINK_ERROR;                  --C2C link error
          localRdData( 2)            <=  Mon.CM(1).C2C(1).STATUS.LINK_GOOD;                   --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(1).C2C(1).STATUS.MB_ERROR;                    --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(1).C2C(1).STATUS.DO_CC;                       --Aurora do CC
          localRdData( 5)            <=  reg_data(20)( 5);                                    --C2C initialize
          localRdData( 8)            <=  Mon.CM(1).C2C(1).STATUS.PHY_RESET;                   --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(1).C2C(1).STATUS.PHY_GT_PLL_LOCK;             --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(1).C2C(1).STATUS.PHY_MMCM_LOL;                --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(1).C2C(1).STATUS.PHY_LANE_UP;                 --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(1).C2C(1).STATUS.PHY_HARD_ERR;                --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(1).C2C(1).STATUS.PHY_SOFT_ERR;                --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(1).C2C(1).STATUS.LINK_IN_FW;                  --FW includes this link
        when 21 => --0x15
          localRdData(15 downto  0)  <=  Mon.CM(1).C2C(1).LINK_DEBUG.DMONITOR;                --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(1).C2C(1).LINK_DEBUG.QPLL_LOCK;               --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(1).C2C(1).LINK_DEBUG.CPLL_LOCK;               --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(1).C2C(1).LINK_DEBUG.EYESCAN_DATA_ERROR;      --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(21)(22);                                    --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(21)(23);                                    --DEBUG eyescan trigger
        when 22 => --0x16
          localRdData(15 downto  0)  <=  reg_data(22)(15 downto  0);                          --bit 2 is DRP uber reset
        when 23 => --0x17
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(1).LINK_DEBUG.RX.BUF_STATUS;           --DEBUG rx buf status
          localRdData(10)            <=  Mon.CM(1).C2C(1).LINK_DEBUG.RX.PRBS_ERR;             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(1).C2C(1).LINK_DEBUG.RX.RESET_DONE;           --DEBUG rx reset done
          localRdData(12)            <=  reg_data(23)(12);                                    --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(23)(13);                                    --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(23)(17);                                    --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(23)(18);                                    --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(23)(23);                                    --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(23)(24);                                    --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(23)(25);                                    --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(23)(29 downto 26);                          --DEBUG rx PRBS select
        when 24 => --0x18
          localRdData( 2 downto  0)  <=  reg_data(24)( 2 downto  0);                          --DEBUG rx rate
        when 25 => --0x19
          localRdData( 1 downto  0)  <=  Mon.CM(1).C2C(1).LINK_DEBUG.TX.BUF_STATUS;           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(1).C2C(1).LINK_DEBUG.TX.RESET_DONE;           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(25)( 7);                                    --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(25)(15);                                    --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(25)(16);                                    --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(25)(17);                                    --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(25)(22 downto 18);                          --DEBUG post cursor
          localRdData(23)            <=  reg_data(25)(23);                                    --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(25)(31 downto 27);                          --DEBUG pre cursor
        when 26 => --0x1a
          localRdData( 3 downto  0)  <=  reg_data(26)( 3 downto  0);                          --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(26)( 8 downto  4);                          --DEBUG tx diff control
        when 32 => --0x20
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.INIT_ALLTIME;                   --Counter for every PHYLANEUP cycle
        when 33 => --0x21
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.INIT_SHORTTERM;                 --Counter for PHYLANEUP cycles since lase C2C INITIALIZE
        when 34 => --0x22
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.CONFIG_ERROR_COUNT;             --Counter for CONFIG_ERROR
        when 35 => --0x23
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.LINK_ERROR_COUNT;               --Counter for LINK_ERROR
        when 36 => --0x24
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.MB_ERROR_COUNT;                 --Counter for MB_ERROR
        when 37 => --0x25
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.PHY_HARD_ERROR_COUNT;           --Counter for PHY_HARD_ERROR
        when 38 => --0x26
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.PHY_SOFT_ERROR_COUNT;           --Counter for PHY_SOFT_ERROR
        when 39 => --0x27
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(1).CNT.PHYLANE_STATE;                  --Current state of phy_lane_control module
        when 41 => --0x29
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.PHY_ERRORSTATE_COUNT;           --Count for phylane in error state
        when 42 => --0x2a
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(1).CNT.USER_CLK_FREQ;                  --Frequency of the user C2C clk
        when 48 => --0x30
          localRdData(11)            <=  reg_data(48)(11);                                    --phy_lane_control is enabled
        when 49 => --0x31
          localRdData(31 downto  0)  <=  reg_data(49)(31 downto  0);                          --Contious phy_lane_up signals required to lock phylane control
        when 50 => --0x32
          localRdData(23 downto  0)  <=  reg_data(50)(23 downto  0);                          --Time spent waiting for phylane to stabilize
        when 52 => --0x34
          localRdData( 0)            <=  Mon.CM(1).C2C(2).STATUS.CONFIG_ERROR;                --C2C config error
          localRdData( 1)            <=  Mon.CM(1).C2C(2).STATUS.LINK_ERROR;                  --C2C link error
          localRdData( 2)            <=  Mon.CM(1).C2C(2).STATUS.LINK_GOOD;                   --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(1).C2C(2).STATUS.MB_ERROR;                    --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(1).C2C(2).STATUS.DO_CC;                       --Aurora do CC
          localRdData( 5)            <=  reg_data(52)( 5);                                    --C2C initialize
          localRdData( 8)            <=  Mon.CM(1).C2C(2).STATUS.PHY_RESET;                   --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(1).C2C(2).STATUS.PHY_GT_PLL_LOCK;             --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(1).C2C(2).STATUS.PHY_MMCM_LOL;                --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(1).C2C(2).STATUS.PHY_LANE_UP;                 --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(1).C2C(2).STATUS.PHY_HARD_ERR;                --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(1).C2C(2).STATUS.PHY_SOFT_ERR;                --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(1).C2C(2).STATUS.LINK_IN_FW;                  --FW includes this link
        when 53 => --0x35
          localRdData(15 downto  0)  <=  Mon.CM(1).C2C(2).LINK_DEBUG.DMONITOR;                --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(1).C2C(2).LINK_DEBUG.QPLL_LOCK;               --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(1).C2C(2).LINK_DEBUG.CPLL_LOCK;               --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(1).C2C(2).LINK_DEBUG.EYESCAN_DATA_ERROR;      --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(53)(22);                                    --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(53)(23);                                    --DEBUG eyescan trigger
        when 54 => --0x36
          localRdData(15 downto  0)  <=  reg_data(54)(15 downto  0);                          --bit 2 is DRP uber reset
        when 55 => --0x37
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(2).LINK_DEBUG.RX.BUF_STATUS;           --DEBUG rx buf status
          localRdData(10)            <=  Mon.CM(1).C2C(2).LINK_DEBUG.RX.PRBS_ERR;             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(1).C2C(2).LINK_DEBUG.RX.RESET_DONE;           --DEBUG rx reset done
          localRdData(12)            <=  reg_data(55)(12);                                    --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(55)(13);                                    --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(55)(17);                                    --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(55)(18);                                    --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(55)(23);                                    --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(55)(24);                                    --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(55)(25);                                    --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(55)(29 downto 26);                          --DEBUG rx PRBS select
        when 56 => --0x38
          localRdData( 2 downto  0)  <=  reg_data(56)( 2 downto  0);                          --DEBUG rx rate
        when 57 => --0x39
          localRdData( 1 downto  0)  <=  Mon.CM(1).C2C(2).LINK_DEBUG.TX.BUF_STATUS;           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(1).C2C(2).LINK_DEBUG.TX.RESET_DONE;           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(57)( 7);                                    --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(57)(15);                                    --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(57)(16);                                    --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(57)(17);                                    --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(57)(22 downto 18);                          --DEBUG post cursor
          localRdData(23)            <=  reg_data(57)(23);                                    --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(57)(31 downto 27);                          --DEBUG pre cursor
        when 58 => --0x3a
          localRdData( 3 downto  0)  <=  reg_data(58)( 3 downto  0);                          --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(58)( 8 downto  4);                          --DEBUG tx diff control
        when 64 => --0x40
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.INIT_ALLTIME;                   --Counter for every PHYLANEUP cycle
        when 65 => --0x41
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.INIT_SHORTTERM;                 --Counter for PHYLANEUP cycles since lase C2C INITIALIZE
        when 66 => --0x42
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.CONFIG_ERROR_COUNT;             --Counter for CONFIG_ERROR
        when 67 => --0x43
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.LINK_ERROR_COUNT;               --Counter for LINK_ERROR
        when 68 => --0x44
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.MB_ERROR_COUNT;                 --Counter for MB_ERROR
        when 69 => --0x45
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.PHY_HARD_ERROR_COUNT;           --Counter for PHY_HARD_ERROR
        when 70 => --0x46
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.PHY_SOFT_ERROR_COUNT;           --Counter for PHY_SOFT_ERROR
        when 71 => --0x47
          localRdData( 2 downto  0)  <=  Mon.CM(1).C2C(2).CNT.PHYLANE_STATE;                  --Current state of phy_lane_control module
        when 73 => --0x49
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.PHY_ERRORSTATE_COUNT;           --Count for phylane in error state
        when 74 => --0x4a
          localRdData(31 downto  0)  <=  Mon.CM(1).C2C(2).CNT.USER_CLK_FREQ;                  --Frequency of the user C2C clk
        when 80 => --0x50
          localRdData( 7 downto  0)  <=  reg_data(80)( 7 downto  0);                          --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          localRdData( 8)            <=  Mon.CM(1).MONITOR.ACTIVE;                            --Monitoring active. Is zero when no update in the last second.
          localRdData(15 downto 12)  <=  Mon.CM(1).MONITOR.HISTORY_VALID;                     --bytes valid in debug history
        when 81 => --0x51
          localRdData(31 downto  0)  <=  Mon.CM(1).MONITOR.HISTORY;                           --4 bytes of uart history
        when 82 => --0x52
          localRdData( 7 downto  0)  <=  Mon.CM(1).MONITOR.BAD_TRANS.ADDR;                    --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(1).MONITOR.BAD_TRANS.DATA;                    --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(1).MONITOR.BAD_TRANS.ERROR_MASK;              --Sensor error bits
        when 83 => --0x53
          localRdData( 7 downto  0)  <=  Mon.CM(1).MONITOR.LAST_TRANS.ADDR;                   --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(1).MONITOR.LAST_TRANS.DATA;                   --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(1).MONITOR.LAST_TRANS.ERROR_MASK;             --Sensor error bits
        when 84 => --0x54
          localRdData( 0)            <=  reg_data(84)( 0);                                    --Reset monitoring error counters
        when 85 => --0x55
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BAD_SOF;                --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2;         --Monitoring errors. Count of invalid byte types in parsing.
        when 86 => --0x56
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA;         --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA;         --Monitoring errors. Count of invalid byte types in parsing.
        when 87 => --0x57
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA;         --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_TIMEOUT;                --Monitoring errors. Count of invalid byte types in parsing.
        when 88 => --0x58
          localRdData(15 downto  0)  <=  Mon.CM(1).MONITOR.ERRORS.CNT_UNKNOWN;                --Monitoring errors. Count of invalid byte types in parsing.
        when 89 => --0x59
          localRdData(31 downto  0)  <=  Mon.CM(1).MONITOR.UART_BYTES;                        --Count of UART bytes from CM MCU
        when 90 => --0x5a
          localRdData(31 downto  0)  <=  reg_data(90)(31 downto  0);                          --Count to wait for in state machine before timing out (50Mhz clk)
        when 256 => --0x100
          localRdData( 0)            <=  reg_data(256)( 0);                                   --Tell CM uC to power-up
          localRdData( 1)            <=  reg_data(256)( 1);                                   --Tell CM uC to power-up the rest of the CM
          localRdData( 2)            <=  reg_data(256)( 2);                                   --Ignore power good from CM
          localRdData( 3)            <=  Mon.CM(2).CTRL.PWR_GOOD;                             --CM power is good
          localRdData( 7 downto  4)  <=  Mon.CM(2).CTRL.STATE;                                --CM power up state
          localRdData( 8)            <=  reg_data(256)( 8);                                   --CM power is good
          localRdData( 9)            <=  Mon.CM(2).CTRL.PWR_ENABLED;                          --power is enabled
          localRdData(10)            <=  Mon.CM(2).CTRL.IOS_ENABLED;                          --IOs to CM are enabled
        when 272 => --0x110
          localRdData(11)            <=  reg_data(272)(11);                                   --phy_lane_control is enabled
        when 273 => --0x111
          localRdData(31 downto  0)  <=  reg_data(273)(31 downto  0);                         --Contious phy_lane_up signals required to lock phylane control
        when 274 => --0x112
          localRdData(23 downto  0)  <=  reg_data(274)(23 downto  0);                         --Time spent waiting for phylane to stabilize
        when 276 => --0x114
          localRdData( 0)            <=  Mon.CM(2).C2C(1).STATUS.CONFIG_ERROR;                --C2C config error
          localRdData( 1)            <=  Mon.CM(2).C2C(1).STATUS.LINK_ERROR;                  --C2C link error
          localRdData( 2)            <=  Mon.CM(2).C2C(1).STATUS.LINK_GOOD;                   --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(2).C2C(1).STATUS.MB_ERROR;                    --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(2).C2C(1).STATUS.DO_CC;                       --Aurora do CC
          localRdData( 5)            <=  reg_data(276)( 5);                                   --C2C initialize
          localRdData( 8)            <=  Mon.CM(2).C2C(1).STATUS.PHY_RESET;                   --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(2).C2C(1).STATUS.PHY_GT_PLL_LOCK;             --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(2).C2C(1).STATUS.PHY_MMCM_LOL;                --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(2).C2C(1).STATUS.PHY_LANE_UP;                 --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(2).C2C(1).STATUS.PHY_HARD_ERR;                --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(2).C2C(1).STATUS.PHY_SOFT_ERR;                --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(2).C2C(1).STATUS.LINK_IN_FW;                  --FW includes this link
        when 277 => --0x115
          localRdData(15 downto  0)  <=  Mon.CM(2).C2C(1).LINK_DEBUG.DMONITOR;                --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(2).C2C(1).LINK_DEBUG.QPLL_LOCK;               --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(2).C2C(1).LINK_DEBUG.CPLL_LOCK;               --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(2).C2C(1).LINK_DEBUG.EYESCAN_DATA_ERROR;      --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(277)(22);                                   --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(277)(23);                                   --DEBUG eyescan trigger
        when 278 => --0x116
          localRdData(15 downto  0)  <=  reg_data(278)(15 downto  0);                         --bit 2 is DRP uber reset
        when 279 => --0x117
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(1).LINK_DEBUG.RX.BUF_STATUS;           --DEBUG rx buf status
          localRdData(10)            <=  Mon.CM(2).C2C(1).LINK_DEBUG.RX.PRBS_ERR;             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(2).C2C(1).LINK_DEBUG.RX.RESET_DONE;           --DEBUG rx reset done
          localRdData(12)            <=  reg_data(279)(12);                                   --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(279)(13);                                   --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(279)(17);                                   --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(279)(18);                                   --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(279)(23);                                   --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(279)(24);                                   --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(279)(25);                                   --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(279)(29 downto 26);                         --DEBUG rx PRBS select
        when 280 => --0x118
          localRdData( 2 downto  0)  <=  reg_data(280)( 2 downto  0);                         --DEBUG rx rate
        when 281 => --0x119
          localRdData( 1 downto  0)  <=  Mon.CM(2).C2C(1).LINK_DEBUG.TX.BUF_STATUS;           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(2).C2C(1).LINK_DEBUG.TX.RESET_DONE;           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(281)( 7);                                   --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(281)(15);                                   --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(281)(16);                                   --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(281)(17);                                   --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(281)(22 downto 18);                         --DEBUG post cursor
          localRdData(23)            <=  reg_data(281)(23);                                   --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(281)(31 downto 27);                         --DEBUG pre cursor
        when 282 => --0x11a
          localRdData( 3 downto  0)  <=  reg_data(282)( 3 downto  0);                         --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(282)( 8 downto  4);                         --DEBUG tx diff control
        when 288 => --0x120
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.INIT_ALLTIME;                   --Counter for every PHYLANEUP cycle
        when 289 => --0x121
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.INIT_SHORTTERM;                 --Counter for PHYLANEUP cycles since lase C2C INITIALIZE
        when 290 => --0x122
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.CONFIG_ERROR_COUNT;             --Counter for CONFIG_ERROR
        when 291 => --0x123
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.LINK_ERROR_COUNT;               --Counter for LINK_ERROR
        when 292 => --0x124
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.MB_ERROR_COUNT;                 --Counter for MB_ERROR
        when 293 => --0x125
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.PHY_HARD_ERROR_COUNT;           --Counter for PHY_HARD_ERROR
        when 294 => --0x126
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.PHY_SOFT_ERROR_COUNT;           --Counter for PHY_SOFT_ERROR
        when 295 => --0x127
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(1).CNT.PHYLANE_STATE;                  --Current state of phy_lane_control module
        when 297 => --0x129
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.PHY_ERRORSTATE_COUNT;           --Count for phylane in error state
        when 298 => --0x12a
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(1).CNT.USER_CLK_FREQ;                  --Frequency of the user C2C clk
        when 304 => --0x130
          localRdData(11)            <=  reg_data(304)(11);                                   --phy_lane_control is enabled
        when 305 => --0x131
          localRdData(31 downto  0)  <=  reg_data(305)(31 downto  0);                         --Contious phy_lane_up signals required to lock phylane control
        when 306 => --0x132
          localRdData(23 downto  0)  <=  reg_data(306)(23 downto  0);                         --Time spent waiting for phylane to stabilize
        when 308 => --0x134
          localRdData( 0)            <=  Mon.CM(2).C2C(2).STATUS.CONFIG_ERROR;                --C2C config error
          localRdData( 1)            <=  Mon.CM(2).C2C(2).STATUS.LINK_ERROR;                  --C2C link error
          localRdData( 2)            <=  Mon.CM(2).C2C(2).STATUS.LINK_GOOD;                   --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.CM(2).C2C(2).STATUS.MB_ERROR;                    --C2C multi-bit error
          localRdData( 4)            <=  Mon.CM(2).C2C(2).STATUS.DO_CC;                       --Aurora do CC
          localRdData( 5)            <=  reg_data(308)( 5);                                   --C2C initialize
          localRdData( 8)            <=  Mon.CM(2).C2C(2).STATUS.PHY_RESET;                   --Aurora phy in reset
          localRdData( 9)            <=  Mon.CM(2).C2C(2).STATUS.PHY_GT_PLL_LOCK;             --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.CM(2).C2C(2).STATUS.PHY_MMCM_LOL;                --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.CM(2).C2C(2).STATUS.PHY_LANE_UP;                 --Aurora phy lanes up
          localRdData(16)            <=  Mon.CM(2).C2C(2).STATUS.PHY_HARD_ERR;                --Aurora phy hard error
          localRdData(17)            <=  Mon.CM(2).C2C(2).STATUS.PHY_SOFT_ERR;                --Aurora phy soft error
          localRdData(31)            <=  Mon.CM(2).C2C(2).STATUS.LINK_IN_FW;                  --FW includes this link
        when 309 => --0x135
          localRdData(15 downto  0)  <=  Mon.CM(2).C2C(2).LINK_DEBUG.DMONITOR;                --DEBUG d monitor
          localRdData(16)            <=  Mon.CM(2).C2C(2).LINK_DEBUG.QPLL_LOCK;               --DEBUG cplllock
          localRdData(20)            <=  Mon.CM(2).C2C(2).LINK_DEBUG.CPLL_LOCK;               --DEBUG cplllock
          localRdData(21)            <=  Mon.CM(2).C2C(2).LINK_DEBUG.EYESCAN_DATA_ERROR;      --DEBUG eyescan data error
          localRdData(22)            <=  reg_data(309)(22);                                   --DEBUG eyescan reset
          localRdData(23)            <=  reg_data(309)(23);                                   --DEBUG eyescan trigger
        when 310 => --0x136
          localRdData(15 downto  0)  <=  reg_data(310)(15 downto  0);                         --bit 2 is DRP uber reset
        when 311 => --0x137
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(2).LINK_DEBUG.RX.BUF_STATUS;           --DEBUG rx buf status
          localRdData(10)            <=  Mon.CM(2).C2C(2).LINK_DEBUG.RX.PRBS_ERR;             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.CM(2).C2C(2).LINK_DEBUG.RX.RESET_DONE;           --DEBUG rx reset done
          localRdData(12)            <=  reg_data(311)(12);                                   --DEBUG rx buf reset
          localRdData(13)            <=  reg_data(311)(13);                                   --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data(311)(17);                                   --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data(311)(18);                                   --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data(311)(23);                                   --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data(311)(24);                                   --DEBUG rx pma reset
          localRdData(25)            <=  reg_data(311)(25);                                   --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(311)(29 downto 26);                         --DEBUG rx PRBS select
        when 312 => --0x138
          localRdData( 2 downto  0)  <=  reg_data(312)( 2 downto  0);                         --DEBUG rx rate
        when 313 => --0x139
          localRdData( 1 downto  0)  <=  Mon.CM(2).C2C(2).LINK_DEBUG.TX.BUF_STATUS;           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.CM(2).C2C(2).LINK_DEBUG.TX.RESET_DONE;           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(313)( 7);                                   --DEBUG tx inhibit
          localRdData(15)            <=  reg_data(313)(15);                                   --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data(313)(16);                                   --DEBUG tx pma reset
          localRdData(17)            <=  reg_data(313)(17);                                   --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(313)(22 downto 18);                         --DEBUG post cursor
          localRdData(23)            <=  reg_data(313)(23);                                   --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(313)(31 downto 27);                         --DEBUG pre cursor
        when 314 => --0x13a
          localRdData( 3 downto  0)  <=  reg_data(314)( 3 downto  0);                         --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(314)( 8 downto  4);                         --DEBUG tx diff control
        when 320 => --0x140
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.INIT_ALLTIME;                   --Counter for every PHYLANEUP cycle
        when 321 => --0x141
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.INIT_SHORTTERM;                 --Counter for PHYLANEUP cycles since lase C2C INITIALIZE
        when 322 => --0x142
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.CONFIG_ERROR_COUNT;             --Counter for CONFIG_ERROR
        when 323 => --0x143
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.LINK_ERROR_COUNT;               --Counter for LINK_ERROR
        when 324 => --0x144
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.MB_ERROR_COUNT;                 --Counter for MB_ERROR
        when 325 => --0x145
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.PHY_HARD_ERROR_COUNT;           --Counter for PHY_HARD_ERROR
        when 326 => --0x146
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.PHY_SOFT_ERROR_COUNT;           --Counter for PHY_SOFT_ERROR
        when 327 => --0x147
          localRdData( 2 downto  0)  <=  Mon.CM(2).C2C(2).CNT.PHYLANE_STATE;                  --Current state of phy_lane_control module
        when 329 => --0x149
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.PHY_ERRORSTATE_COUNT;           --Count for phylane in error state
        when 330 => --0x14a
          localRdData(31 downto  0)  <=  Mon.CM(2).C2C(2).CNT.USER_CLK_FREQ;                  --Frequency of the user C2C clk
        when 336 => --0x150
          localRdData( 7 downto  0)  <=  reg_data(336)( 7 downto  0);                         --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
          localRdData( 8)            <=  Mon.CM(2).MONITOR.ACTIVE;                            --Monitoring active. Is zero when no update in the last second.
          localRdData(15 downto 12)  <=  Mon.CM(2).MONITOR.HISTORY_VALID;                     --bytes valid in debug history
        when 337 => --0x151
          localRdData(31 downto  0)  <=  Mon.CM(2).MONITOR.HISTORY;                           --4 bytes of uart history
        when 338 => --0x152
          localRdData( 7 downto  0)  <=  Mon.CM(2).MONITOR.BAD_TRANS.ADDR;                    --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(2).MONITOR.BAD_TRANS.DATA;                    --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(2).MONITOR.BAD_TRANS.ERROR_MASK;              --Sensor error bits
        when 339 => --0x153
          localRdData( 7 downto  0)  <=  Mon.CM(2).MONITOR.LAST_TRANS.ADDR;                   --Sensor addr bits
          localRdData(23 downto  8)  <=  Mon.CM(2).MONITOR.LAST_TRANS.DATA;                   --Sensor data bits
          localRdData(31 downto 24)  <=  Mon.CM(2).MONITOR.LAST_TRANS.ERROR_MASK;             --Sensor error bits
        when 340 => --0x154
          localRdData( 0)            <=  reg_data(340)( 0);                                   --Reset monitoring error counters
        when 341 => --0x155
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BAD_SOF;                --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_AXI_BUSY_BYTE2;         --Monitoring errors. Count of invalid byte types in parsing.
        when 342 => --0x156
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE2_NOT_DATA;         --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE3_NOT_DATA;         --Monitoring errors. Count of invalid byte types in parsing.
        when 343 => --0x157
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_BYTE4_NOT_DATA;         --Monitoring errors. Count of invalid byte types in parsing.
          localRdData(31 downto 16)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_TIMEOUT;                --Monitoring errors. Count of invalid byte types in parsing.
        when 344 => --0x158
          localRdData(15 downto  0)  <=  Mon.CM(2).MONITOR.ERRORS.CNT_UNKNOWN;                --Monitoring errors. Count of invalid byte types in parsing.
        when 345 => --0x159
          localRdData(31 downto  0)  <=  Mon.CM(2).MONITOR.UART_BYTES;                        --Count of UART bytes from CM MCU
        when 346 => --0x15a
          localRdData(31 downto  0)  <=  reg_data(346)(31 downto  0);                         --Count to wait for in state machine before timing out (50Mhz clk)


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
  Ctrl.CM(1).CTRL.ENABLE_UC                       <=  reg_data( 0)( 0);                
  Ctrl.CM(1).CTRL.ENABLE_PWR                      <=  reg_data( 0)( 1);                
  Ctrl.CM(1).CTRL.OVERRIDE_PWR_GOOD               <=  reg_data( 0)( 2);                
  Ctrl.CM(1).CTRL.ERROR_STATE_RESET               <=  reg_data( 0)( 8);                
  Ctrl.CM(1).C2C(1).ENABLE_PHY_CTRL               <=  reg_data(16)(11);                
  Ctrl.CM(1).C2C(1).PHY_LANE_STABLE               <=  reg_data(17)(31 downto  0);      
  Ctrl.CM(1).C2C(1).PHY_READ_TIME                 <=  reg_data(18)(23 downto  0);      
  Ctrl.CM(1).C2C(1).STATUS.INITIALIZE             <=  reg_data(20)( 5);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.EYESCAN_RESET      <=  reg_data(21)(22);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.EYESCAN_TRIGGER    <=  reg_data(21)(23);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.PCS_RSV_DIN        <=  reg_data(22)(15 downto  0);      
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.BUF_RESET       <=  reg_data(23)(12);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.CDR_HOLD        <=  reg_data(23)(13);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.DFE_LPM_RESET   <=  reg_data(23)(17);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.LPM_EN          <=  reg_data(23)(18);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.PCS_RESET       <=  reg_data(23)(23);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.PMA_RESET       <=  reg_data(23)(24);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.PRBS_CNT_RST    <=  reg_data(23)(25);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.PRBS_SEL        <=  reg_data(23)(29 downto 26);      
  Ctrl.CM(1).C2C(1).LINK_DEBUG.RX.RATE            <=  reg_data(24)( 2 downto  0);      
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.INHIBIT         <=  reg_data(25)( 7);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.PCS_RESET       <=  reg_data(25)(15);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.PMA_RESET       <=  reg_data(25)(16);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.POLARITY        <=  reg_data(25)(17);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.POST_CURSOR     <=  reg_data(25)(22 downto 18);      
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.PRBS_FORCE_ERR  <=  reg_data(25)(23);                
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.PRE_CURSOR      <=  reg_data(25)(31 downto 27);      
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.PRBS_SEL        <=  reg_data(26)( 3 downto  0);      
  Ctrl.CM(1).C2C(1).LINK_DEBUG.TX.DIFF_CTRL       <=  reg_data(26)( 8 downto  4);      
  Ctrl.CM(1).C2C(2).ENABLE_PHY_CTRL               <=  reg_data(48)(11);                
  Ctrl.CM(1).C2C(2).PHY_LANE_STABLE               <=  reg_data(49)(31 downto  0);      
  Ctrl.CM(1).C2C(2).PHY_READ_TIME                 <=  reg_data(50)(23 downto  0);      
  Ctrl.CM(1).C2C(2).STATUS.INITIALIZE             <=  reg_data(52)( 5);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.EYESCAN_RESET      <=  reg_data(53)(22);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.EYESCAN_TRIGGER    <=  reg_data(53)(23);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.PCS_RSV_DIN        <=  reg_data(54)(15 downto  0);      
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.BUF_RESET       <=  reg_data(55)(12);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.CDR_HOLD        <=  reg_data(55)(13);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.DFE_LPM_RESET   <=  reg_data(55)(17);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.LPM_EN          <=  reg_data(55)(18);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.PCS_RESET       <=  reg_data(55)(23);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.PMA_RESET       <=  reg_data(55)(24);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.PRBS_CNT_RST    <=  reg_data(55)(25);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.PRBS_SEL        <=  reg_data(55)(29 downto 26);      
  Ctrl.CM(1).C2C(2).LINK_DEBUG.RX.RATE            <=  reg_data(56)( 2 downto  0);      
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.INHIBIT         <=  reg_data(57)( 7);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.PCS_RESET       <=  reg_data(57)(15);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.PMA_RESET       <=  reg_data(57)(16);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.POLARITY        <=  reg_data(57)(17);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.POST_CURSOR     <=  reg_data(57)(22 downto 18);      
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.PRBS_FORCE_ERR  <=  reg_data(57)(23);                
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.PRE_CURSOR      <=  reg_data(57)(31 downto 27);      
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.PRBS_SEL        <=  reg_data(58)( 3 downto  0);      
  Ctrl.CM(1).C2C(2).LINK_DEBUG.TX.DIFF_CTRL       <=  reg_data(58)( 8 downto  4);      
  Ctrl.CM(1).MONITOR.COUNT_16X_BAUD               <=  reg_data(80)( 7 downto  0);      
  Ctrl.CM(1).MONITOR.ERRORS.RESET                 <=  reg_data(84)( 0);                
  Ctrl.CM(1).MONITOR.SM_TIMEOUT                   <=  reg_data(90)(31 downto  0);      
  Ctrl.CM(2).CTRL.ENABLE_UC                       <=  reg_data(256)( 0);               
  Ctrl.CM(2).CTRL.ENABLE_PWR                      <=  reg_data(256)( 1);               
  Ctrl.CM(2).CTRL.OVERRIDE_PWR_GOOD               <=  reg_data(256)( 2);               
  Ctrl.CM(2).CTRL.ERROR_STATE_RESET               <=  reg_data(256)( 8);               
  Ctrl.CM(2).C2C(1).ENABLE_PHY_CTRL               <=  reg_data(272)(11);               
  Ctrl.CM(2).C2C(1).PHY_LANE_STABLE               <=  reg_data(273)(31 downto  0);     
  Ctrl.CM(2).C2C(1).PHY_READ_TIME                 <=  reg_data(274)(23 downto  0);     
  Ctrl.CM(2).C2C(1).STATUS.INITIALIZE             <=  reg_data(276)( 5);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.EYESCAN_RESET      <=  reg_data(277)(22);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.EYESCAN_TRIGGER    <=  reg_data(277)(23);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.PCS_RSV_DIN        <=  reg_data(278)(15 downto  0);     
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.BUF_RESET       <=  reg_data(279)(12);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.CDR_HOLD        <=  reg_data(279)(13);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.DFE_LPM_RESET   <=  reg_data(279)(17);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.LPM_EN          <=  reg_data(279)(18);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.PCS_RESET       <=  reg_data(279)(23);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.PMA_RESET       <=  reg_data(279)(24);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.PRBS_CNT_RST    <=  reg_data(279)(25);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.PRBS_SEL        <=  reg_data(279)(29 downto 26);     
  Ctrl.CM(2).C2C(1).LINK_DEBUG.RX.RATE            <=  reg_data(280)( 2 downto  0);     
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.INHIBIT         <=  reg_data(281)( 7);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.PCS_RESET       <=  reg_data(281)(15);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.PMA_RESET       <=  reg_data(281)(16);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.POLARITY        <=  reg_data(281)(17);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.POST_CURSOR     <=  reg_data(281)(22 downto 18);     
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.PRBS_FORCE_ERR  <=  reg_data(281)(23);               
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.PRE_CURSOR      <=  reg_data(281)(31 downto 27);     
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.PRBS_SEL        <=  reg_data(282)( 3 downto  0);     
  Ctrl.CM(2).C2C(1).LINK_DEBUG.TX.DIFF_CTRL       <=  reg_data(282)( 8 downto  4);     
  Ctrl.CM(2).C2C(2).ENABLE_PHY_CTRL               <=  reg_data(304)(11);               
  Ctrl.CM(2).C2C(2).PHY_LANE_STABLE               <=  reg_data(305)(31 downto  0);     
  Ctrl.CM(2).C2C(2).PHY_READ_TIME                 <=  reg_data(306)(23 downto  0);     
  Ctrl.CM(2).C2C(2).STATUS.INITIALIZE             <=  reg_data(308)( 5);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.EYESCAN_RESET      <=  reg_data(309)(22);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.EYESCAN_TRIGGER    <=  reg_data(309)(23);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.PCS_RSV_DIN        <=  reg_data(310)(15 downto  0);     
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.BUF_RESET       <=  reg_data(311)(12);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.CDR_HOLD        <=  reg_data(311)(13);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.DFE_LPM_RESET   <=  reg_data(311)(17);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.LPM_EN          <=  reg_data(311)(18);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.PCS_RESET       <=  reg_data(311)(23);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.PMA_RESET       <=  reg_data(311)(24);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.PRBS_CNT_RST    <=  reg_data(311)(25);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.PRBS_SEL        <=  reg_data(311)(29 downto 26);     
  Ctrl.CM(2).C2C(2).LINK_DEBUG.RX.RATE            <=  reg_data(312)( 2 downto  0);     
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.INHIBIT         <=  reg_data(313)( 7);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.PCS_RESET       <=  reg_data(313)(15);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.PMA_RESET       <=  reg_data(313)(16);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.POLARITY        <=  reg_data(313)(17);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.POST_CURSOR     <=  reg_data(313)(22 downto 18);     
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.PRBS_FORCE_ERR  <=  reg_data(313)(23);               
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.PRE_CURSOR      <=  reg_data(313)(31 downto 27);     
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.PRBS_SEL        <=  reg_data(314)( 3 downto  0);     
  Ctrl.CM(2).C2C(2).LINK_DEBUG.TX.DIFF_CTRL       <=  reg_data(314)( 8 downto  4);     
  Ctrl.CM(2).MONITOR.COUNT_16X_BAUD               <=  reg_data(336)( 7 downto  0);     
  Ctrl.CM(2).MONITOR.ERRORS.RESET                 <=  reg_data(340)( 0);               
  Ctrl.CM(2).MONITOR.SM_TIMEOUT                   <=  reg_data(346)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)( 0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).CTRL.ENABLE_UC;
      reg_data( 0)( 1)  <= DEFAULT_CM_USP_CTRL_t.CM(1).CTRL.ENABLE_PWR;
      reg_data( 0)( 2)  <= DEFAULT_CM_USP_CTRL_t.CM(1).CTRL.OVERRIDE_PWR_GOOD;
      reg_data( 0)( 8)  <= DEFAULT_CM_USP_CTRL_t.CM(1).CTRL.ERROR_STATE_RESET;
      reg_data(16)(11)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).ENABLE_PHY_CTRL;
      reg_data(17)(31 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).PHY_LANE_STABLE;
      reg_data(18)(23 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).PHY_READ_TIME;
      reg_data(20)( 5)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).STATUS.INITIALIZE;
      reg_data(21)(22)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.EYESCAN_RESET;
      reg_data(21)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.EYESCAN_TRIGGER;
      reg_data(22)(15 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.PCS_RSV_DIN;
      reg_data(23)(12)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.BUF_RESET;
      reg_data(23)(13)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.CDR_HOLD;
      reg_data(23)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.DFE_LPM_RESET;
      reg_data(23)(18)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.LPM_EN;
      reg_data(23)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.PCS_RESET;
      reg_data(23)(24)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.PMA_RESET;
      reg_data(23)(25)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.PRBS_CNT_RST;
      reg_data(23)(29 downto 26)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.PRBS_SEL;
      reg_data(24)( 2 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.RX.RATE;
      reg_data(25)( 7)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.INHIBIT;
      reg_data(25)(15)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.PCS_RESET;
      reg_data(25)(16)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.PMA_RESET;
      reg_data(25)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.POLARITY;
      reg_data(25)(22 downto 18)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.POST_CURSOR;
      reg_data(25)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(25)(31 downto 27)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.PRE_CURSOR;
      reg_data(26)( 3 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.PRBS_SEL;
      reg_data(26)( 8 downto  4)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(1).LINK_DEBUG.TX.DIFF_CTRL;
      reg_data(48)(11)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).ENABLE_PHY_CTRL;
      reg_data(49)(31 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).PHY_LANE_STABLE;
      reg_data(50)(23 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).PHY_READ_TIME;
      reg_data(52)( 5)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).STATUS.INITIALIZE;
      reg_data(53)(22)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.EYESCAN_RESET;
      reg_data(53)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.EYESCAN_TRIGGER;
      reg_data(54)(15 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.PCS_RSV_DIN;
      reg_data(55)(12)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.BUF_RESET;
      reg_data(55)(13)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.CDR_HOLD;
      reg_data(55)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.DFE_LPM_RESET;
      reg_data(55)(18)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.LPM_EN;
      reg_data(55)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.PCS_RESET;
      reg_data(55)(24)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.PMA_RESET;
      reg_data(55)(25)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.PRBS_CNT_RST;
      reg_data(55)(29 downto 26)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.PRBS_SEL;
      reg_data(56)( 2 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.RX.RATE;
      reg_data(57)( 7)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.INHIBIT;
      reg_data(57)(15)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.PCS_RESET;
      reg_data(57)(16)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.PMA_RESET;
      reg_data(57)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.POLARITY;
      reg_data(57)(22 downto 18)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.POST_CURSOR;
      reg_data(57)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(57)(31 downto 27)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.PRE_CURSOR;
      reg_data(58)( 3 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.PRBS_SEL;
      reg_data(58)( 8 downto  4)  <= DEFAULT_CM_USP_CTRL_t.CM(1).C2C(2).LINK_DEBUG.TX.DIFF_CTRL;
      reg_data(80)( 7 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).MONITOR.COUNT_16X_BAUD;
      reg_data(84)( 0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).MONITOR.ERRORS.RESET;
      reg_data(90)(31 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(1).MONITOR.SM_TIMEOUT;
      reg_data(256)( 0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).CTRL.ENABLE_UC;
      reg_data(256)( 1)  <= DEFAULT_CM_USP_CTRL_t.CM(2).CTRL.ENABLE_PWR;
      reg_data(256)( 2)  <= DEFAULT_CM_USP_CTRL_t.CM(2).CTRL.OVERRIDE_PWR_GOOD;
      reg_data(256)( 8)  <= DEFAULT_CM_USP_CTRL_t.CM(2).CTRL.ERROR_STATE_RESET;
      reg_data(272)(11)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).ENABLE_PHY_CTRL;
      reg_data(273)(31 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).PHY_LANE_STABLE;
      reg_data(274)(23 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).PHY_READ_TIME;
      reg_data(276)( 5)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).STATUS.INITIALIZE;
      reg_data(277)(22)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.EYESCAN_RESET;
      reg_data(277)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.EYESCAN_TRIGGER;
      reg_data(278)(15 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.PCS_RSV_DIN;
      reg_data(279)(12)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.BUF_RESET;
      reg_data(279)(13)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.CDR_HOLD;
      reg_data(279)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.DFE_LPM_RESET;
      reg_data(279)(18)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.LPM_EN;
      reg_data(279)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.PCS_RESET;
      reg_data(279)(24)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.PMA_RESET;
      reg_data(279)(25)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.PRBS_CNT_RST;
      reg_data(279)(29 downto 26)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.PRBS_SEL;
      reg_data(280)( 2 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.RX.RATE;
      reg_data(281)( 7)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.INHIBIT;
      reg_data(281)(15)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.PCS_RESET;
      reg_data(281)(16)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.PMA_RESET;
      reg_data(281)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.POLARITY;
      reg_data(281)(22 downto 18)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.POST_CURSOR;
      reg_data(281)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(281)(31 downto 27)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.PRE_CURSOR;
      reg_data(282)( 3 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.PRBS_SEL;
      reg_data(282)( 8 downto  4)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(1).LINK_DEBUG.TX.DIFF_CTRL;
      reg_data(304)(11)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).ENABLE_PHY_CTRL;
      reg_data(305)(31 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).PHY_LANE_STABLE;
      reg_data(306)(23 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).PHY_READ_TIME;
      reg_data(308)( 5)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).STATUS.INITIALIZE;
      reg_data(309)(22)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.EYESCAN_RESET;
      reg_data(309)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.EYESCAN_TRIGGER;
      reg_data(310)(15 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.PCS_RSV_DIN;
      reg_data(311)(12)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.BUF_RESET;
      reg_data(311)(13)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.CDR_HOLD;
      reg_data(311)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.DFE_LPM_RESET;
      reg_data(311)(18)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.LPM_EN;
      reg_data(311)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.PCS_RESET;
      reg_data(311)(24)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.PMA_RESET;
      reg_data(311)(25)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.PRBS_CNT_RST;
      reg_data(311)(29 downto 26)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.PRBS_SEL;
      reg_data(312)( 2 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.RX.RATE;
      reg_data(313)( 7)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.INHIBIT;
      reg_data(313)(15)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.PCS_RESET;
      reg_data(313)(16)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.PMA_RESET;
      reg_data(313)(17)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.POLARITY;
      reg_data(313)(22 downto 18)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.POST_CURSOR;
      reg_data(313)(23)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(313)(31 downto 27)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.PRE_CURSOR;
      reg_data(314)( 3 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.PRBS_SEL;
      reg_data(314)( 8 downto  4)  <= DEFAULT_CM_USP_CTRL_t.CM(2).C2C(2).LINK_DEBUG.TX.DIFF_CTRL;
      reg_data(336)( 7 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).MONITOR.COUNT_16X_BAUD;
      reg_data(340)( 0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).MONITOR.ERRORS.RESET;
      reg_data(346)(31 downto  0)  <= DEFAULT_CM_USP_CTRL_t.CM(2).MONITOR.SM_TIMEOUT;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.CM(1).C2C(1).CNT.RESET_COUNTERS <= '0';
      Ctrl.CM(1).C2C(2).CNT.RESET_COUNTERS <= '0';
      Ctrl.CM(2).C2C(1).CNT.RESET_COUNTERS <= '0';
      Ctrl.CM(2).C2C(2).CNT.RESET_COUNTERS <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(8 downto 0))) is
        when 0 => --0x0
          reg_data( 0)( 0)                      <=  localWrData( 0);                --Tell CM uC to power-up
          reg_data( 0)( 1)                      <=  localWrData( 1);                --Tell CM uC to power-up the rest of the CM
          reg_data( 0)( 2)                      <=  localWrData( 2);                --Ignore power good from CM
          reg_data( 0)( 8)                      <=  localWrData( 8);                --CM power is good
        when 16 => --0x10
          reg_data(16)(11)                      <=  localWrData(11);                --phy_lane_control is enabled
        when 17 => --0x11
          reg_data(17)(31 downto  0)            <=  localWrData(31 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 18 => --0x12
          reg_data(18)(23 downto  0)            <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
        when 20 => --0x14
          reg_data(20)( 5)                      <=  localWrData( 5);                --C2C initialize
        when 21 => --0x15
          reg_data(21)(22)                      <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(21)(23)                      <=  localWrData(23);                --DEBUG eyescan trigger
        when 22 => --0x16
          reg_data(22)(15 downto  0)            <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 23 => --0x17
          reg_data(23)(12)                      <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(23)(13)                      <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(23)(17)                      <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(23)(18)                      <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(23)(23)                      <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(23)(24)                      <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(23)(25)                      <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(23)(29 downto 26)            <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 24 => --0x18
          reg_data(24)( 2 downto  0)            <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 25 => --0x19
          reg_data(25)( 7)                      <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(25)(15)                      <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(25)(16)                      <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(25)(17)                      <=  localWrData(17);                --DEBUG tx polarity
          reg_data(25)(22 downto 18)            <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(25)(23)                      <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(25)(31 downto 27)            <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 26 => --0x1a
          reg_data(26)( 3 downto  0)            <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(26)( 8 downto  4)            <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 40 => --0x28
          Ctrl.CM(1).C2C(1).CNT.RESET_COUNTERS  <=  localWrData( 0);               
        when 48 => --0x30
          reg_data(48)(11)                      <=  localWrData(11);                --phy_lane_control is enabled
        when 49 => --0x31
          reg_data(49)(31 downto  0)            <=  localWrData(31 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 50 => --0x32
          reg_data(50)(23 downto  0)            <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
        when 52 => --0x34
          reg_data(52)( 5)                      <=  localWrData( 5);                --C2C initialize
        when 53 => --0x35
          reg_data(53)(22)                      <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(53)(23)                      <=  localWrData(23);                --DEBUG eyescan trigger
        when 54 => --0x36
          reg_data(54)(15 downto  0)            <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 55 => --0x37
          reg_data(55)(12)                      <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(55)(13)                      <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(55)(17)                      <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(55)(18)                      <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(55)(23)                      <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(55)(24)                      <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(55)(25)                      <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(55)(29 downto 26)            <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 56 => --0x38
          reg_data(56)( 2 downto  0)            <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 57 => --0x39
          reg_data(57)( 7)                      <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(57)(15)                      <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(57)(16)                      <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(57)(17)                      <=  localWrData(17);                --DEBUG tx polarity
          reg_data(57)(22 downto 18)            <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(57)(23)                      <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(57)(31 downto 27)            <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 58 => --0x3a
          reg_data(58)( 3 downto  0)            <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(58)( 8 downto  4)            <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 72 => --0x48
          Ctrl.CM(1).C2C(2).CNT.RESET_COUNTERS  <=  localWrData( 0);               
        when 80 => --0x50
          reg_data(80)( 7 downto  0)            <=  localWrData( 7 downto  0);      --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
        when 84 => --0x54
          reg_data(84)( 0)                      <=  localWrData( 0);                --Reset monitoring error counters
        when 90 => --0x5a
          reg_data(90)(31 downto  0)            <=  localWrData(31 downto  0);      --Count to wait for in state machine before timing out (50Mhz clk)
        when 256 => --0x100
          reg_data(256)( 0)                     <=  localWrData( 0);                --Tell CM uC to power-up
          reg_data(256)( 1)                     <=  localWrData( 1);                --Tell CM uC to power-up the rest of the CM
          reg_data(256)( 2)                     <=  localWrData( 2);                --Ignore power good from CM
          reg_data(256)( 8)                     <=  localWrData( 8);                --CM power is good
        when 272 => --0x110
          reg_data(272)(11)                     <=  localWrData(11);                --phy_lane_control is enabled
        when 273 => --0x111
          reg_data(273)(31 downto  0)           <=  localWrData(31 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 274 => --0x112
          reg_data(274)(23 downto  0)           <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
        when 276 => --0x114
          reg_data(276)( 5)                     <=  localWrData( 5);                --C2C initialize
        when 277 => --0x115
          reg_data(277)(22)                     <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(277)(23)                     <=  localWrData(23);                --DEBUG eyescan trigger
        when 278 => --0x116
          reg_data(278)(15 downto  0)           <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 279 => --0x117
          reg_data(279)(12)                     <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(279)(13)                     <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(279)(17)                     <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(279)(18)                     <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(279)(23)                     <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(279)(24)                     <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(279)(25)                     <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(279)(29 downto 26)           <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 280 => --0x118
          reg_data(280)( 2 downto  0)           <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 281 => --0x119
          reg_data(281)( 7)                     <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(281)(15)                     <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(281)(16)                     <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(281)(17)                     <=  localWrData(17);                --DEBUG tx polarity
          reg_data(281)(22 downto 18)           <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(281)(23)                     <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(281)(31 downto 27)           <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 282 => --0x11a
          reg_data(282)( 3 downto  0)           <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(282)( 8 downto  4)           <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 296 => --0x128
          Ctrl.CM(2).C2C(1).CNT.RESET_COUNTERS  <=  localWrData( 0);               
        when 304 => --0x130
          reg_data(304)(11)                     <=  localWrData(11);                --phy_lane_control is enabled
        when 305 => --0x131
          reg_data(305)(31 downto  0)           <=  localWrData(31 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 306 => --0x132
          reg_data(306)(23 downto  0)           <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
        when 308 => --0x134
          reg_data(308)( 5)                     <=  localWrData( 5);                --C2C initialize
        when 309 => --0x135
          reg_data(309)(22)                     <=  localWrData(22);                --DEBUG eyescan reset
          reg_data(309)(23)                     <=  localWrData(23);                --DEBUG eyescan trigger
        when 310 => --0x136
          reg_data(310)(15 downto  0)           <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 311 => --0x137
          reg_data(311)(12)                     <=  localWrData(12);                --DEBUG rx buf reset
          reg_data(311)(13)                     <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(311)(17)                     <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data(311)(18)                     <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(311)(23)                     <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data(311)(24)                     <=  localWrData(24);                --DEBUG rx pma reset
          reg_data(311)(25)                     <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(311)(29 downto 26)           <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 312 => --0x138
          reg_data(312)( 2 downto  0)           <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 313 => --0x139
          reg_data(313)( 7)                     <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(313)(15)                     <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data(313)(16)                     <=  localWrData(16);                --DEBUG tx pma reset
          reg_data(313)(17)                     <=  localWrData(17);                --DEBUG tx polarity
          reg_data(313)(22 downto 18)           <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(313)(23)                     <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(313)(31 downto 27)           <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 314 => --0x13a
          reg_data(314)( 3 downto  0)           <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(314)( 8 downto  4)           <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 328 => --0x148
          Ctrl.CM(2).C2C(2).CNT.RESET_COUNTERS  <=  localWrData( 0);               
        when 336 => --0x150
          reg_data(336)( 7 downto  0)           <=  localWrData( 7 downto  0);      --Baud 16x counter.  Set by 50Mhz/(baudrate(hz) * 16). Nominally 27
        when 340 => --0x154
          reg_data(340)( 0)                     <=  localWrData( 0);                --Reset monitoring error counters
        when 346 => --0x15a
          reg_data(346)(31 downto  0)           <=  localWrData(31 downto  0);      --Count to wait for in state machine before timing out (50Mhz clk)

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;







  
end architecture behavioral;