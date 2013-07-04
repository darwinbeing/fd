---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Fine Delay Main WB Slave
---------------------------------------------------------------------------------------
-- File           : fd_main_wbgen2_pkg.vhd
-- Author         : auto-generated by wbgen2 from fd_main_wishbone_slave.wb
-- Created        : Thu Jul  4 10:40:48 2013
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE fd_main_wishbone_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;

package fd_main_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_fd_main_in_registers is record
    gcr_ddr_locked_i                         : std_logic;
    gcr_fmc_present_i                        : std_logic;
    tcr_dmtd_stat_i                          : std_logic;
    tcr_wr_locked_i                          : std_logic;
    tcr_wr_present_i                         : std_logic;
    tcr_wr_ready_i                           : std_logic;
    tcr_wr_link_i                            : std_logic;
    tm_sech_i                                : std_logic_vector(7 downto 0);
    tm_secl_i                                : std_logic_vector(31 downto 0);
    tm_cycles_i                              : std_logic_vector(27 downto 0);
    tdr_i                                    : std_logic_vector(27 downto 0);
    tdcsr_empty_i                            : std_logic;
    dmtr_in_tag_i                            : std_logic_vector(30 downto 0);
    dmtr_in_rdy_i                            : std_logic;
    dmtr_out_tag_i                           : std_logic_vector(30 downto 0);
    dmtr_out_rdy_i                           : std_logic;
    iecraw_i                                 : std_logic_vector(31 downto 0);
    iectag_i                                 : std_logic_vector(31 downto 0);
    iepd_pdelay_i                            : std_logic_vector(7 downto 0);
    scr_data_i                               : std_logic_vector(23 downto 0);
    scr_ready_i                              : std_logic;
    rcrr_i                                   : std_logic_vector(31 downto 0);
    tsbcr_full_i                             : std_logic;
    tsbcr_empty_i                            : std_logic;
    tsbcr_count_i                            : std_logic_vector(11 downto 0);
    tsbr_sech_i                              : std_logic_vector(7 downto 0);
    tsbr_secl_i                              : std_logic_vector(31 downto 0);
    tsbr_cycles_i                            : std_logic_vector(27 downto 0);
    tsbr_fid_channel_i                       : std_logic_vector(3 downto 0);
    tsbr_fid_fine_i                          : std_logic_vector(11 downto 0);
    tsbr_fid_seqid_i                         : std_logic_vector(15 downto 0);
    i2cr_scl_in_i                            : std_logic;
    i2cr_sda_in_i                            : std_logic;
    tder1_vcxo_freq_i                        : std_logic_vector(31 downto 0);
    tsbr_debug_i                             : std_logic_vector(31 downto 0);
    end record;
  
  constant c_fd_main_in_registers_init_value: t_fd_main_in_registers := (
    gcr_ddr_locked_i => '0',
    gcr_fmc_present_i => '0',
    tcr_dmtd_stat_i => '0',
    tcr_wr_locked_i => '0',
    tcr_wr_present_i => '0',
    tcr_wr_ready_i => '0',
    tcr_wr_link_i => '0',
    tm_sech_i => (others => '0'),
    tm_secl_i => (others => '0'),
    tm_cycles_i => (others => '0'),
    tdr_i => (others => '0'),
    tdcsr_empty_i => '0',
    dmtr_in_tag_i => (others => '0'),
    dmtr_in_rdy_i => '0',
    dmtr_out_tag_i => (others => '0'),
    dmtr_out_rdy_i => '0',
    iecraw_i => (others => '0'),
    iectag_i => (others => '0'),
    iepd_pdelay_i => (others => '0'),
    scr_data_i => (others => '0'),
    scr_ready_i => '0',
    rcrr_i => (others => '0'),
    tsbcr_full_i => '0',
    tsbcr_empty_i => '0',
    tsbcr_count_i => (others => '0'),
    tsbr_sech_i => (others => '0'),
    tsbr_secl_i => (others => '0'),
    tsbr_cycles_i => (others => '0'),
    tsbr_fid_channel_i => (others => '0'),
    tsbr_fid_fine_i => (others => '0'),
    tsbr_fid_seqid_i => (others => '0'),
    i2cr_scl_in_i => '0',
    i2cr_sda_in_i => '0',
    tder1_vcxo_freq_i => (others => '0'),
    tsbr_debug_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_fd_main_out_registers is record
      rstr_rst_fmc_o                           : std_logic;
      rstr_rst_fmc_wr_o                        : std_logic;
      rstr_rst_core_o                          : std_logic;
      rstr_rst_core_wr_o                       : std_logic;
      rstr_lock_o                              : std_logic_vector(15 downto 0);
      rstr_lock_wr_o                           : std_logic;
      gcr_bypass_o                             : std_logic;
      gcr_input_en_o                           : std_logic;
      tcr_wr_enable_o                          : std_logic;
      tcr_cap_time_o                           : std_logic;
      tcr_set_time_o                           : std_logic;
      tm_sech_o                                : std_logic_vector(7 downto 0);
      tm_sech_load_o                           : std_logic;
      tm_secl_o                                : std_logic_vector(31 downto 0);
      tm_secl_load_o                           : std_logic;
      tm_cycles_o                              : std_logic_vector(27 downto 0);
      tm_cycles_load_o                         : std_logic;
      tdr_o                                    : std_logic_vector(27 downto 0);
      tdr_load_o                               : std_logic;
      tdcsr_write_o                            : std_logic;
      tdcsr_read_o                             : std_logic;
      tdcsr_stop_en_o                          : std_logic;
      tdcsr_start_dis_o                        : std_logic;
      tdcsr_start_en_o                         : std_logic;
      tdcsr_stop_dis_o                         : std_logic;
      tdcsr_alutrig_o                          : std_logic;
      calr_cal_pulse_o                         : std_logic;
      calr_cal_pps_o                           : std_logic;
      calr_cal_dmtd_o                          : std_logic;
      calr_psel_o                              : std_logic_vector(3 downto 0);
      adsfr_o                                  : std_logic_vector(17 downto 0);
      atmcr_c_thr_o                            : std_logic_vector(7 downto 0);
      atmcr_f_thr_o                            : std_logic_vector(22 downto 0);
      asor_offset_o                            : std_logic_vector(22 downto 0);
      iepd_rst_stat_o                          : std_logic;
      scr_data_o                               : std_logic_vector(23 downto 0);
      scr_data_load_o                          : std_logic;
      scr_sel_dac_o                            : std_logic;
      scr_sel_pll_o                            : std_logic;
      scr_sel_gpio_o                           : std_logic;
      scr_cpol_o                               : std_logic;
      scr_start_o                              : std_logic;
      tsbcr_chan_mask_o                        : std_logic_vector(4 downto 0);
      tsbcr_enable_o                           : std_logic;
      tsbcr_purge_o                            : std_logic;
      tsbcr_rst_seq_o                          : std_logic;
      tsbcr_raw_o                              : std_logic;
      tsbir_timeout_o                          : std_logic_vector(9 downto 0);
      tsbir_threshold_o                        : std_logic_vector(11 downto 0);
      i2cr_scl_out_o                           : std_logic;
      i2cr_sda_out_o                           : std_logic;
      tder2_pelt_drive_o                       : std_logic_vector(31 downto 0);
      tsbr_advance_adv_o                       : std_logic;
      end record;
    
    constant c_fd_main_out_registers_init_value: t_fd_main_out_registers := (
      rstr_rst_fmc_o => '0',
      rstr_rst_fmc_wr_o => '0',
      rstr_rst_core_o => '0',
      rstr_rst_core_wr_o => '0',
      rstr_lock_o => (others => '0'),
      rstr_lock_wr_o => '0',
      gcr_bypass_o => '0',
      gcr_input_en_o => '0',
      tcr_wr_enable_o => '0',
      tcr_cap_time_o => '0',
      tcr_set_time_o => '0',
      tm_sech_o => (others => '0'),
      tm_sech_load_o => '0',
      tm_secl_o => (others => '0'),
      tm_secl_load_o => '0',
      tm_cycles_o => (others => '0'),
      tm_cycles_load_o => '0',
      tdr_o => (others => '0'),
      tdr_load_o => '0',
      tdcsr_write_o => '0',
      tdcsr_read_o => '0',
      tdcsr_stop_en_o => '0',
      tdcsr_start_dis_o => '0',
      tdcsr_start_en_o => '0',
      tdcsr_stop_dis_o => '0',
      tdcsr_alutrig_o => '0',
      calr_cal_pulse_o => '0',
      calr_cal_pps_o => '0',
      calr_cal_dmtd_o => '0',
      calr_psel_o => (others => '0'),
      adsfr_o => (others => '0'),
      atmcr_c_thr_o => (others => '0'),
      atmcr_f_thr_o => (others => '0'),
      asor_offset_o => (others => '0'),
      iepd_rst_stat_o => '0',
      scr_data_o => (others => '0'),
      scr_data_load_o => '0',
      scr_sel_dac_o => '0',
      scr_sel_pll_o => '0',
      scr_sel_gpio_o => '0',
      scr_cpol_o => '0',
      scr_start_o => '0',
      tsbcr_chan_mask_o => (others => '0'),
      tsbcr_enable_o => '0',
      tsbcr_purge_o => '0',
      tsbcr_rst_seq_o => '0',
      tsbcr_raw_o => '0',
      tsbir_timeout_o => (others => '0'),
      tsbir_threshold_o => (others => '0'),
      i2cr_scl_out_o => '0',
      i2cr_sda_out_o => '0',
      tder2_pelt_drive_o => (others => '0'),
      tsbr_advance_adv_o => '0'
      );
    function "or" (left, right: t_fd_main_in_registers) return t_fd_main_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body fd_main_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if(x = 'X' or x = 'U') then
return '0';
else
return x;
end if; 
end function;
function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
variable tmp: std_logic_vector(x'length-1 downto 0);
begin
for i in 0 to x'length-1 loop
if(x(i) = 'X' or x(i) = 'U') then
tmp(i):= '0';
else
tmp(i):=x(i);
end if; 
end loop; 
return tmp;
end function;
function "or" (left, right: t_fd_main_in_registers) return t_fd_main_in_registers is
variable tmp: t_fd_main_in_registers;
begin
tmp.gcr_ddr_locked_i := f_x_to_zero(left.gcr_ddr_locked_i) or f_x_to_zero(right.gcr_ddr_locked_i);
tmp.gcr_fmc_present_i := f_x_to_zero(left.gcr_fmc_present_i) or f_x_to_zero(right.gcr_fmc_present_i);
tmp.tcr_dmtd_stat_i := f_x_to_zero(left.tcr_dmtd_stat_i) or f_x_to_zero(right.tcr_dmtd_stat_i);
tmp.tcr_wr_locked_i := f_x_to_zero(left.tcr_wr_locked_i) or f_x_to_zero(right.tcr_wr_locked_i);
tmp.tcr_wr_present_i := f_x_to_zero(left.tcr_wr_present_i) or f_x_to_zero(right.tcr_wr_present_i);
tmp.tcr_wr_ready_i := f_x_to_zero(left.tcr_wr_ready_i) or f_x_to_zero(right.tcr_wr_ready_i);
tmp.tcr_wr_link_i := f_x_to_zero(left.tcr_wr_link_i) or f_x_to_zero(right.tcr_wr_link_i);
tmp.tm_sech_i := f_x_to_zero(left.tm_sech_i) or f_x_to_zero(right.tm_sech_i);
tmp.tm_secl_i := f_x_to_zero(left.tm_secl_i) or f_x_to_zero(right.tm_secl_i);
tmp.tm_cycles_i := f_x_to_zero(left.tm_cycles_i) or f_x_to_zero(right.tm_cycles_i);
tmp.tdr_i := f_x_to_zero(left.tdr_i) or f_x_to_zero(right.tdr_i);
tmp.tdcsr_empty_i := f_x_to_zero(left.tdcsr_empty_i) or f_x_to_zero(right.tdcsr_empty_i);
tmp.dmtr_in_tag_i := f_x_to_zero(left.dmtr_in_tag_i) or f_x_to_zero(right.dmtr_in_tag_i);
tmp.dmtr_in_rdy_i := f_x_to_zero(left.dmtr_in_rdy_i) or f_x_to_zero(right.dmtr_in_rdy_i);
tmp.dmtr_out_tag_i := f_x_to_zero(left.dmtr_out_tag_i) or f_x_to_zero(right.dmtr_out_tag_i);
tmp.dmtr_out_rdy_i := f_x_to_zero(left.dmtr_out_rdy_i) or f_x_to_zero(right.dmtr_out_rdy_i);
tmp.iecraw_i := f_x_to_zero(left.iecraw_i) or f_x_to_zero(right.iecraw_i);
tmp.iectag_i := f_x_to_zero(left.iectag_i) or f_x_to_zero(right.iectag_i);
tmp.iepd_pdelay_i := f_x_to_zero(left.iepd_pdelay_i) or f_x_to_zero(right.iepd_pdelay_i);
tmp.scr_data_i := f_x_to_zero(left.scr_data_i) or f_x_to_zero(right.scr_data_i);
tmp.scr_ready_i := f_x_to_zero(left.scr_ready_i) or f_x_to_zero(right.scr_ready_i);
tmp.rcrr_i := f_x_to_zero(left.rcrr_i) or f_x_to_zero(right.rcrr_i);
tmp.tsbcr_full_i := f_x_to_zero(left.tsbcr_full_i) or f_x_to_zero(right.tsbcr_full_i);
tmp.tsbcr_empty_i := f_x_to_zero(left.tsbcr_empty_i) or f_x_to_zero(right.tsbcr_empty_i);
tmp.tsbcr_count_i := f_x_to_zero(left.tsbcr_count_i) or f_x_to_zero(right.tsbcr_count_i);
tmp.tsbr_sech_i := f_x_to_zero(left.tsbr_sech_i) or f_x_to_zero(right.tsbr_sech_i);
tmp.tsbr_secl_i := f_x_to_zero(left.tsbr_secl_i) or f_x_to_zero(right.tsbr_secl_i);
tmp.tsbr_cycles_i := f_x_to_zero(left.tsbr_cycles_i) or f_x_to_zero(right.tsbr_cycles_i);
tmp.tsbr_fid_channel_i := f_x_to_zero(left.tsbr_fid_channel_i) or f_x_to_zero(right.tsbr_fid_channel_i);
tmp.tsbr_fid_fine_i := f_x_to_zero(left.tsbr_fid_fine_i) or f_x_to_zero(right.tsbr_fid_fine_i);
tmp.tsbr_fid_seqid_i := f_x_to_zero(left.tsbr_fid_seqid_i) or f_x_to_zero(right.tsbr_fid_seqid_i);
tmp.i2cr_scl_in_i := f_x_to_zero(left.i2cr_scl_in_i) or f_x_to_zero(right.i2cr_scl_in_i);
tmp.i2cr_sda_in_i := f_x_to_zero(left.i2cr_sda_in_i) or f_x_to_zero(right.i2cr_sda_in_i);
tmp.tder1_vcxo_freq_i := f_x_to_zero(left.tder1_vcxo_freq_i) or f_x_to_zero(right.tder1_vcxo_freq_i);
tmp.tsbr_debug_i := f_x_to_zero(left.tsbr_debug_i) or f_x_to_zero(right.tsbr_debug_i);
return tmp;
end function;
end package body;
