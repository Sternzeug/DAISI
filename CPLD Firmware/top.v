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

assign led0 = spi_interface_signal;
assign led1 = spi_controller_signal;
assign led2 = 1'b1;
assign led3 = 1'b1;

assign led4 = 1'b1;
assign led5 = 1'b1;
assign led6 = 1'b1;
assign led7 = reset;//1'b1; // Off


spi_interface spi_interface_inst (	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(spi_interface_signal ));
					
spi_controller spi_controller_inst (	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(spi_controller_signal ));


endmodule
