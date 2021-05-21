--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
{% if bram_count %}use work.BRAMPortPkg.all;{% endif %}
use work.{{baseName}}_Ctrl.all;
entity {{baseName}}_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    {% if r_ops_output %}
    Mon              : in  {{baseName}}_Mon_t{% endif %}{% if w_ops_output or bram_count %};
    Ctrl             : out {{baseName}}_Ctrl_t
    {% endif %}    
    );
end entity {{baseName}}_interface;
architecture behavioral of {{baseName}}_interface is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  {% if bram_count %}
  constant BRAM_COUNT       : integer := {{bram_count}};
  signal latchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  constant BRAM_RANGE       : int_array_t(0 to BRAM_COUNT-1) := ({{bram_ranges}});
  constant BRAM_ADDR        : slv32_array_t(0 to BRAM_COUNT-1) := ({{bram_addrs}});
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  {% endif %}
  
  signal reg_data :  slv32_array_t(integer range 0 to {{regMapSize}});
  constant Default_reg_data : slv32_array_t(integer range 0 to {{regMapSize}}) := (others => x"00000000");
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

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      
      if localRdReq = '1' then
        localRdAddress <= localAddress;       
      end if;

      localRdAck <= '0';
      if regRdAck = '1' then
        localRdData_latch <= localRdData;
        localRdAck <= '1';
{% if bram_count %}
      else
        for iBRAM in 0 to BRAM_COUNT-1 loop
          if (latchBRAM(iBRAM) = '1') then
            localRdData_latch <= BRAM_MISO(iBRAM).rd_data;
            localRdAck <= '1';
          end if;
        end loop;  -- iBRAM
        {% endif %}
      end if;        
    end if;
  end process latch_reads;

  reads: process (clk_axi) is
  begin  -- process reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      regRdAck  <= '0';
      if localRdReq = '1' then
        regRdAck  <= '1';
        case to_integer(unsigned(localAddress({{regAddrRange}} downto 0))) is

{{r_ops_output}}

        when others =>
          localRdData <= x"00000000";
          regRdAck  <= '0';
        end case;      
      end if;
    end if;
  end process reads;

{% if w_ops_output %}
  -------------------------------------------------------------------------------
  -- Record write decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  -- Register mapping to ctrl structures
{{rw_ops_output}}

  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
{{def_ops_output}}
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
{{a_ops_output}}
      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress({{regAddrRange}} downto 0))) is
{{w_ops_output}}
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;
{% endif %}


{% if bram_count %}  
  -------------------------------------------------------------------------------
  -- BRAM decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  BRAM_reads: process (clk_axi) is
  begin  -- process BRAM_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      for iBRAM in 0 to BRAM_COUNT-1 loop
        latchBRAM(iBRAM) <= '0';        
        if localAddress({{regAddrRange}} downto BRAM_RANGE(iBRAM)) = BRAM_ADDR(iBRAM)({{regAddrRange}} downto BRAM_RANGE(iBRAM)) then
          latchBRAM(iBRAM) <= localRdReq;          
        end if;
      end loop;  -- iBRAM
    end if;
  end process BRAM_reads;
{% endif %}

{% if bram_count %}
  BRAMs: for iBRAM in 0 to BRAM_COUNT-1 generate    
    BRAM_MOSI(iBRAM).clk     <= clk_axi;

    BRAM_addrs: process (clk_axi) is
    begin  -- process BRAM_reads
      if clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
        BRAM_MOSI(iBRAM).enable  <= '1';
      end if;
    end process  BRAM_addrs;
    
  end generate BRAMs;

{{bram_MOSI_map}}
{{bram_MISO_map}}    

  
  BRAM_writes: process (clk_axi) is    
  begin  -- process BRAM_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      for iBRAM in 0 to BRAM_COUNT-1 loop
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress({{regAddrRange}} downto BRAM_RANGE(iBRAM)) = BRAM_ADDR(iBRAM)({{regAddrRange}} downto BRAM_RANGE(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_data     <= localWrData;
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;
        end if;
      end loop;  -- iBRAM
    end if;
  end process BRAM_writes;
{% endif %}

  
end architecture behavioral;
