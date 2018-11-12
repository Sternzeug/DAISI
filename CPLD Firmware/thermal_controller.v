module thermal_controller ( clock, reset,
                            temp_sample_pulse, temp_rx_byte, temp_rx_valid, temp_tx_bytes, temp_tx_num_bytes, temp_tx_valid,
                            temp1_value, temp2_value, temp3_value, temp4_value,
                            therm_pwm1, therm_pwm2, therm_pwm3, therm_pwm4 );


parameter TEMP_MAX_BYTES	      = 5;

parameter TEMP_CMD_1_RX_BYTES     = 0;
parameter TEMP_CMD_1_TX_BYTES     = 2;

parameter TEMP_CMD_2_RX_BYTES     = 4;
parameter TEMP_CMD_2_TX_BYTES     = 3;

parameter TEMP_CMD_3_RX_BYTES     = 0;
parameter TEMP_CMD_3_TX_BYTES     = 5;

parameter TEMP_CMD_4_RX_BYTES     = 8;
parameter TEMP_CMD_4_TX_BYTES     = 3;


input	                                    clock;
input	                                    reset;
input                                       temp_sample_pulse;
input               [ 7:0]	                temp_rx_byte;
input 			                            temp_rx_valid;
output reg          [TEMP_MAX_BYTES*8-1:0]  temp_tx_bytes;
output reg          [ 3:0]                  temp_tx_num_bytes;
output reg                                  temp_tx_valid;
output reg signed   [15:0]                  temp1_value;
output reg signed   [15:0]                  temp2_value;
output reg signed   [15:0]                  temp3_value;
output reg signed   [15:0]                  temp4_value;
output reg          [ 5:0]                  therm_pwm1;
output reg          [ 5:0]                  therm_pwm2;
output reg          [ 5:0]                  therm_pwm3;
output reg          [ 5:0]                  therm_pwm4;

reg                 temp1_valid;
reg                 temp2_valid;
reg                 temp3_valid;
reg                 temp4_valid;

reg [ 3:0]  temp_rx_num_bytes;
reg         temp_rx_done;
reg         temp_sample_pulse_reg;
reg [ 2:0]  temp_rx_valid_reg;
reg [ 7:0]  temp_rx_byte_reg;
reg [ 3:0]  temp_rx_count;
reg         temp_tx_valid_reg;
reg [ 2:0]  temp_command_index;
reg [15:0]  temp_current;
	
always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    temp_sample_pulse_reg   <= 0;
			temp_rx_valid_reg       <= 3'b000;
			temp_rx_byte_reg        <= 8'h00;
			temp_tx_bytes           <= 0;
			temp_tx_num_bytes       <= 0;
			temp_tx_valid           <= 0;
			temp_tx_valid_reg       <= 0;
			
			temp_rx_num_bytes       <= 0;
			temp_rx_done            <= 0;
			
			temp_command_index      <= 0;
			
			temp_current            <= 16'h0000;
			temp1_valid             <= 1'b0;
			temp2_valid             <= 1'b0;
			temp3_valid             <= 1'b0;
			temp4_valid             <= 1'b0;
			temp1_value             <= 0;
			temp2_value             <= 0;
			temp3_value             <= 0;
			temp4_value             <= 0;
			
			temp_rx_count           <= 0;
		end
	else
		begin
		    temp_sample_pulse_reg   <= temp_sample_pulse;
			temp_rx_valid_reg       <= {temp_rx_valid_reg[1:0],temp_rx_valid};
			temp_rx_byte_reg        <= temp_rx_byte;
			temp_tx_valid           <= temp_tx_valid_reg;
			
			if((temp_sample_pulse_reg == 1'b0) && (temp_sample_pulse == 1'b1) || temp_rx_done)
			    begin
			        if(temp_command_index == 0)    // Reset devices
			            begin
			                temp_tx_bytes[TEMP_MAX_BYTES*8-1:(TEMP_MAX_BYTES-TEMP_CMD_1_TX_BYTES)*8]  <= {8'h55,   8'h5D};
			                temp_tx_num_bytes           <= TEMP_CMD_1_TX_BYTES;
			                temp_rx_num_bytes           <= TEMP_CMD_1_RX_BYTES;
			                temp_tx_valid_reg           <= 1;
			                temp_command_index          <= 1;
			            end
			        else if(temp_command_index == 1)         // Initialize bus
			            begin
			                temp_tx_bytes[TEMP_MAX_BYTES*8-1:(TEMP_MAX_BYTES-TEMP_CMD_2_TX_BYTES)*8]  <= {8'h55,   8'h95,   8'h0D};
			                temp_tx_num_bytes           <= TEMP_CMD_2_TX_BYTES;
			                temp_rx_num_bytes           <= TEMP_CMD_2_RX_BYTES;
			                if(temp_rx_done)
			                    begin
			                        temp_tx_valid_reg           <= 0;
			                        temp_command_index          <= 2;
			                    end
			                else
			                    begin
			                        temp_tx_valid_reg           <= 1;
			                        temp_command_index          <= 1;
			                    end
			            end
			        else if(temp_command_index == 2)    // Configure sample rate and GPO polarity
			            begin
			                temp_tx_bytes[TEMP_MAX_BYTES*8-1:(TEMP_MAX_BYTES-TEMP_CMD_3_TX_BYTES)*8]  <= {8'h55,   5'h04,3'h1,   4'hA,4'h1, 8'h00,  8'hc0};
			                temp_tx_num_bytes           <= TEMP_CMD_3_TX_BYTES;
			                temp_rx_num_bytes           <= TEMP_CMD_3_RX_BYTES;
			                temp_tx_valid_reg           <= 1;
			                temp_command_index          <= 3;
			            end
			        else if(temp_command_index == 3)    // Read temperature
			            begin
			                temp_tx_bytes[TEMP_MAX_BYTES*8-1:(TEMP_MAX_BYTES-TEMP_CMD_4_TX_BYTES)*8]  <= {8'h55,   5'h04,3'h3,   4'hA,4'h0};
			                temp_tx_num_bytes           <= TEMP_CMD_4_TX_BYTES;
			                temp_rx_num_bytes           <= TEMP_CMD_4_RX_BYTES;
			                if(temp_rx_done)
			                    begin
			                        temp_tx_valid_reg           <= 0;
			                        temp_command_index          <= 3;
			                    end
			                else
			                    begin
			                        temp_tx_valid_reg           <= 1;
			                        temp_command_index          <= 3;
			                    end
			            end
			    end
			else if((temp_sample_pulse_reg == 1'b1) && (temp_sample_pulse == 1'b0))
			    begin
				    temp_tx_valid_reg <= 0;
				end
			
			if((temp_rx_valid_reg[1] == 0) && (temp_rx_valid_reg[0] == 1))
				begin
					temp_current   <= {temp_rx_byte_reg,temp_current[15:8]};
					temp_rx_count  <= temp_rx_count + 1;
			    end
			else if((temp_rx_valid_reg[2] == 0) && (temp_rx_valid_reg[1] == 1))
				begin		
					if(temp_rx_count == temp_rx_num_bytes)
		                begin
		                    temp_rx_count   <= 0;
		                    temp_rx_done    <= 1;
		                end 
					
					
					if(temp_rx_count == 2)
				        begin
				            temp4_valid <= 1'b1;
		                    temp4_value <= temp_current;
		                end
		                
		            if(temp_rx_count == 4)
				        begin
				            temp3_valid <= 1'b1;
		                    temp3_value <= temp_current;
		                end
		                
		            if(temp_rx_count == 6)
				        begin
				            temp2_valid <= 1'b1;
		                    temp2_value <= temp_current;
		                end
		                
					if(temp_rx_count == 8)
				        begin
				            temp1_valid <= 1'b1;
		                    temp1_value <= temp_current;
		                end
				end
			else
			    begin
			        temp_rx_done        <= 0;
			        temp1_valid         <= 1'b0;
			        temp2_valid         <= 1'b0;
			        temp3_valid         <= 1'b0;
			        temp4_valid         <= 1'b0;
			    end

		end
	end

reg                 temp_valid;
reg         [ 2:0]  temp_selection;
reg         [ 4:0]  temp_count;
reg  signed [13:0]  temp_value;
reg  signed [13:0]  temp_value_prev;
reg  signed [13:0]  temp1_value_prev;
reg  signed [13:0]  temp2_value_prev;
reg  signed [13:0]  temp3_value_prev;
reg  signed [13:0]  temp4_value_prev;
reg         [ 5:0]  therm_pwm;
reg  signed [13:0]  temp_target;
reg  signed [14:0]  temp_slope;
reg                 temp_slope_valid;
reg                 temp_slope_valid_reg;

wire signed [14:0]  temp_target_result_signed;
wire signed [14:0]  temp_slope_result_signed;

assign temp_target_result_signed    = temp_value - temp_target;
assign temp_slope_result_signed     = temp_value - temp_value_prev - temp_slope;
	
always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    temp_valid              <= 1'b0;
		    temp_selection          <= 0;
		    temp_count              <= 5'h00;
		    therm_pwm               <= 6'h00;
		    therm_pwm1              <= 6'h00;
		    therm_pwm2              <= 6'h00;
		    therm_pwm3              <= 6'h00;
		    therm_pwm4              <= 6'h00;
            temp_value              <= 0;
            temp_value_prev         <= 0;
		    temp1_value_prev        <= 14'h000;
		    temp2_value_prev        <= 14'h000;
		    temp3_value_prev        <= 14'h000;
		    temp4_value_prev        <= 14'h000;
		    temp_target             <= 14'h3B00;   // -20 C
		    //temp_target             <= 14'h8C0;   // 35 C
		    //temp_target             <= 14'h1400;    // 80 C
		    temp_slope              <= 0;
            temp_slope_valid        <= 1'b0;
            temp_slope_valid_reg    <= 1'b0;
		end
	else
		begin
		    temp_slope_valid_reg  <= temp_slope_valid;
		
		    if(     temp1_valid == 1)
		        begin
		            temp_selection      <= 0;
		            temp_valid          <= 1'b1;
		            temp_value          <= temp1_value[15:2];
		            temp_value_prev     <= temp1_value_prev;
		            if(temp_count == 0)
		                temp1_value_prev    <= temp1_value[15:2];
		            therm_pwm           <= therm_pwm1;
		        end
		    else if(temp2_valid == 1)
		        begin
		            temp_selection      <= 1;
		            temp_valid          <= 1'b1;
		            temp_value          <= temp2_value[15:2];
		            temp_value_prev     <= temp2_value_prev;
		            if(temp_count == 0)
		                temp2_value_prev    <= temp2_value[15:2];
		            therm_pwm           <= therm_pwm2;
		        end
		    else if(temp3_valid == 1)
		        begin
		            temp_selection      <= 2;
		            temp_valid          <= 1'b1;
		            temp_value          <= temp3_value[15:2];
		            temp_value_prev     <= temp3_value_prev;
		            if(temp_count == 0)
		                temp3_value_prev    <= temp3_value[15:2];
		            therm_pwm           <= therm_pwm3;
		        end
		    else if(temp4_valid == 1)
		        begin
		            temp_selection      <= 3;
		            temp_valid          <= 1'b1;
		            temp_value          <= temp4_value[15:2];
		            temp_value_prev     <= temp4_value_prev;
		            if(temp_count == 0)
		                temp4_value_prev    <= temp4_value[15:2];
		            therm_pwm           <= therm_pwm4;
		        end
		    else
		        temp_valid          <= 1'b0;
		        
		        
		    if((temp_valid == 1) && (temp_count == 5'h0F)) // check bit length: max 32h
		        begin
		            if(temp_selection == 0)
                        temp_count  <= 5'h00;
            
                    // Use temperature distance from target temperature to determine desired temperature change slope
                    if(         temp_target_result_signed < 15'sh7F80)  // Beneath -2.0 C
                        begin
                            temp_slope          <= 15'sh0040;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed < 15'sh7FC0) // Beneath -1.0 C
                        begin
                            temp_slope          <= 15'sh0008;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed < 15'sh7FE0) // Beneath -0.5 C
                        begin
                            temp_slope          <= 15'sh0004;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed < 15'sh7FF0) // Beneath -0.25 C
                        begin
                            temp_slope          <= 15'sh0002;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed < 15'sh7FF8) // Beneath -0.125 C
                        begin
                            temp_slope          <= 15'sh0001;
                            temp_slope_valid    <= 1'b1;
                        end
                        
                    else if(    temp_target_result_signed > 15'sh0080) // Above +2.0 C
                        begin
                            temp_slope          <= 15'sh7FC0;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed > 15'sh0040) // Above +1.0 C
                        begin
                            temp_slope          <= 15'sh7FF8;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed > 15'sh0020) // Above +0.5 C
                        begin
                            temp_slope          <= 15'sh7FFC;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed > 15'sh0010) // Above +0.25 C
                        begin
                            temp_slope          <= 15'sh7FFE;
                            temp_slope_valid    <= 1'b1;
                        end
                    else if(    temp_target_result_signed > 15'sh0008) // Above +0.125 C
                        begin
                            temp_slope          <= 15'sh7FFF;
                            temp_slope_valid    <= 1'b1;
                        end
                        
                    else                                        // Near target
                        begin
                            temp_slope          <= 15'sh0000;
                            temp_slope_valid    <= 1;
                        end
		        end
		     else if((temp_valid == 1) && (temp_selection == 0))
		        temp_count          <= temp_count + 1;
		     else
		        temp_slope_valid    <= 0;
		        
		        
		     if(temp_slope_valid == 1)
		        begin
		        
		            // Use temperature distance from previous temperature to determine desired PWM (heat applied) to match desired slope
		            if(         ((temp_slope_result_signed) < 15'sh7FC0) && (therm_pwm < 6'h39))  // Beneath -1.875
                        therm_pwm  <= therm_pwm + 6'h06;
                    else if(    ((temp_slope_result_signed) < 15'sh7FE0) && (therm_pwm < 6'h3B))  // Beneath -0.938
                        therm_pwm  <= therm_pwm + 6'h04;
                    else if(    ((temp_slope_result_signed) < 15'sh7FFA) && (therm_pwm < 6'h3E))  // Beneath -0.469
                        therm_pwm  <= therm_pwm + 6'h02;
                    else if(    ((temp_slope_result_signed) < 15'sh7FFE) && (therm_pwm != 6'h3F)) // Beneath -0.234
                        therm_pwm  <= therm_pwm + 6'h01;
                        
                    else if(    ((temp_slope_result_signed) > 15'sh0040) && (therm_pwm > 6'h06))  // Above +1.875
                        therm_pwm  <= therm_pwm - 6'h06;
                    else if(    ((temp_slope_result_signed) > 15'sh0020) && (therm_pwm > 6'h04))  // Above +0.938
                        therm_pwm  <= therm_pwm - 6'h04;
                    else if(    ((temp_slope_result_signed) > 15'sh0006) && (therm_pwm > 6'h02))  // Above +0.469
                        therm_pwm  <= therm_pwm - 6'h02;
                    else if(    ((temp_slope_result_signed) > 15'sh0002) && (therm_pwm != 6'h00))  // Above +0.234
                        therm_pwm  <= therm_pwm - 6'h01;
                        
                    else
                        therm_pwm  <= therm_pwm;
		        
		        end
		     
		     if(temp_slope_valid_reg == 1)
		        begin
		            if(     temp_selection == 0)
		               therm_pwm1   <= therm_pwm; 
		            else if(temp_selection == 1)
		               therm_pwm2   <= therm_pwm;
		            else if(temp_selection == 2)
		               therm_pwm3   <= therm_pwm;
		            else if(temp_selection == 3)
		               therm_pwm4   <= therm_pwm;
		        end
		end
	end


endmodule
