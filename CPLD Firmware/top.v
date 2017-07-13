module top ( 	stdby_in, stdby1, switch0, switch0_gnd, osc_clk, clock_84_0000, clock_00_0192, clock_00_0096, 
				led0, led1, led2, led3, led4, led5, led6, led7, 
				spi_clk, spi_miso, spi_mosi, spi_csn,
				rs_232_rx, rs_232_tx );

input		stdby_in;
output		stdby1, osc_clk;

input		switch0;
output		switch0_gnd;
output		led0, led1, led2, led3, led4, led5, led6, led7;

inout		spi_clk, spi_miso, spi_mosi;
output		spi_csn;

input		rs_232_rx;
output		rs_232_tx;


output		clock_84_0000;
output    	clock_00_0192;
output reg	clock_00_0096;

assign		switch0_gnd = 1'b0;

wire		stby_flag ;
wire		clock_lock;

wire [7:0]  rs_232_rx_byte;

// Internal Oscillator
defparam OSCH_inst.NOM_FREQ = "7";		//  This is the default frequency

OSCH OSCH_inst ( 
					.STDBY(stdby1 ), 		// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
					.OSC(osc_clk ),
					.SEDSTDBY());		//  this signal is not required if not using SED - see TN1199 for more details.

pll pll_inst (
					.CLKI(osc_clk ),
					.LOCK(clock_lock),
					.CLKOP(clock_84_0000 ),
					.CLKOS(clock_00_0192 ));
					
pwr_cntrllr pcm1 (	
					.USERSTDBY(stdby_in ),
					.CLRFLAG(stby_flag ),
					.CFGSTDBY(1'b0 ),
					.STDBY(stdby1 ),
					.SFLAG(stby_flag ));


wire reset = (~switch0) | (~clock_lock); // NAND

wire data_buffer_signal_1;
wire data_formatter_signal;
wire data_buffer_signal_2;
wire storage_interface_signal;
wire rs232_command_processor_signal;
wire pseudo_adc_signal;
wire regulator_control_signal;
wire sensor_interface_signal;
wire thermal_controller_signal;

assign led0 = ~rs_232_rx_byte[0];
assign led1 = ~rs_232_rx_byte[1];
assign led2 = ~rs_232_rx_byte[2];
assign led3 = ~rs_232_rx_byte[3];

assign led4 = ~rs_232_rx_byte[4];
assign led5 = ~rs_232_rx_byte[5];
assign led6 = ~rs_232_rx_byte[6];
assign led7 = ~rs_232_rx_byte[7];//1'b1; // Off

always@(posedge clock_00_0192 or posedge reset)
	begin
	if(reset)
		begin
			clock_00_0096 <= 1'b0;
		end
	else
		begin
			clock_00_0096 <= ~clock_00_0096;
		end
	end


wire 		wb_cyc;wire 		wb_stb;
wire 		wb_we;
wire [7:0]	wb_adr; 
wire [7:0]	wb_dat_i;wire [7:0]	wb_dat_o;wire 		wb_ack;

efb efb_inst (
					.wb_clk_i(clock_84_0000),
					.wb_rst_i(reset),
					.wb_cyc_i(wb_cyc),
					.wb_stb_i(wb_stb),
					.wb_we_i(wb_we),
					.wb_adr_i(wb_adr), 
					.wb_dat_i(wb_dat_i),
					.wb_dat_o(wb_dat_o),
					.wb_ack_o(wb_ack),
					.spi_clk(spi_clk),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_scsn(1'b1),
					.spi_csn(spi_csn));
					
spi_controller spi_controller_inst (	
					.clock(clock_84_0000 ),
					.reset(reset ),
					.wb_cyc(wb_cyc),
					.wb_stb(wb_stb),
					.wb_we(wb_we),
					.wb_adr(wb_adr),
					.wb_dat_i(wb_dat_i),
					.wb_dat_o(wb_dat_o),
					.wb_ack(wb_ack));
					
data_buffer data_buffer_inst_1 (	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(data_buffer_signal_1 ));
					
data_formatter data_formatter_inst(	
					.clock(clock_84_0000 ),
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
					.clock(clock_00_0096 ),
					.reset(reset ),
					.rx(rs_232_rx ),
					.tx(rs_232_tx ),
					.rx_byte(rs_232_rx_byte));
					
rs232_command_processor rs232_command_processor_inst(	
					.clock(clock_84_0000 ),
					.reset(reset ),
					.signal(rs232_command_processor_signal ));
					
pseudo_adc pseudo_adc_inst(	
					.clock(osc_clk ),
					.reset(reset ),
					.signal(pseudo_adc_signal ));
					
regulator_control regulator_control_inst(	
					.clock(clock_84_0000 ),
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
