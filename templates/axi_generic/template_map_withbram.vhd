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
{{additionalLibraries}}


entity {{baseName}}_map is
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
    {% if r_ops_output or bram_count or fifo_count %}
    Mon              : in  {{baseName}}_Mon_t{% endif %}{% if w_ops_output or bram_count or fifo_count %};
    Ctrl             : out {{baseName}}_Ctrl_t
    {% endif %}    
    );
end entity {{baseName}}_map;
architecture behavioral of {{baseName}}_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localWrAck         : std_logic;
  signal localWrErr         : std_logic;
  signal regWrAck           : std_logic;
  
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal localRdErr         : std_logic;
  signal regRdAck           : std_logic;

  {% if bram_count %}
  constant BRAM_COUNT       : integer := {{bram_count}};
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := ({{bram_ranges}});
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := ({{bram_addrs}});
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  {% endif %}

  {% if fifo_count %}
  constant FIFO_COUNT       : integer := {{fifo_count}};
  constant FIFO_range       : int_array_t(0 to FIFO_COUNT-1) := ({{fifo_ranges}});
  constant FIFO_addr        : slv32_array_t(0 to FIFO_COUNT-1) := ({{fifo_addrs}});
  signal FIFO_MOSI          : FIFOPortMOSI_array_t(0 to FIFO_COUNT-1);
  signal FIFO_MISO          : FIFOPortMISO_array_t(0 to FIFO_COUNT-1);
  {% endif %}

  signal reg_data :  slv32_array_t(integer range 0 to {{regMapSize}});
  constant Default_reg_data : slv32_array_t(integer range 0 to {{regMapSize}}) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  assert ((4*{{regMapSize}}) <= ALLOCATED_MEMORY_RANGE)
    report "{{baseName}}: Regmap addressing range " & integer'image(4*{{regMapSize}}) & " is outside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity ERROR;
  assert ((4*{{regMapSize}}) > ALLOCATED_MEMORY_RANGE)
    report "{{baseName}}: Regmap addressing range " & integer'image(4*{{regMapSize}}) & " is inside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
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
      write_ack   => localWrAck,
      write_err   => localWrErr,
      read_req    => localRdReq,
      read_ack    => localRdAck,
      read_err    => localRdErr);

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
        localRdAck        <= '1';
      {% for index in range(bram_count) %}elsif BRAM_MISO({{loop.index0}}).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= BRAM_MISO({{loop.index0}}).rd_data;
{% endfor %}
      {% for index in range(fifo_count) %}elsif FIFO_MISO({{loop.index0}}).rd_data_valid = '1' then
        localRdAck        <= '1';
        localRdData_latch <= FIFO_MISO({{loop.index0}}).rd_data;
        localRderr        <= FIFO_MISO({{loop.index0}}).rd_error;
{% endfor %}
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
        case to_integer(unsigned(localAddress({{regAddrRange}} downto 0))) is
          
{{r_ops_output}}

          when others =>
            regRdAck <= '0';
            localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;

{% if w_ops_output %}
  -------------------------------------------------------------------------------
  -- Record write decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------


  write_ack_proc : process (clk_axi, reset_axi_n) is
  begin
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      localWrAck <= '0';
      localWrErr <= '0';
    elsif clk'event and clk_axi = '1' then
      localWrAck <= '0';
      localWrErr <= '0';
      if regWrAck = '1' then
        localWrAck <= '1';
        localWrErr <= '0';
      {% for index in range(bram_count) %}elsif BRAM_MOSI({{loop.index0}}).wr_enable = '1' then
        localWrAck        <= '1';
        localWrErr        <= '0'; --assume this just works for now
{% endfor %}
      {% for index in range(fifo_count) %}elsif FIFO_MISO({{loop.index0}}).wr_data_valid = '1' then
        localWrAck        <= '1';
        localWrErr        <= FIFO_MISO({{loop.index0}}).wr_response;
{% endfor %}
      
    end if;
  end process write_ack_proc;    
  
  -- Register mapping to ctrl structures
{{rw_ops_output}}

  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      {{def_ops_output}}
      regWrAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
{{a_ops_output}}
      regWrAck <= '0';      
      if localWrEn = '1' then
        regWrAck <= '1';
        case to_integer(unsigned(localAddress({{regAddrRange}} downto 0))) is
{{w_ops_output}}
        when others =>
          regWrAck <= '0';
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

  BRAM_reads: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_read: process (clk_axi,reset_axi_n) is
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
        BRAM_MOSI(iBRAM).enable  <= '0';
        if localAddress({{regAddrRange}} downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)({{regAddrRange}} downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).enable  <= localRdReq;
        end if;
      end if;
    end process BRAM_read;
  end generate BRAM_reads;
{% endif %}

{% if bram_count %}
  BRAM_asyncs: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_MOSI(iBRAM).clk     <= clk_axi;
    BRAM_MOSI(iBRAM).wr_data <= localWrData;
  end generate BRAM_asyncs;
  
{{bram_MOSI_map}}
{{bram_MISO_map}}    

  BRAM_writes: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_write: process (clk_axi,reset_axi_n) is    
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress({{regAddrRange}} downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)({{regAddrRange}} downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;          
        end if;
      end if;
    end process BRAM_write;
  end generate BRAM_writes;
{% endif %}


{% if fifo_count %}  
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
        if localAddress({{regAddrRange}} downto FIFO_range(iFIFO)) = FIFO_addr(iFIFO)({{regAddrRange}} downto FIFO_range(iFIFO)) then
          FIFO_MOSI(iFIFO).rd_enable  <= localRdReq;
        end if;
      end if;
    end process FIFO_read;
  end generate FIFO_reads;
{% endif %}

{% if fifo_count %}
  FIFO_asyncs: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_MOSI(iFIFO).clk     <= clk_axi;
    FIFO_MOSI(iFIFO).wr_data <= localWrData;
  end generate FIFO_asyncs;
  
{{fifo_MOSI_map}}
{{fifo_MISO_map}}    

  FIFO_writes: for iFIFO in 0 to FIFO_COUNT-1 generate
    FIFO_write: process (clk_axi,reset_axi_n) is    
    begin  -- process FIFO_reads
      if reset_axi_n = '0' then
        FIFO_MOSI(iFIFO).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        FIFO_MOSI(iFIFO).wr_enable   <= '0';
        if localAddress({{regAddrRange}} downto FIFO_range(iFIFO)) = FIFO_addr(iFIFO)({{regAddrRange}} downto FIFO_range(iFIFO)) then
          FIFO_MOSI(iFIFO).wr_enable   <= localWrEn;
        end if;
      end if;
    end process FIFO_write;
  end generate FIFO_writes;
{% endif %}

  
end architecture behavioral;
