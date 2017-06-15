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
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false
set_option -frequency 1
set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {/media/sf_Downloads/Code/DAISI/CPLD Firmware}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/top.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/pwr_cntrllr.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/spi_interface.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/spi_controller.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/data_buffer.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/data_formatter.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/storage_interface.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/rs232_decoder_encoder.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/rs232_command_processor.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/pseudo_adc.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/regulator_control.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/sensor_interface.v}
add_file -verilog {/media/sf_Downloads/Code/DAISI/CPLD Firmware/thermal_controller.v}

#-- top module name
set_option -top_module top

#-- set result format/file last
project -result_file {/media/sf_Downloads/Code/DAISI/CPLD Firmware/impl1/DAISI_impl1.edi}

#-- error message log file
project -log_file {DAISI_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
