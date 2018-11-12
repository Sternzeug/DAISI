module command_processor (  clock, reset, 
                            regulator_12v_en, regulator_3_3v_sd_en, regulator_3_3v_adc_en,
                            regulator_12v_en_sup, regulator_3_3v_sd_en_sup, regulator_3_3v_adc_en_sup,
                            ms_pulse, rs232_rx_byte, rs232_rx_valid, command_valid, rs232_reset, 
                            rs232_tx_bytes, rs232_tx_byte_count, rs232_tx_valid,
                            rs232_buffer_full, rs232_buffer_write_enable, rs232_record_byte,
                          
                            temp1_value, temp2_value, temp3_value, temp4_value,
                            therm_pwm1, therm_pwm2, therm_pwm3, therm_pwm4,
                            
                            therm_override_1, therm_override_2, therm_override_3, therm_override_4,
                            therm_increment_1, therm_increment_2, therm_increment_3, therm_increment_4,
                            therm_decrement_1, therm_decrement_2, therm_decrement_3, therm_decrement_4,
                            therm_reset,
                            
                            system_idle, adc_disable, sd_disable,
                            adc_init, sd_init_1, sd_init_2, sd_write_ready,
                            buffer_full, buffer_full_latch,
                            
                            adc_data_ch1, adc_data_ch2, adc_data_ch3, adc_data_ch4, 
                            adc_data_ch5, adc_data_ch6, adc_data_ch7, adc_data_ch8,
                            adc_event_detected_ch1, adc_event_detected_ch2,
                            adc_event_detected_ch3, adc_event_detected_ch4,
                            adc_event_detected_ch5, adc_event_detected_ch6,
                            adc_event_detected_ch7, adc_event_detected_ch8,
                            
                            regulator_main_count, regulator_12_count, regulator_5_count,
                            regulator_3_3_main_count, regulator_3_3_adc_count, regulator_3_3_sd_count);

parameter MAX_BYTES	        = 78;//46;//76; // Override in top.v
parameter RECORD_TX_BYTES	= MAX_BYTES;
parameter MAX_BYTES_RX      = 7;


input	        clock;
input	        reset;

output reg                          regulator_12v_en;
output reg                          regulator_3_3v_sd_en;
output reg                          regulator_3_3v_adc_en;

input                               regulator_12v_en_sup;
input                               regulator_3_3v_sd_en_sup;
input                               regulator_3_3v_adc_en_sup;

input                               ms_pulse;
input       [ 7:0]	                rs232_rx_byte;
input 			                    rs232_rx_valid;


input                               rs232_buffer_full;
output reg                          rs232_buffer_write_enable;
output reg  [7:0]                   rs232_record_byte;

output reg [7:0]                    rs232_tx_byte_count;
output reg [MAX_BYTES*8-1:0]        rs232_tx_bytes;
output reg                          rs232_tx_valid;

input       [5:0]                   therm_pwm1;
input       [5:0]                   therm_pwm2;
input       [5:0]                   therm_pwm3;
input       [5:0]                   therm_pwm4;

input       [15:0]                  temp1_value;
input       [15:0]                  temp2_value;
input       [15:0]                  temp3_value;
input       [15:0]                  temp4_value;

output reg                          therm_override_1;
output reg                          therm_override_2;
output reg                          therm_override_3;
output reg                          therm_override_4;
output reg                          therm_increment_1;
output reg                          therm_increment_2;
output reg                          therm_increment_3;
output reg                          therm_increment_4;
output reg                          therm_decrement_1;
output reg                          therm_decrement_2;
output reg                          therm_decrement_3;
output reg                          therm_decrement_4;
output reg                          therm_reset;

output reg  [7:0]	                command_valid;
output reg						    rs232_reset;

output reg                          system_idle;
output reg                          adc_disable;
output reg                          sd_disable;

input                               adc_init;
input                               sd_init_1;
input                               sd_init_2;
input                               sd_write_ready;

input                               buffer_full;
input                               buffer_full_latch;

input       [31:0]                  adc_data_ch1;
input       [31:0]                  adc_data_ch2;
input       [31:0]                  adc_data_ch3;
input       [31:0]                  adc_data_ch4;
input       [31:0]                  adc_data_ch5;
input       [31:0]                  adc_data_ch6;
input       [31:0]                  adc_data_ch7;
input       [31:0]                  adc_data_ch8;

input                               adc_event_detected_ch1;
input                               adc_event_detected_ch2;
input                               adc_event_detected_ch3;
input                               adc_event_detected_ch4;
input                               adc_event_detected_ch5;
input                               adc_event_detected_ch6;
input                               adc_event_detected_ch7;
input                               adc_event_detected_ch8;

input       [19:0]                  regulator_main_count;
input       [19:0]                  regulator_12_count;
input       [19:0]                  regulator_5_count;
input       [19:0]                  regulator_3_3_main_count;
input       [19:0]                  regulator_3_3_adc_count;
input       [19:0]                  regulator_3_3_sd_count;
					
reg [1:0]                           rs232_rx_valid_reg;
reg [7:0]                           rs232_rx_byte_reg;

reg [MAX_BYTES_RX*8-1:0]            rs232_rx_bytes;
reg [7:0]                           rs232_rx_command_byte;

reg [15:0]                          ms_timer;

reg [23:0]                          adc_event_count_ch1;
reg [23:0]                          adc_event_count_ch2;
reg [23:0]                          adc_event_count_ch3;
reg [23:0]                          adc_event_count_ch4;
reg [23:0]                          adc_event_count_ch5;
reg [23:0]                          adc_event_count_ch6;
reg [23:0]                          adc_event_count_ch7;
reg [23:0]                          adc_event_count_ch8;
	
always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    regulator_12v_en        <= 1'b1;
		    regulator_3_3v_sd_en    <= 1'b0;
		    regulator_3_3v_adc_en   <= 1'b0;
			rs232_reset             <= 0;
			rs232_rx_valid_reg      <= 2'b00;
			rs232_rx_byte_reg       <= 8'h00;
			rs232_rx_bytes          <= 0;
			command_valid           <= 0;
			rs232_tx_bytes          <= 0;
			
			rs232_buffer_write_enable  <= 1'b0;
			rs232_record_byte          <= 8'h00;
			rs232_tx_byte_count        <= 8'h00;
			rs232_tx_valid          <= 0;
			rs232_rx_command_byte   <= 8'h00;
			ms_timer                <= 0;
			
			system_idle             <= 0;
			adc_disable             <= 0;
			sd_disable              <= 0;
			
			therm_override_1        <= 0;
            therm_override_2        <= 0;
            therm_override_3        <= 0;
            therm_override_4        <= 0;
            therm_increment_1       <= 0;
            therm_increment_2       <= 0;
            therm_increment_3       <= 0;
            therm_increment_4       <= 0;
            therm_decrement_1       <= 0;
            therm_decrement_2       <= 0;
            therm_decrement_3       <= 0;
            therm_decrement_4       <= 0;
            therm_reset             <= 0;
			
            adc_event_count_ch1     <= 0;
            adc_event_count_ch2     <= 0;
            adc_event_count_ch3     <= 0;
            adc_event_count_ch4     <= 0;
            adc_event_count_ch5     <= 0;
            adc_event_count_ch6     <= 0;
            adc_event_count_ch7     <= 0;
            adc_event_count_ch8     <= 0;
		end
	else
		begin
			rs232_rx_valid_reg      <= {rs232_rx_valid_reg[0],rs232_rx_valid};
			rs232_rx_byte_reg       <= rs232_rx_byte;
			    
			if(ms_pulse == 1'b1)
			    begin
		            if(ms_timer < 16'd2000)
		                ms_timer <= ms_timer + 1;
		            else
		                ms_timer <= 0;
		        end
			
			
			if((rs232_rx_valid_reg[1] == 0) && (rs232_rx_valid_reg[0] == 1))
				begin
					
					rs232_rx_bytes  <= {rs232_rx_bytes[(MAX_BYTES_RX-1)*8-1:0],rs232_rx_byte_reg};
					
					if( (rs232_rx_byte_reg == 8'h0A) && (rs232_rx_bytes[47:40] == 8'h01) && (rs232_rx_bytes[39:32] == 8'h02) &&
					    (rs232_rx_bytes[27:24] == 4'd13) && (rs232_rx_bytes[15:8] == 8'h03) && (rs232_rx_bytes[7:0] == 8'h0D))  // Detect command pattern
					    begin
					        rs232_rx_command_byte                   <= rs232_rx_bytes[23:16];
					        if((rs232_rx_bytes[31:28] == 4'h3) && (rs232_rx_bytes[23:16] == 8'h00))         // 3.3V ADC Disable
								begin
							        command_valid                   <= 1;
							        regulator_3_3v_adc_en           <= 1'b0;
								end
							else if((rs232_rx_bytes[31:28] == 4'h9) && (rs232_rx_bytes[23:16] == 8'h10))    // 3.3V ADC Enable
								begin
							        command_valid                   <= 2;
							        regulator_3_3v_adc_en           <= 1'b1;
								end
							else if((rs232_rx_bytes[31:28] == 4'hD) && (rs232_rx_bytes[23:16] == 8'h01))   // 3.3V SD Disable
								begin
							        command_valid                   <= 3;
							        //regulator_3_3v_sd_en            <= 1'b0;
							        sd_disable                      <= 1'b1;
								end
							else if((rs232_rx_bytes[31:28] == 4'h7) && (rs232_rx_bytes[23:16] == 8'h11))    // 3.3V SD Enable
								begin
							        command_valid                   <= 4;
							        //regulator_3_3v_sd_en            <= 1'b1;
							        sd_disable                      <= 1'b0;
								end
							else if((rs232_rx_bytes[31:28] == 4'h0) && (rs232_rx_bytes[23:16] == 8'h02))    // 12V Disable
								begin
							        command_valid                   <= 5;
							        regulator_12v_en                <= 1'b0;
								end
							else if((rs232_rx_bytes[31:28] == 4'hA) && (rs232_rx_bytes[23:16] == 8'h12))    // 12V Enable
								begin
							        command_valid                   <= 6;
							        regulator_12v_en                <= 1'b1;
								end	
								
						    else if((rs232_rx_bytes[31:28] == 4'h5) && (rs232_rx_bytes[23:16] == 8'h40))    // ADC Disable
								begin
							        command_valid                   <= 15;
							        adc_disable                     <= 1'b1;
								end
							else if((rs232_rx_bytes[31:28] == 4'hB) && (rs232_rx_bytes[23:16] == 8'h41))    // ADC Re-enable
								begin
							        command_valid                   <= 16;
							        adc_disable                     <= 1'b0;
								end
								
							else if((rs232_rx_bytes[31:28] == 4'hF) && (rs232_rx_bytes[23:16] == 8'h50))    // Decrement therm pwm 1
								begin
							        command_valid                   <= 17;
							        therm_override_1                <= 1'b1;
							        therm_decrement_1               <= 1'b1;
								end
						    else if((rs232_rx_bytes[31:28] == 4'h1) && (rs232_rx_bytes[23:16] == 8'h51))    // Increment therm pwm 1
								begin
							        command_valid                   <= 18;
							        therm_override_1                <= 1'b1;
							        therm_increment_1               <= 1'b1;
								end	
							else if((rs232_rx_bytes[31:28] == 4'hC) && (rs232_rx_bytes[23:16] == 8'h52))    // Decrement therm pwm 2
								begin
							        command_valid                   <= 19;
							        therm_override_2                <= 1'b1;
							        therm_decrement_2               <= 1'b1;
								end
						    else if((rs232_rx_bytes[31:28] == 4'h2) && (rs232_rx_bytes[23:16] == 8'h53))    // Increment therm pwm 2
								begin
							        command_valid                   <= 20;
							        therm_override_2                <= 1'b1;
							        therm_increment_2               <= 1'b1;
								end
							else if((rs232_rx_bytes[31:28] == 4'h6) && (rs232_rx_bytes[23:16] == 8'h54))    // Decrement therm pwm 3
								begin
							        command_valid                   <= 21;
							        therm_override_3                <= 1'b1;
							        therm_decrement_3               <= 1'b1;
								end
						    else if((rs232_rx_bytes[31:28] == 4'h8) && (rs232_rx_bytes[23:16] == 8'h55))    // Increment therm pwm 3
								begin
							        command_valid                   <= 22;
							        therm_override_3                <= 1'b1;
							        therm_increment_3               <= 1'b1;
								end	
							else if((rs232_rx_bytes[31:28] == 4'h5) && (rs232_rx_bytes[23:16] == 8'h56))    // Decrement therm pwm 4
								begin
							        command_valid                   <= 23;
							        therm_override_4                <= 1'b1;
							        therm_decrement_4               <= 1'b1;
								end
						    else if((rs232_rx_bytes[31:28] == 4'hB) && (rs232_rx_bytes[23:16] == 8'h57))    // Increment therm pwm 4
								begin
							        command_valid                   <= 24;
							        therm_override_4                <= 1'b1;
							        therm_increment_4               <= 1'b1;
								end
							else if((rs232_rx_bytes[31:28] == 4'h2) && (rs232_rx_bytes[23:16] == 8'h58))    // Thermal controller reset
								begin
							        command_valid                   <= 25;
							        therm_reset                     <= 1'b1;
								end		
													        
					        else if((rs232_rx_bytes[31:28] == 4'h9) && (rs232_rx_bytes[23:16] == 8'hFA))    // Reset Command
						        begin
									rs232_reset                     <= 1;
									command_valid                   <= 26;
						        end
						    else if((rs232_rx_bytes[31:28] == 4'h7) && (rs232_rx_bytes[23:16] == 8'hFB))    // Resume from idle
						        begin
									system_idle                     <= 0;
									command_valid                   <= 27;
						        end	
						    else if((rs232_rx_bytes[31:28] == 4'h3) && (rs232_rx_bytes[23:16] == 8'hFC))    // Enter idle
						        begin
									system_idle                     <= 1;
									command_valid                   <= 28;
						        end						
							else if((rs232_rx_bytes[31:28] == 4'hF) && (rs232_rx_bytes[23:16] == 8'hFF))    // Dummy Command - NOP
						        begin
							        command_valid                   <= 29;
						        end
						        
					    end
				    else
			            begin
			                therm_increment_1   <= 1'b0;
			                therm_increment_2   <= 1'b0;
			                therm_increment_3   <= 1'b0;
			                therm_increment_4   <= 1'b0;
			                therm_decrement_1   <= 1'b0;
			                therm_decrement_2   <= 1'b0;
			                therm_decrement_3   <= 1'b0;
			                therm_decrement_4   <= 1'b0;
			            end
				end
			else
			    begin
			        therm_reset         <= 1'b0;
			    end
			
		    
		    if((rs232_tx_byte_count > 0) && (rs232_buffer_full == 0))
			    begin
			        rs232_buffer_write_enable  <= 1'b1;
			        rs232_record_byte          <= rs232_tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-1)*8];
			        rs232_tx_bytes             <= {rs232_tx_bytes[(MAX_BYTES-1)*8-1:0],8'hFF};
			        rs232_tx_byte_count        <= rs232_tx_byte_count - 1;
			        rs232_tx_valid      	   <= 0;
			    end
			else if((rs232_tx_byte_count == 0) && (ms_pulse == 1'b1) && (ms_timer == 0))
                begin
			        rs232_buffer_write_enable  <= 1'b0; 
		    
					rs232_tx_bytes  <= {    adc_data_ch1, adc_data_ch2,                                     // 8
					                        adc_data_ch3, adc_data_ch4,                                     // 16
					                        adc_data_ch5, adc_data_ch6,                                     // 24
					                        adc_data_ch7, adc_data_ch8,                                     // 32
					                        temp1_value[15:0], therm_pwm1[5:0], 2'h0,                       // 35
					                        temp2_value[15:0], therm_pwm2[5:0], 2'h0,                       // 38
					                        temp3_value[15:0], therm_pwm3[5:0], 2'h0,                       // 41
					                        temp4_value[15:0], therm_pwm4[5:0], 2'h0,                       // 44
					                        regulator_12v_en_sup, regulator_3_3v_sd_en_sup,
                                            regulator_3_3v_adc_en_sup, sd_write_ready,
                                            sd_init_1, sd_init_2,
                                            adc_init, buffer_full_latch,                                    // 45
                                             
                                            regulator_main_count[19:12],     regulator_12_count[19:12],     // 47
                                            regulator_5_count[19:12],        regulator_3_3_main_count[15:8],// 49
                                            regulator_3_3_adc_count[15:8],  regulator_3_3_sd_count[16:9],   // 51
                                            adc_event_count_ch1, adc_event_count_ch2,                       // 57
                                            adc_event_count_ch3, adc_event_count_ch4,                       // 63
                                            adc_event_count_ch5, adc_event_count_ch6,                       // 69
                                            adc_event_count_ch7, adc_event_count_ch8,                       // 75
                                            rs232_rx_command_byte, command_valid,                           // 77
                                            8'h0D};                                                         // 78
                    //// Test Sequence 
                    /*rs232_tx_bytes  <= {     32'h00010203, 32'h04050607,    // 8
					                         32'h08090A0B, 32'h0C0D0E0F,    // 16
					                         32'h10111213, 32'h14151617,    // 24
					                         32'h18191A1B, 32'h1C1D1E1F,    // 32
					                         16'h2021, 8'h22,               // 35
					                         16'h2324, 8'h25,               // 38
					                         16'h2627, 8'h28,               // 41
					                         16'h292A, 8'h2B,               // 44
					                         8'h2C,                         // 45
					                         
					                         8'h2D, 8'h2E,                   // 47
					                         8'h2F, 8'h30,                   // 49
					                         8'h31, 8'h32,                   // 51
					                         //24'h333435, 24'h363738,         // 57
					                         //24'h393A3B, 24'h3C3D3E,         // 63
					                         //24'h3F4041, 24'h424344,         // 69
					                         //24'h454647, 24'h48494A,         // 75
					                         
					                         
                                             8'h2D};                        // 76
                    */                          
			        rs232_tx_byte_count     <= RECORD_TX_BYTES;
				    rs232_tx_valid      	<= 1;
			        
			        adc_event_count_ch1     <= 0;//1;
                    adc_event_count_ch2     <= 0;//2;
                    adc_event_count_ch3     <= 0;//3;
                    adc_event_count_ch4     <= 0;//4;
                    adc_event_count_ch5     <= 0;//5;
                    adc_event_count_ch6     <= 0;//6;
                    adc_event_count_ch7     <= 0;//7;
                    adc_event_count_ch8     <= 0;//8;
                end
            else
                begin
                
                    rs232_buffer_write_enable   <= 1'b0; 
                    rs232_tx_valid      	    <= 0;
                
                    if(adc_event_detected_ch1)
			            adc_event_count_ch1 <= adc_event_count_ch1 + 1;
			        if(adc_event_detected_ch2)
			            adc_event_count_ch2 <= adc_event_count_ch2 + 1;
			        if(adc_event_detected_ch3)
			            adc_event_count_ch3 <= adc_event_count_ch3 + 1;
			        if(adc_event_detected_ch4)
			            adc_event_count_ch4 <= adc_event_count_ch4 + 1;
			        if(adc_event_detected_ch5)
			            adc_event_count_ch5 <= adc_event_count_ch5 + 1;
			        if(adc_event_detected_ch6)
			            adc_event_count_ch6 <= adc_event_count_ch6 + 1;
			        if(adc_event_detected_ch7)
			            adc_event_count_ch7 <= adc_event_count_ch7 + 1;
			        if(adc_event_detected_ch8)
			            adc_event_count_ch8 <= adc_event_count_ch8 + 1;
                
                end
		end
	end

endmodule
