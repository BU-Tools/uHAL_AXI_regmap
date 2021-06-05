--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.{{baseName}}_Ctrl.all;
entity {{baseName}}_wb_interface is
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
{% if r_ops_output %}    mon         : in  {{baseName}}_Mon_t{% endif %}{% if w_ops_output %};
    ctrl        : out {{baseName}}_Ctrl_t{% endif %}
    );
end entity {{baseName}}_wb_interface;
architecture behavioral of {{baseName}}_wb_interface is
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  signal localRdData : std_logic_vector (31 downto 0) := (others => '0');
  signal localWrData : std_logic_vector (31 downto 0) := (others => '0');
  signal reg_data :  slv32_array_t(integer range 0 to {{regMapSize}});
  constant DEFAULT_REG_DATA : slv32_array_t(integer range 0 to {{regMapSize}}) := (others => x"00000000");
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
        case to_integer(unsigned(wb_addr({{regAddrRange}} downto 0))) is
  {{r_ops_output}}
        when others =>
          localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;

{% if w_ops_output %}
  -- Register mapping to ctrl structures
{{rw_ops_output}}

  -- writes to slave
  reg_writes: process (clk) is
  begin  -- process reg_writes
    if (rising_edge(clk)) then  -- rising clock edge

      -- Write on strobe=write=1
      if wb_strobe='1' and wb_write = '1' then
        case to_integer(unsigned(wb_addr({{regAddrRange}} downto 0))) is
{{w_ops_output}}
        when others => null;

        end case;
      end if; -- write

      -- synchronous reset (active high)
      if reset = '1' then
{{def_ops_output}}
{{a_ops_output}}
{{a_ops_output}}
      end if; -- reset
    end if; -- clk
  end process reg_writes;
{% endif %}

end architecture behavioral;
