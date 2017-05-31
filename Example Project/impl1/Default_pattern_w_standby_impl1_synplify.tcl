#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology MACHXO2
set_option -part LCMXO2_7000HE
set_option -package TG144C
set_option -speed_grade -4

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 100
set_option -auto_constrain_io 1
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe false
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false
set_option -frequency 1
set_option -default_enum_encoding default

#simulation options


#timing analysis options
set_option -num_critical_paths 3
set_option -num_startend_points 0

#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 1


#-- add_file options
set_option -include_path {F:/MachXO2_Breakout_board}
add_file -verilog {F:/MachXO2_Breakout_board/impl1/source/pwr_cntrllr.v}
add_file -verilog {F:/MachXO2_Breakout_board/pseudo_adc.v}

#-- top module name
set_option -top_module Default_w_standby_top

#-- set result format/file last
project -result_file {F:/MachXO2_Breakout_board/impl1/Default_pattern_w_standby_impl1.edi}

#-- error message log file
project -log_file {Default_pattern_w_standby_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run -clean
