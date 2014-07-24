----------------------------------------------------------------------------------
-- Company: FREE INDEPENDENT ALLIANCE OF MAKERS
-- Engineer: Jose Jimenez Montañez
-- 
-- Create Date:    21:56:34 06/08/2014 
-- Design Name: 
-- Module Name:    wb_debugger - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wishbone_pkg.all;
use work.fine_delay_pkg.all;
--use work.etherbone_pkg.all;
use work.wr_xilinx_pkg.all;
use work.genram_pkg.all;
use work.wb_irq_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wb_debugger is
	generic(	g_dbg_dpram_size	: integer := 40960/4;
				g_dbg_init_file: string;
				g_reset_vector	:  t_wishbone_address := x"00000000";
				g_msi_queues 	: natural := 1;
				g_profile		: string := "medium_icache_debug";
				g_timers			: integer := 1;
				g_slave_interface_mode : t_wishbone_interface_mode := PIPELINED;
				g_slave_granularity : t_wishbone_address_granularity := BYTE);
    Port ( clk_sys 		: in  STD_LOGIC;
           reset_n 		: in  STD_LOGIC;
           master_i 		: in  t_wishbone_master_in;
           master_o 		: out t_wishbone_master_out;
			  slave_i		: in  t_wishbone_slave_in;
			  slave_o 		: out t_wishbone_slave_out;			  
			  wrpc_uart_rxd_i: inout std_logic;
			  wrpc_uart_txd_o: inout std_logic;
           uart_rxd_i 	: in  STD_LOGIC;
           uart_txd_o 	: out STD_LOGIC;
			  running_indicator : out STD_LOGIC;
			  control_button : in std_logic);
end wb_debugger;

architecture Behavioral of wb_debugger is

function f_xwb_dpram_dbg(g_size : natural) return t_sdb_device
  is
    variable result : t_sdb_device;
  begin
    result.abi_class     := x"0001"; -- RAM device
    result.abi_ver_major := x"01";
    result.abi_ver_minor := x"00";
    result.wbd_width     := x"7"; -- 32/16/8-bit supported
    result.wbd_endian    := c_sdb_endian_big;
    
    result.sdb_component.addr_first := (others => '0');
    result.sdb_component.addr_last  := std_logic_vector(to_unsigned(g_size*4-1, 64));
    
    result.sdb_component.product.vendor_id := x"000000000000CE42"; -- CERN
    result.sdb_component.product.device_id := x"deaf0bee";
    result.sdb_component.product.version   := x"00000001";
    result.sdb_component.product.date      := x"20120305";
    result.sdb_component.product.name      := "BlockRAM-Debugger  ";
    
    return result;
  end f_xwb_dpram_dbg;
  
  constant c_NUM_TIMERS		 : natural range 1 to 3 := 1;
  
  constant c_NUM_WB_MASTERS : integer := 6;
  constant c_NUM_WB_SLAVES  : integer := 3;

  constant c_MASTER_LM32   : integer := 0; ---has two
  constant c_MASTER_ADAPT  : integer := 2;
  --constant c_MASTER_OUT_PORT : integer := 2;
  
  constant c_EXT_BRIDGE			: integer := 0;
  constant c_SLAVE_DPRAM		: integer := 1;
  --constant c_SEC_BRIDGE			: integer := 1;
  constant c_SLAVE_TICS		 	: integer := 2;
  constant c_SLAVE_TIMER_IRQ	: integer := 3;
  constant c_SLAVE_IRQ_CTRL	: integer := 4;
  constant c_SLAVE_UART       : integer := 5;

  constant c_EXT_BRIDGE_SDB : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"000effff", x"00000000");
  
  
  --- SEC
--  constant c_NUM_SEC_WB_MASTERS  : integer := 2;
--  constant c_NUM_SEC_WB_SLAVES   : integer := 2;
--  
--  constant c_SEC_MASTER_CBAR		: integer := 0;
--  constant c_SEC_MASTER_ADAPT	   : integer := 1;
--  constant c_SEC_SLAVE_DPRAM	 	: integer := 0;
--  constant c_SEC_SLAVE_UART	 	: integer := 1;
	 
  --constant init_lm32_addr : t_wishbone_address := x"00040000";

  --constant g_dpram_size		: integer := 114688/4;  --in 32-bit words
  constant c_FREQ_DIVIDER	: integer := 62500; -- LM32 clk = 62.5 Mhz
  
  component chipscope_ila
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      TRIG0   : in    std_logic_vector(31 downto 0);
      TRIG1   : in    std_logic_vector(31 downto 0);
      TRIG2   : in    std_logic_vector(31 downto 0);
      TRIG3   : in    std_logic_vector(31 downto 0));
  end component;

  component chipscope_icon
    port (
      CONTROL0 : inout std_logic_vector (35 downto 0));
  end component;

  signal CONTROL : std_logic_vector(35 downto 0);
  signal CLK     : std_logic;
  signal TRIG0   : std_logic_vector(31 downto 0);
  signal TRIG1   : std_logic_vector(31 downto 0);
  signal TRIG2   : std_logic_vector(31 downto 0);
  signal TRIG3   : std_logic_vector(31 downto 0);
--  
  
  constant c_uart_sdb_dbg : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"dead0fee",
        version   => x"00000001",
        date      => x"20120305",
        name      => "WB-UART-debugger   "))); 

  constant c_xwb_tics_sdb_dbg : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"0000000000000000",
      product     => (
        vendor_id => x"000000000000CE42",  -- GSIx
        device_id => x"adabadaa",
        version   => x"00000001",
        date      => x"20111004",
        name      => "WB-Tics-Debugger   ")));


--constant c_SEC_INTERCONNECT_LAYOUT : t_sdb_record_array(c_NUM_SEC_WB_MASTERS-1 downto 0) :=
--    (c_SEC_SLAVE_DPRAM => f_sdb_embed_device(f_xwb_dpram_dbg(g_dbg_dpram_size), x"00000000"),
--	  c_SEC_SLAVE_UART  => f_sdb_embed_device(c_uart_sdb_dbg, x"00020000"));

--  constant c_SEC_SDB_ADDRESS : t_wishbone_address := x"00030000";
--  constant c_SEC_BRIDGE_SDB  : t_sdb_bridge       :=
--    f_xwb_bridge_layout_sdb(true, c_SEC_INTERCONNECT_LAYOUT, c_SEC_SDB_ADDRESS);		  

--  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(c_NUM_WB_MASTERS-1 downto 0) :=
--    (c_EXT_BRIDGE		 => f_sdb_embed_bridge(c_EXT_BRIDGE_SDB,   x"01000000"),
--	  c_SEC_BRIDGE     => f_sdb_embed_bridge(c_SEC_BRIDGE_SDB,   x"00040000"),
--	  c_SLAVE_TICS	    => f_sdb_embed_device(c_xwb_tics_sdb_dbg, x"00020000"),
--	  c_SLAVE_TIMER_IRQ=> f_sdb_embed_device(c_irq_timer_sdb,    x"00020100"),
--	  c_SLAVE_IRQ_CTRL => f_sdb_embed_device(c_irq_ctrl_sdb,     x"00020300"));
--	  c_SLAVE_FK_DPRAM => f_sdb_embed_device(f_xwb_dpram_dbg(g_dbg_dpram_size), x"00000000"));  

  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(c_NUM_WB_MASTERS-1 downto 0) :=
    (c_EXT_BRIDGE		 => f_sdb_embed_bridge(c_EXT_BRIDGE_SDB,   x"00100000"),
	  c_SLAVE_DPRAM    => f_sdb_embed_device(f_xwb_dpram_dbg(g_dbg_dpram_size), x"00000000"),
	  c_SLAVE_TICS	    => f_sdb_embed_device(c_xwb_tics_sdb_dbg, x"00020400"),
	  c_SLAVE_TIMER_IRQ=> f_sdb_embed_device(c_irq_timer_sdb,    x"00020300"),
	  c_SLAVE_IRQ_CTRL => f_sdb_embed_device(c_irq_ctrl_sdb,     x"00020200"),
	  c_SLAVE_UART     => f_sdb_embed_device(c_uart_sdb_dbg,     x"00020100")
	  );

  constant c_SDB_ADDRESS : t_wishbone_address := x"00020600";
  
 
  signal cnx_master_out : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in  : t_wishbone_master_in_array(c_NUM_WB_MASTERS-1 downto 0);

  signal cnx_slave_out : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in  : t_wishbone_slave_in_array(c_NUM_WB_SLAVES-1 downto 0);  
  
--  signal cnx_sec_master_out : t_wishbone_master_out_array(c_NUM_SEC_WB_MASTERS-1 downto 0);
--  signal cnx_sec_master_in  : t_wishbone_master_in_array(c_NUM_SEC_WB_MASTERS-1 downto 0);

--  signal cnx_sec_slave_out : t_wishbone_slave_out_array(c_NUM_SEC_WB_SLAVES-1 downto 0);
--  signal cnx_sec_slave_in  : t_wishbone_slave_in_array(c_NUM_SEC_WB_SLAVES-1 downto 0);
  
  signal debugger_ram_wbb_i : t_wishbone_slave_in;
  signal debugger_ram_wbb_o : t_wishbone_slave_out;
  
  signal aux_slave_i : t_wishbone_slave_in;
  signal aux_slave_o : t_wishbone_slave_out;
  
  signal sl_addr_i : t_wishbone_address := (others => '0'); 
  
  
  signal periph_slave_i : t_wishbone_slave_in_array(0 to 2);
  signal periph_slave_o : t_wishbone_slave_out_array(0 to 2);
  signal periph_dummy	: std_logic_vector (9 downto 0);
  signal wrpc_dummy		: std_logic_vector (2 downto 0);
  signal forced_lm32_reset_n : std_logic := '0';
  signal button2_synced_n : std_logic;
  
  signal irq_slave_i : t_wishbone_slave_in_array(g_msi_queues-1 to 0);
  signal irq_slave_o : t_wishbone_slave_out_array(g_msi_queues-1 to 0);

  signal local_counter : unsigned (63 downto 0);
  
  signal uart_dummy_i 	: std_logic;
  signal uart_dummy_o 	: std_logic;

  signal dbg_uart_rxd_i	: std_logic;
  signal dbg_uart_txd_o	: std_logic;
  
  signal use_dbg_uart	: std_logic := '1';
  signal state_control 	: unsigned (39 downto 0) := x"0000000000";

begin
  running_indicator <= forced_lm32_reset_n;
  
  master_o <= cnx_master_out(c_EXT_BRIDGE);
  cnx_master_in(c_EXT_BRIDGE) <= master_i;
  
--  aux_slave_i.adr(31 downto 20) <= (others => '0');
--  aux_slave_i <= slave_i;
--  slave_o <= aux_slave_o;
  
  trig0(0) <= cnx_slave_in(c_MASTER_ADAPT).cyc;
  trig0(1) <= cnx_master_out(c_SLAVE_DPRAM).cyc;
--  trig0(2) <= aux_slave_i.cyc;
  trig0(3) <= cnx_master_in(c_SLAVE_DPRAM).ack;
--  
  trig1 <= cnx_slave_in(c_MASTER_ADAPT).adr;
--  
  trig2 <= cnx_master_out(c_SLAVE_DPRAM).adr;
--  trig3 <= aux_slave_i.adr;
  
--  cnx_master_in(c_SEC_BRIDGE) <= cnx_sec_slave_out(c_SEC_MASTER_CBAR);  
--  cnx_sec_slave_in(c_SEC_MASTER_CBAR) <= cnx_master_out(c_SEC_BRIDGE);
--  cnx_master_out(c_SEC_BRIDGE) <= cnx_sec_slave_in(c_SEC_MASTER_CBAR);
--  cnx_sec_slave_out(c_SEC_MASTER_CBAR) <= cnx_master_in(c_SEC_BRIDGE);
  
  controller : process (clk_sys)
	begin 
		if (rising_edge(clk_sys)) then
			if (control_button = '0' and (state_control /= x"ffffffffff")) then
				state_control <= state_control + 1;
			else
				if ((state_control /= x"0000000000") and (state_control <= x"3B9ACA0")) then --0.5s
					forced_lm32_reset_n <= not forced_lm32_reset_n;
				elsif (state_control > x"3B9ACA0") then
					use_dbg_uart <= not use_dbg_uart;
				end if;
				state_control <= x"0000000000";
			end if;
		end if;
	end process;
	
	uart_txd_o <= dbg_uart_txd_o when use_dbg_uart ='1' else wrpc_uart_txd_o;
	dbg_uart_rxd_i <= uart_rxd_i when use_dbg_uart ='1' else '1';
	wrpc_uart_rxd_i <= uart_rxd_i when use_dbg_uart ='0' else '1';

--------------------------------------
-- UART
--------------------------------------
  UART : xwb_simple_uart
    generic map(
      g_with_virtual_uart   => true,
      g_with_physical_uart  => true,
      g_interface_mode      => PIPELINED,
      g_address_granularity => BYTE
      )
    port map(
      clk_sys_i => clk_sys,
      rst_n_i   => reset_n,

      -- Wishbone
--		slave_i => cnx_sec_master_out(c_SEC_SLAVE_UART),
--      slave_o => cnx_sec_master_in(c_sec_SLAVE_UART),
		slave_i => cnx_master_out(c_SLAVE_UART),
      slave_o => cnx_master_in(c_SLAVE_UART),
      desc_o  => open,

		uart_rxd_i => dbg_uart_rxd_i,
      uart_txd_o => dbg_uart_txd_o
      );

--------------------------------------
-- Tics Counter
--------------------------------------
	tic_cnt : xwb_tics 
	generic map(
		g_period => c_FREQ_DIVIDER
		)
	port map(
		clk_sys_i => clk_sys,
		rst_n_i   => reset_n,

		-- Wishbone
		slave_i => cnx_master_out(c_SLAVE_TICS),
      slave_o => cnx_master_in(c_SLAVE_TICS),
      desc_o  => open
    );

-----------------------------------------------------------------------------
-- LM32 with MSI interface
----------------------------------------------------------------------------- 

	U_LM32_CORE : wb_irq_lm32
	generic map(
			  g_msi_queues => g_msi_queues, 
			  g_profile => g_profile)
			  --g_reset_vector=> init_lm32_addr)
	port map(
		clk_sys_i => clk_sys,
		rst_n_i => forced_lm32_reset_n,

	   dwb_o => cnx_slave_in(c_MASTER_LM32),
      dwb_i => cnx_slave_out(c_MASTER_LM32),
      iwb_o => cnx_slave_in(c_MASTER_LM32+1),
      iwb_i => cnx_slave_out(c_MASTER_LM32+1),

		irq_slave_o  => irq_slave_o,  -- wb msi interface
		irq_slave_i  => irq_slave_i,
				
		ctrl_slave_o => cnx_master_in(c_SLAVE_IRQ_CTRL),                -- ctrl interface for LM32 irq processing
		ctrl_slave_i => cnx_master_out(c_SLAVE_IRQ_CTRL)
	);

---------------------------------------------------------------------------
-- Dual-port RAM
-----------------------------------------------------------------------------  
  U_DPRAM : xwb_dpram
    generic map(
      g_size                  => g_dbg_dpram_size,  --in 32-bit words
      g_init_file             => g_dbg_init_file,
      g_must_have_init_file   => true,  --> OJO <--
      g_slave1_interface_mode => PIPELINED,
      g_slave2_interface_mode => PIPELINED,
      g_slave1_granularity    => BYTE,
      g_slave2_granularity    => WORD)  
    port map(
      clk_sys_i => clk_sys,
      rst_n_i   => reset_n,

--      slave1_i => cnx_sec_master_out(c_SEC_SLAVE_DPRAM),
--      slave1_o => cnx_sec_master_in(c_SEC_SLAVE_DPRAM),     
		slave1_i => cnx_master_out(c_SLAVE_DPRAM),
      slave1_o => cnx_master_in(c_SLAVE_DPRAM),
      slave2_i => debugger_ram_wbb_i,
      slave2_o => open
      );

---------------------------------------------------------------------------
-- IRQ - Timer
---------------------------------------------------------------------------
  process(clk_sys)
	begin
	if (clk_sys'event and clk_sys = '1') then
		if (reset_n = '0') then
			local_counter <= (others => '0');
		else
			local_counter <= local_counter + 1;
		end if;
	end if;
  end process;
		
  U_Timer : wb_irq_timer 
  generic map( g_timers =>  g_timers)
  port map(clk_sys_i     => clk_sys,           
           rst_sys_n_i   => reset_n,             
         
           tm_tai8ns_i   => std_logic_vector(local_counter),

           ctrl_slave_o  => cnx_master_in(c_SLAVE_TIMER_IRQ), 				 -- ctrl interface for LM32 irq processing
           ctrl_slave_i  => cnx_master_out(c_SLAVE_TIMER_IRQ),
           
           irq_master_o  => irq_slave_i(0),                             -- wb msi interface 
           irq_master_i  => irq_slave_o(0)
   );

  U_Intercon : xwb_sdb_crossbar
    generic map (
      g_num_masters => c_NUM_WB_SLAVES,
      g_num_slaves  => c_NUM_WB_MASTERS,
      g_registered  => true,
      g_wraparound  => true,
      g_layout      => c_INTERCONNECT_LAYOUT,
      g_sdb_addr    => c_SDB_ADDRESS)
    port map (
      clk_sys_i => clk_sys,
      rst_n_i   => reset_n,
      slave_i   => cnx_slave_in,
      slave_o   => cnx_slave_out,
      master_i  => cnx_master_in,
      master_o  => cnx_master_out);
	
-- U_Sec_Intercon : xwb_sdb_crossbar
--    generic map (
--      g_num_masters => c_NUM_SEC_WB_SLAVES,
--      g_num_slaves  => c_NUM_SEC_WB_MASTERS,
--      g_registered  => true,
--      g_wraparound  => true,
--      g_layout      => c_SEC_INTERCONNECT_LAYOUT,
--      g_sdb_addr    => c_SEC_SDB_ADDRESS)
--    port map (
--      clk_sys_i => clk_sys,
--      rst_n_i   => reset_n,
--      slave_i   => cnx_sec_slave_in,
--      slave_o   => cnx_sec_slave_out,
--      master_i  => cnx_sec_master_in,
--      master_o  => cnx_sec_master_out);

  U_Adapter1 : wb_slave_adapter
    generic map (
      g_master_use_struct  => true,
      g_master_mode        => g_slave_interface_mode,
      g_master_granularity => BYTE,
      g_slave_use_struct   => false,
      g_slave_mode         => g_slave_interface_mode,
      g_slave_granularity  => g_slave_granularity)
    port map (
      clk_sys_i => clk_sys,
      rst_n_i   => reset_n,
		master_i  => cnx_slave_out(c_MASTER_ADAPT),
      master_o  => cnx_slave_in(c_MASTER_ADAPT),
      sl_adr_i(c_wishbone_address_width-1 downto 16)  => (others => '0'),
      sl_adr_i(15 downto 0)   => slave_i.adr(15 downto 0),
      sl_dat_i   => slave_i.dat,
      sl_sel_i   => slave_i.sel,
      sl_cyc_i   => slave_i.cyc,
      sl_stb_i   => slave_i.stb,
      sl_we_i    => slave_i.we,
      sl_dat_o   => slave_o.dat,
      sl_ack_o   => slave_o.ack,
      sl_err_o   => slave_o.err,
      sl_rty_o   => slave_o.rty,
      sl_stall_o => slave_o.stall);      
--		master_i  => cnx_sec_slave_out(c_SEC_MASTER_ADAPT),
--      master_o  => cnx_sec_slave_in(c_SEC_MASTER_ADAPT));

  chipscope_ila_1 : chipscope_ila
    port map (
      CONTROL => CONTROL,
      CLK     => clk_sys,
      TRIG0   => TRIG0,
      TRIG1   => TRIG1,
      TRIG2   => TRIG2,
      TRIG3   => TRIG3);

  chipscope_icon_1 : chipscope_icon
    port map (
      CONTROL0 => CONTROL);
		
end Behavioral;

