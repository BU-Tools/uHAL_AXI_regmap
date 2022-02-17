--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.{{baseName}}_Ctrl.all;
{{additionalLibraries}}


entity {{baseName}}_map is
  generic (
    ALLOCATED_MEMORY_RANGE : integer
    );
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
{% if r_ops_output %}    Mon              : in  {{baseName}}_Mon_t{% endif %}{% if w_ops_output %};
    Ctrl             : out {{baseName}}_Ctrl_t{% endif %}
    );
end entity {{baseName}}_map;
architecture behavioral of {{baseName}}_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


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

  AXIRegBridge : entity work.axiLiteReg
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

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;        
      end if;
    end if;
  end process latch_reads;
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case to_integer(unsigned(localAddress({{regAddrRange}} downto 0))) is

{{r_ops_output}}

        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



{% if w_ops_output %}
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

end architecture behavioral;
