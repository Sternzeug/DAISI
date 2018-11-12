module top ( 	stdby_in, stdby1, switch0, //switch0_gnd,
				//led0, led1, led2, led3, led4, led5, led6, led7, 
				regulator_12v_en, regulator_3_3v_sd_en, regulator_3_3v_adc_en,
				spi_clk, spi_miso, spi_mosi, spi_csn0, 
				spi_csn1, spi_csn2, spi_csn3, spi_csn4, 
				adc_drdy, adc_clock, adc_data_0, adc_data_1, adc_data_2, adc_data_3,
				rs232_rx, rs232_tx,
				temp_rxtx,
				therm_en1, therm_en2, therm_en3, therm_en4,
				regulator_main_source, regulator_12_source, regulator_5_source, regulator_3_3_main_source, regulator_3_3_adc_source, regulator_3_3_sd_source,
				test_a, test_b, test_c, test_d, test_e, test_f);

input		stdby_in;
output		stdby1;

input		switch0;
//output		switch0_gnd;
//output		led0, led1, led2, led3, led4, led5, led6, led7;

output      regulator_12v_en, regulator_3_3v_sd_en, regulator_3_3v_adc_en;

output		spi_clk, spi_mosi;
input       spi_miso;
output		spi_csn0, spi_csn1, spi_csn2, spi_csn3, spi_csn4;

input       adc_drdy, adc_clock, adc_data_0, adc_data_1, adc_data_2, adc_data_3;

input		rs232_rx;
output		rs232_tx;

inout       temp_rxtx;



output reg  therm_en1, therm_en2, therm_en3, therm_en4;

inout       regulator_main_source, regulator_12_source, regulator_5_source, regulator_3_3_main_source, regulator_3_3_adc_source, regulator_3_3_sd_source;

output      test_a, test_b, test_c, test_d, test_e, test_f;

wire		clock_126_000;
wire		clock_42_0000;
wire    	clock_00_0192;
reg	        clock_00_0048;

reg         switch0_db;
wire		clock_lock;
wire        rs232_reset;

wire        reset = (~switch0_db) | (~clock_lock) | rs232_reset; // NAND - with reset switch
//wire        reset = (~clock_lock) | rs232_reset; // NAND

//assign		switch0_gnd = 1'b0;

wire		stby_flag ;


wire [5:0]  spi_csn;
wire        sd_cs;

assign      spi_csn0 = spi_csn[0];
assign      spi_csn1 = spi_csn[1];
assign      spi_csn2 = spi_csn[2];
assign      spi_csn3 = reset ? 1'b1: spi_csn[3];
assign      spi_csn4 = reset ? 1'b1: spi_csn[4];

wire        test_signal_120ns;

wire        temp_tx_switch;

wire        regulator_3_3v_adc_en_command_processor;
wire        regulator_3_3v_sd_en_command_processor;
wire        regulator_3_3v_adc_en_spi_controller;
wire        regulator_3_3v_sd_en_spi_controller;

assign      regulator_3_3v_adc_en  = regulator_3_3v_adc_en_command_processor | regulator_3_3v_adc_en_spi_controller;
assign      regulator_3_3v_sd_en   = regulator_3_3v_sd_en_command_processor  | regulator_3_3v_sd_en_spi_controller;

// Internal Oscillator
defparam OSCH_inst.NOM_FREQ = "7";		//  This is the default frequency

OSCH OSCH_inst ( 
					.STDBY(1'b0),//(stdby1 ), 		// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
					.OSC(osc_clk ),
					.SEDSTDBY());		//  this signal is not required if not using SED - see TN1199 for more details.

pll pll_inst (
					.CLKI(osc_clk ),
					.LOCK(clock_lock),
					.CLKOP(clock_126_000 ),
					.CLKOS(clock_42_0000 ),
					.CLKOS2(clock_00_0192 ));
					
pwr_cntrllr pcm1 (	
					.USERSTDBY(stdby_in ),
					.CLRFLAG(stby_flag ),
					.CFGSTDBY(1'b0 ),
					.STDBY(stdby1 ),
					.SFLAG(stby_flag ));

reg         test_signal_120ns_reg;					
reg [7:0]   test_signal_counter;

// Generate a 120ns pulse repeating every 3us
assign test_signal_120ns = (test_signal_120ns_reg) ? 1'b1 : 1'bz;

always@(posedge clock_42_0000 or posedge reset)
	begin
	if(reset)
	    begin
	        test_signal_120ns_reg   <= 0;
	        test_signal_counter     <= 0;
        end
	else
		begin
	        test_signal_counter         <= test_signal_counter + 1;
	        if(test_signal_counter <= 10)    
	            test_signal_120ns_reg   <= 1'b1;
	        else
	            test_signal_120ns_reg   <= 1'b0;
		end
	end


wire    buffer_full;
reg     buffer_full_latch;

always@(posedge clock_42_0000 or posedge reset)
	begin
	if(reset)
	    buffer_full_latch <= 1'b0;
	else
	    if(buffer_full == 1'b1)
	        buffer_full_latch <= 1'b1;
	end

wire adc_init;
wire sd_init_1;
wire sd_init_2;
wire sd_write_error;

//          LEDs 1'b1 = Off, 1'b0 = On
/*assign led0 = ~rs232_rx_command_valid[0];
assign led1 = ~rs232_rx_command_valid[1];
assign led2 = ~rs232_rx_command_valid[2];
assign led3 = ~rs232_rx_command_valid[3];

assign led4 = ~adc_init;
assign led5 = ~sd_init;
assign led6 = ~buffer_full_latch; //~(buffer_half_filled | buffer_full_latch);
assign led7 = ~sd_write_error;   */                           

reg [1:0] clk_div;

wire reset_c = ~clock_lock;

always@(posedge clock_00_0192 or posedge reset_c)
	begin
	if(reset_c)
		begin
		    clk_div         <= 2'b00;
			clock_00_0048   <= 1'b0;
		end
	else
		begin
		    clk_div         <= clk_div + 2'b01;
			clock_00_0048   <= clk_div[1];
		end
	end	


reg         temp_sample_pulse;
reg [13:0]  temp_clock_counter;

always@(posedge clock_00_0048 or posedge reset_c)
    begin
        if(reset_c)
            begin
                temp_sample_pulse   <= 1'b0;
                temp_clock_counter  <= 0;
            end
        else
            begin
                if(temp_clock_counter == 14'h2580)
                    begin
                        temp_sample_pulse   <= 1'b1;
                        temp_clock_counter  <= 0;
                    end
                else
                    begin
                        temp_sample_pulse   <= 1'b0;
                        temp_clock_counter  <= temp_clock_counter + 1;
                    end
            end
    end

reg         ms_pulse;
reg [16:0]  ms_counter;

wire        therm_reset_control;
reg         therm_reset_control_reg;
reg         therm_reset;

always@(posedge clock_42_0000 or posedge reset_c)
    begin
        if(reset_c)
            begin
                ms_pulse                <= 1'b0;
                ms_counter              <= 0;
                therm_reset_control_reg <= 1'b0;
                therm_reset             <= 1'b0;
            end
        else
            begin
                if(therm_reset_control)
                    therm_reset_control_reg <= 1'b1;
            
                //if(ms_counter == 17'd84000)
                if(ms_counter == 17'd42000)
                    begin
                        ms_pulse    <= 1'b1;
                        ms_counter  <= 0;
                        
                        if(therm_reset_control_reg)
                            begin
                                therm_reset_control_reg <= 1'b0;
                                therm_reset             <= 1'b1;
                            end
                        else
                            therm_reset                 <= 1'b0;
                    end
                else
                    begin
                        ms_pulse    <= 1'b0;
                        ms_counter  <= ms_counter + 1;
                    end
            end
    end
    
    
reg [3:0]   debounce_counter;

always@(posedge clock_00_0048 or posedge reset_c)
    begin
        if(reset_c)
            begin
                switch0_db              <= 1'b0;
                debounce_counter        <= 4'h0;
            end
        else
            begin
                if(debounce_counter == 4'hF)
                    switch0_db          <= switch0;
                if((switch0_db != switch0) && (debounce_counter != 4'hF))
                    debounce_counter    <= debounce_counter + 1;
                else
                    debounce_counter    <= 4'h0;
            end
    
    end
    
    


wire [19:0]     regulator_main_count;
wire [19:0]     regulator_12_count;
wire [19:0]     regulator_5_count;
wire [19:0]     regulator_3_3_main_count;
wire [19:0]     regulator_3_3_adc_count;
wire [19:0]     regulator_3_3_sd_count;

pseudo_adc pseudo_adc_regulator_main (
					.clock(clock_42_0000),
					.reset(reset),
					.source(regulator_main_source),
					.adc_count(regulator_main_count));
					
pseudo_adc pseudo_adc_regulator_12 (
					.clock(clock_42_0000),
					.reset(reset),
					.source(regulator_12_source),
					.adc_count(regulator_12_count));
					
pseudo_adc pseudo_adc_regulator_5 (
					.clock(clock_42_0000),
					.reset(reset),
					.source(regulator_5_source),
					.adc_count(regulator_5_count));					

pseudo_adc pseudo_adc_regulator_3_3_main (
					.clock(clock_42_0000),
					.reset(reset),
					.source(regulator_3_3_main_source),
					.adc_count(regulator_3_3_main_count));										

pseudo_adc pseudo_adc_regulator_3_3_adc (
					.clock(clock_42_0000),
					.reset(reset),
					.source(regulator_3_3_adc_source),
					.adc_count(regulator_3_3_adc_count));
    
pseudo_adc pseudo_adc_regulator_3_3_sd (
					.clock(clock_42_0000),
					.reset(reset),
					.source(regulator_3_3_sd_source),
					.adc_count(regulator_3_3_sd_count));


wire 		wb_cyc;
wire 		wb_stb;
wire 		wb_we;
wire [7:0]	wb_adr; 
wire [7:0]	wb_dat_i;
wire [7:0]	wb_dat_o;
wire 		wb_ack;

efb efb_inst (
					.wb_clk_i(clock_126_000),
					//.wb_clk_i(osc_clk),
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
					.spi_csn(spi_csn)
					);

wire        adc_sample_start;					
wire [31:0]	adc_buffer_data;
wire [31:0]	adc_data_ch1;
wire [31:0]	adc_data_ch2;
wire [31:0]	adc_data_ch3;
wire [31:0]	adc_data_ch4;
wire [31:0]	adc_data_ch5;
wire [31:0]	adc_data_ch6;
wire [31:0]	adc_data_ch7;
wire [31:0]	adc_data_ch8;

wire [31:0] buffer_data;
wire        buffer_write_enable;
wire        buffer_write_enable_adc;
wire        buffer_read_enable;
wire        buffer_empty;
wire        buffer_almost_empty;
wire        buffer_almost_full;

wire        system_idle;

wire        sd_busy;
wire        sd_write_ready;

parameter MAX_BYTES	= 78;
					
wire [MAX_BYTES*8-1:0]      record_bytes;
wire [7:0]                  record_num_bytes;
wire                        record_valid;

wire                        adc_disable;
wire                        sd_disable;
					
spi_controller #(.MAX_BYTES(MAX_BYTES)) spi_controller_inst (
                    .clock_126(clock_126_000 ),	
					.clock(clock_42_0000 ),
					.reset(reset ),
					.wb_cyc(wb_cyc),
					.wb_stb(wb_stb),
					.wb_we(wb_we),
					.wb_adr(wb_adr),
					.wb_dat_i(wb_dat_i),
					.wb_dat_o(wb_dat_o),
					.wb_ack(wb_ack),
					.adc_sample_start(adc_sample_start),
					.buffer_read_enable(buffer_read_enable),
					.buffer_data(buffer_data),
					.buffer_ready(!buffer_almost_empty),
					.adc_disable(adc_disable),
					.sd_disable(sd_disable),
					.adc_init(adc_init),
					.sd_init_1(sd_init_1),
					.sd_init_2(sd_init_2),
					.sd_write_error(sd_write_error),
					.sd_write_ready(sd_write_ready),
					.sd_busy(sd_busy),
					.ms_pulse(ms_pulse),
					.regulator_3_3v_adc_en(regulator_3_3v_adc_en_spi_controller),
					.regulator_3_3v_sd_en(regulator_3_3v_sd_en_spi_controller),
					.record_bytes(record_bytes),
                    .record_num_bytes(record_num_bytes),
					.record_valid(record_valid));
					
wire                adc_event_detected_ch1;
wire                adc_event_detected_ch2;
wire                adc_event_detected_ch3;
wire                adc_event_detected_ch4;
wire                adc_event_detected_ch5;
wire                adc_event_detected_ch6;
wire                adc_event_detected_ch7;
wire                adc_event_detected_ch8;
					
adc_serial_interface adc_serial_interface_inst (	
					.clock(clock_42_0000 ),
					.reset(reset ),
					.start(adc_sample_start),
					.sd_write_ready(sd_write_ready),
					.adc_data_ready(adc_drdy),
					.adc_clock(adc_clock),
					.adc_data_0(adc_data_0),
					.adc_data_1(adc_data_1),
					.adc_channel_data_ch1(adc_data_ch1),
					.adc_channel_data_ch2(adc_data_ch2),
					.adc_channel_data_ch3(adc_data_ch3),
					.adc_channel_data_ch4(adc_data_ch4),
					.adc_channel_data_ch5(adc_data_ch5),
					.adc_channel_data_ch6(adc_data_ch6),
					.adc_channel_data_ch7(adc_data_ch7),
					.adc_channel_data_ch8(adc_data_ch8),
					.adc_event_detected_ch1(adc_event_detected_ch1),
					.adc_event_detected_ch2(adc_event_detected_ch2),
					.adc_event_detected_ch3(adc_event_detected_ch3),
					.adc_event_detected_ch4(adc_event_detected_ch4),
					.adc_event_detected_ch5(adc_event_detected_ch5),
					.adc_event_detected_ch6(adc_event_detected_ch6),
					.adc_event_detected_ch7(adc_event_detected_ch7),
					.adc_event_detected_ch8(adc_event_detected_ch8),
					.adc_buffer_data(adc_buffer_data),
					.buffer_write_enable(buffer_write_enable_adc),
					.buffer_full(buffer_almost_full));					

assign buffer_write_enable = (system_idle) ? 1'b0 : buffer_write_enable_adc;
					
fifo_buffer fifo_buffer_inst (
                    .Data(adc_buffer_data), 
                    .WrClock(clock_42_0000), 
                    .RdClock(clock_42_0000), 
                    .WrEn(buffer_write_enable), 
                    .RdEn(buffer_read_enable), 
                    .Reset(reset), 
                    .RPReset(reset), 
                    .Q(buffer_data), 
                    .Empty(buffer_empty), 
                    .AlmostEmpty(buffer_almost_empty),
                    .Full(buffer_full),
                    .AlmostFull(buffer_almost_full)
                    );


// Thermal control PWM generation
reg  [5:0]  temp_pwm_count;
wire [5:0]  therm_pwm1;
wire [5:0]  therm_pwm2;
wire [5:0]  therm_pwm3;
wire [5:0]  therm_pwm4;
wire [5:0]  therm_controller_pwm1;
wire [5:0]  therm_controller_pwm2;
wire [5:0]  therm_controller_pwm3;
wire [5:0]  therm_controller_pwm4;
reg  [5:0]  therm_override_pwm1;
reg  [5:0]  therm_override_pwm2;
reg  [5:0]  therm_override_pwm3;
reg  [5:0]  therm_override_pwm4;
wire        therm_override_1;
wire        therm_override_2;
wire        therm_override_3;
wire        therm_override_4;
wire        therm_increment_1;
wire        therm_increment_2;
wire        therm_increment_3;
wire        therm_increment_4;
wire        therm_decrement_1;
wire        therm_decrement_2;
wire        therm_decrement_3;
wire        therm_decrement_4;
reg         therm_increment_1_reg;
reg         therm_increment_2_reg;
reg         therm_increment_3_reg;
reg         therm_increment_4_reg;
reg         therm_decrement_1_reg;
reg         therm_decrement_2_reg;
reg         therm_decrement_3_reg;
reg         therm_decrement_4_reg;

assign therm_pwm1 = (therm_override_1) ? therm_override_pwm1 : therm_controller_pwm1;
assign therm_pwm2 = (therm_override_2) ? therm_override_pwm2 : therm_controller_pwm2;
assign therm_pwm3 = (therm_override_3) ? therm_override_pwm3 : therm_controller_pwm3;
assign therm_pwm4 = (therm_override_4) ? therm_override_pwm4 : therm_controller_pwm4;

always@(posedge clock_00_0048 or posedge reset)
    begin
        if(reset)
            begin
                temp_pwm_count  <= 6'h00;
                therm_en1       <= 1'b0;
                therm_en2       <= 1'b0;
                therm_en3       <= 1'b0;
                therm_en4       <= 1'b0;
                
                therm_override_pwm1 <= 0;
                therm_override_pwm2 <= 0;
                therm_override_pwm3 <= 0;
                therm_override_pwm4 <= 0;
                
                therm_increment_1_reg   <= 1'b0;
                therm_increment_2_reg   <= 1'b0;
                therm_increment_3_reg   <= 1'b0;
                therm_increment_4_reg   <= 1'b0;
                therm_decrement_1_reg   <= 1'b0;
                therm_decrement_2_reg   <= 1'b0;
                therm_decrement_3_reg   <= 1'b0;
                therm_decrement_4_reg   <= 1'b0;
            end
        else
            begin
            
                therm_increment_1_reg   <= therm_increment_1;
                therm_increment_2_reg   <= therm_increment_2;
                therm_increment_3_reg   <= therm_increment_3;
                therm_increment_4_reg   <= therm_increment_4;
                therm_decrement_1_reg   <= therm_decrement_1;
                therm_decrement_2_reg   <= therm_decrement_2;
                therm_decrement_3_reg   <= therm_decrement_3;
                therm_decrement_4_reg   <= therm_decrement_4;
                
                
                if(~therm_increment_1_reg && therm_increment_1)
                    begin
                        if(therm_override_pwm1 <= 6'h39)
                            therm_override_pwm1 <= therm_override_pwm1 + 6;
                        else
                            therm_override_pwm1 <= 6'h3F;
                    end
                else if(~therm_decrement_1_reg && therm_decrement_1)
                    begin
                        if(therm_override_pwm1 >= 6'h6)
                            therm_override_pwm1 <= therm_override_pwm1 - 6;
                        else
                            therm_override_pwm1 <= 6'h00;
                    end
                    
                if(~therm_increment_2_reg && therm_increment_2)
                    begin
                        if(therm_override_pwm2 <= 6'h39)
                            therm_override_pwm2 <= therm_override_pwm2 + 6;
                        else
                            therm_override_pwm2 <= 6'h3F;
                    end
                else if(~therm_decrement_2_reg && therm_decrement_2)
                    begin
                        if(therm_override_pwm2 >= 6'h6)
                            therm_override_pwm2 <= therm_override_pwm2 - 6;
                        else
                            therm_override_pwm2 <= 6'h00;
                    end
                    
                if(~therm_increment_3_reg && therm_increment_3)
                    begin
                        if(therm_override_pwm3 <= 6'h39)
                            therm_override_pwm3 <= therm_override_pwm3 + 6;
                        else
                            therm_override_pwm3 <= 6'h3F;
                    end
                else if(~therm_decrement_3_reg && therm_decrement_3)
                    begin
                        if(therm_override_pwm3 >= 6'h6)
                            therm_override_pwm3 <= therm_override_pwm3 - 6;
                        else
                            therm_override_pwm3 <= 6'h00;
                    end
                    
                if(~therm_increment_4_reg && therm_increment_4)
                    begin
                        if(therm_override_pwm4 <= 6'h39)
                            therm_override_pwm4 <= therm_override_pwm4 + 6;
                        else
                            therm_override_pwm4 <= 6'h3F;
                    end
                else if(~therm_decrement_4_reg && therm_decrement_4)
                    begin
                        if(therm_override_pwm4 >= 6'h6)
                            therm_override_pwm4 <= therm_override_pwm4 - 6;
                        else
                            therm_override_pwm4 <= 6'h00;
                    end
            
                temp_pwm_count  <= temp_pwm_count + 1;
                
                if((therm_pwm1 != 6'h00) && (temp_pwm_count <= therm_pwm1))
                    therm_en1   <= 1'b1;
                else
                    therm_en1   <= 1'b0;
                    
                if((therm_pwm2 != 6'h00) && (temp_pwm_count <= therm_pwm2))
                    therm_en2   <= 1'b1;
                else
                    therm_en2   <= 1'b0;
                    
                if((therm_pwm3 != 6'h00) && (temp_pwm_count <= therm_pwm3))
                    therm_en3   <= 1'b1;
                else
                    therm_en3   <= 1'b0;
                    
                if((therm_pwm4 != 6'h00) && (temp_pwm_count <= therm_pwm4))
                    therm_en4   <= 1'b1;
                else
                    therm_en4   <= 1'b0;
            end

    end


parameter TEMP_MAX_BYTES	= 5;
					
wire [TEMP_MAX_BYTES*8-1:0]     temp_tx_bytes;
wire [3:0]                      temp_tx_num_bytes;
wire                            temp_tx_valid;
wire [7:0]                      temp_rx_byte;
wire		                    temp_rx_valid;
					
temp_decoder_encoder temp_decoder_encoder_inst(	
					.clock(clock_00_0048 ),
					.clock_4x(clock_00_0192),
					.reset(reset | therm_reset),
					.rxtx(temp_rxtx ),
					.rx_valid(temp_rx_valid),
					.rx_byte(temp_rx_byte),
					.tx_bytes(temp_tx_bytes),
					.tx_num_bytes(temp_tx_num_bytes),
					.tx_valid(temp_tx_valid),
					.tx_switch(temp_tx_switch));
			
wire [15:0]  temp1_value;
wire [15:0]  temp2_value;
wire [15:0]  temp3_value;
wire [15:0]  temp4_value;
					
thermal_controller thermal_controller_inst(	
					.clock(clock_42_0000 ),
					.reset(reset | therm_reset),
					.temp_sample_pulse(temp_sample_pulse),
                    .temp_rx_valid(temp_rx_valid),
					.temp_rx_byte(temp_rx_byte),
					.temp_tx_bytes(temp_tx_bytes),
					.temp_tx_num_bytes(temp_tx_num_bytes),
					.temp_tx_valid(temp_tx_valid),
					.temp1_value(temp1_value),
					.temp2_value(temp2_value),
					.temp3_value(temp3_value),
					.temp4_value(temp4_value),
					.therm_pwm1(therm_controller_pwm1),
					.therm_pwm2(therm_controller_pwm2),
					.therm_pwm3(therm_controller_pwm3),
					.therm_pwm4(therm_controller_pwm4)
					);


wire [7:0]                  rs232_rx_byte;
wire		                rs232_rx_valid;
wire [7:0]                  rs232_rx_command_valid;


wire                rs232_buffer_write_enable;
wire [7:0]          rs232_record_byte;
wire                rs232_buffer_read_enable;
wire [7:0]          rs232_tx_buffer_byte;
wire                rs232_buffer_empty;
wire                rs232_buffer_full;
					
rs232_decoder_encoder rs232_decoder_encoder_inst(	
					.clock(clock_00_0048 ),
					.clock_4x(clock_00_0192),
					.reset(reset ),
					.rx(rs232_rx ),
					.tx(rs232_tx ),
					.rx_valid(rs232_rx_valid),
					.rx_byte(rs232_rx_byte),
					.tx_buffer_empty(rs232_buffer_empty),
					.tx_buffer_read_enable(rs232_buffer_read_enable),
					.tx_buffer_byte(rs232_tx_buffer_byte)
					);		
					
fifo_buffer_rs232_tx fifo_buffer_rs232_inst (
                    .Data(rs232_record_byte), 
                    .WrClock(clock_42_0000), 
                    .RdClock(clock_00_0048), 
                    .WrEn(rs232_buffer_write_enable), 
                    .RdEn(rs232_buffer_read_enable), 
                    .Reset(reset), 
                    .RPReset(reset), 
                    .Q(rs232_tx_buffer_byte), 
                    .Empty(rs232_buffer_empty), 
                    .Full(rs232_buffer_full)
                    );

					
command_processor #(.MAX_BYTES(MAX_BYTES)) command_processor_inst(
					.clock(clock_42_0000 ),
					.reset(reset ),
					
					.regulator_12v_en(regulator_12v_en),
					.regulator_3_3v_sd_en(regulator_3_3v_sd_en_command_processor),
					.regulator_3_3v_adc_en(regulator_3_3v_adc_en_command_processor),
					
					.regulator_12v_en_sup(regulator_12v_en),
					.regulator_3_3v_sd_en_sup(regulator_3_3v_sd_en),
					.regulator_3_3v_adc_en_sup(regulator_3_3v_adc_en),
					
					.ms_pulse(ms_pulse),
					.rs232_reset(rs232_reset),
					.rs232_rx_valid(rs232_rx_valid),
					.rs232_rx_byte(rs232_rx_byte),
					.command_valid(rs232_rx_command_valid),
					
					.rs232_buffer_full(rs232_buffer_full), 
					.rs232_buffer_write_enable(rs232_buffer_write_enable),
					.rs232_record_byte(rs232_record_byte),

					.rs232_tx_bytes(record_bytes),
					.rs232_tx_byte_count(record_num_bytes),
					.rs232_tx_valid(record_valid),
					
					.temp1_value(temp1_value),
					.temp2_value(temp2_value),
					.temp3_value(temp3_value),
					.temp4_value(temp4_value),
					.therm_pwm1(therm_pwm1),
					.therm_pwm2(therm_pwm2),
					.therm_pwm3(therm_pwm3),
					.therm_pwm4(therm_pwm4),
					
					.therm_override_1(therm_override_1),
					.therm_override_2(therm_override_2),
					.therm_override_3(therm_override_3),
					.therm_override_4(therm_override_4),
					.therm_increment_1(therm_increment_1),
					.therm_increment_2(therm_increment_2),
					.therm_increment_3(therm_increment_3),
					.therm_increment_4(therm_increment_4),
					.therm_decrement_1(therm_decrement_1),
					.therm_decrement_2(therm_decrement_2),
					.therm_decrement_3(therm_decrement_3),
					.therm_decrement_4(therm_decrement_4),
					.therm_reset(therm_reset_control),
					
					.system_idle(system_idle),
					.adc_disable(adc_disable),
					.sd_disable(sd_disable),
					
					.adc_init(adc_init),
					.sd_init_1(sd_init_1),
					.sd_init_2(sd_init_2),
					.sd_write_ready(sd_write_ready),
					
					.buffer_full(buffer_full),
					.buffer_full_latch(buffer_full_latch),

					.adc_data_ch1(adc_data_ch1),
					.adc_data_ch2(adc_data_ch2),
					.adc_data_ch3(adc_data_ch3),
					.adc_data_ch4(adc_data_ch4),
					.adc_data_ch5(adc_data_ch5),
					.adc_data_ch6(adc_data_ch6),
					.adc_data_ch7(adc_data_ch7),
					.adc_data_ch8(adc_data_ch8),
					
					.adc_event_detected_ch1(adc_event_detected_ch1),
					.adc_event_detected_ch2(adc_event_detected_ch2),
                    .adc_event_detected_ch3(adc_event_detected_ch3), 
                    .adc_event_detected_ch4(adc_event_detected_ch4),
                    .adc_event_detected_ch5(adc_event_detected_ch5), 
                    .adc_event_detected_ch6(adc_event_detected_ch6),
                    .adc_event_detected_ch7(adc_event_detected_ch7), 
                    .adc_event_detected_ch8(adc_event_detected_ch8),
					
					.regulator_main_count(regulator_main_count),//16'h1000),
					.regulator_12_count(regulator_12_count),//16'h2000),
					.regulator_5_count(regulator_5_count),//16'h3000),
                    .regulator_3_3_main_count(regulator_3_3_main_count),//16'h4000),
                    .regulator_3_3_adc_count(regulator_3_3_adc_count),//16'h5000), 
                    .regulator_3_3_sd_count(regulator_3_3_sd_count)//16'h6000)
					);
					

assign      test_a = test_signal_120ns;
assign      test_b = clock_00_0048;
assign      test_c = therm_en1;
assign      test_d = buffer_full;
assign      test_e = sd_busy;
assign      test_f = ms_pulse;

endmodule
