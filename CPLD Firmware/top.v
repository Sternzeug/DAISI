module top ( stdby_in, stdby1, switch0, osc_clk, led0, led1, led2, led3, led4, led5, led6, led7 );

input	stdby_in;
output	stdby1, osc_clk;

input	switch0;
output	led0, led1, led2, led3, led4, led5, led6, led7;

wire	stby_flag ;


// Internal Oscillator
defparam OSCH_inst.NOM_FREQ = "2.08";		//  This is the default frequency

OSCH OSCH_inst( 
					.STDBY(stdby1 ), 		// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
					.OSC(osc_clk),
					.SEDSTDBY());		//  this signal is not required if not using SED - see TN1199 for more details.


pwr_cntrllr pcm1 (	
					.USERSTDBY(stdby_in ),
					.CLRFLAG(stby_flag ),
					.CFGSTDBY(1'b0 ),
					.STDBY(stdby1 ),
					.SFLAG(stby_flag ));


wire reset = ~switch0;

wire spi_interface_signal;
wire spi_controller_signal;
wire data_buffer_signal_1;
wire data_formatter_signal;
wire data_buffer_signal_2;
wire storage_interface_signal;
wire rs232_decoder_encoder_signal;
wire rs232_command_processor_signal;
wire pseudo_adc_signal;
wire regulator_control_signal;
wire sensor_interface_signal;
wire thermal_controller_signal;

assign led0 = spi_interface_signal;
assign led1 = spi_controller_signal;
assign led2 = data_buffer_signal_1;
assign led3 = data_formatter_signal;

assign led4 = data_buffer_signal_2;
assign led5 = storage_interface_signal;
assign led6 = rs232_decoder_encoder_signal;
assign led7 = reset;//1'b1; // Off


spi_interface spi_interface_inst (	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(spi_interface_signal ));
					
spi_controller spi_controller_inst (	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(spi_controller_signal ));
					
data_buffer data_buffer_inst_1 (	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(data_buffer_signal_1 ));
					
data_formatter data_formatter_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(data_formatter_signal ));
					
data_buffer data_buffer_inst_2(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(data_buffer_signal_2 ));
					
storage_interface storage_interface_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(storage_interface_signal ));
					
rs232_decoder_encoder rs232_decoder_encoder_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(rs232_decoder_encoder_signal ));
					
rs232_command_processor rs232_command_processor_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(rs232_command_processor_signal ));
					
pseudo_adc pseudo_adc_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(pseudo_adc_signal ));
					
regulator_control regulator_control_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(regulator_control_signal ));
					
sensor_interface sensor_interface_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(sensor_interface_signal ));
					
thermal_controller thermal_controller_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(thermal_controller_signal ));


endmodule
