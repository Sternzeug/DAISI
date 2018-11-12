module adc_serial_interface (   clock, reset, start, sd_write_ready, 
                                adc_data_ready, adc_clock, adc_data_0, adc_data_1,  //adc_data_2,  adc_data_3, 
                                adc_channel_data_ch1, adc_channel_data_ch2,
                                adc_channel_data_ch3, adc_channel_data_ch4,
                                adc_channel_data_ch5, adc_channel_data_ch6,
                                adc_channel_data_ch7, adc_channel_data_ch8,
                                adc_event_detected_ch1, adc_event_detected_ch2,
                                adc_event_detected_ch3, adc_event_detected_ch4,
                                adc_event_detected_ch5, adc_event_detected_ch6,
                                adc_event_detected_ch7, adc_event_detected_ch8,
                                adc_buffer_data, buffer_write_enable, buffer_full);

input	            clock;
input	            reset;
input               start;
input               sd_write_ready;
input               adc_data_ready;
input               adc_clock;
input               adc_data_0;
input               adc_data_1;
input               buffer_full;

output reg          buffer_write_enable;
output reg  [31:0]  adc_buffer_data;
output reg  [31:0]  adc_channel_data_ch1;
output reg  [31:0]  adc_channel_data_ch2;
output reg  [31:0]  adc_channel_data_ch3;
output reg  [31:0]  adc_channel_data_ch4;
output reg  [31:0]  adc_channel_data_ch5;
output reg  [31:0]  adc_channel_data_ch6;
output reg  [31:0]  adc_channel_data_ch7;
output reg  [31:0]  adc_channel_data_ch8;

output              adc_event_detected_ch1;
output              adc_event_detected_ch2;
output              adc_event_detected_ch3;
output              adc_event_detected_ch4;
output              adc_event_detected_ch5;
output              adc_event_detected_ch6;
output              adc_event_detected_ch7;
output              adc_event_detected_ch8;

reg                 adc_channel_data_ready_ch1;
reg                 adc_channel_data_ready_ch2;
reg                 adc_channel_data_ready_ch3;
reg                 adc_channel_data_ready_ch4;
reg                 adc_channel_data_ready_ch5;
reg                 adc_channel_data_ready_ch6;
reg                 adc_channel_data_ready_ch7;
reg                 adc_channel_data_ready_ch8;

reg         [31:0]  adc_channel_data_0;
reg         [31:0]  adc_channel_data_1;
reg                 adc_channel_data_ready;
reg                 adc_data_ready_reg;
reg                 adc_clock_reg;
reg                 adc_clock_reg_1;
reg                 adc_data_0_reg;
reg                 adc_data_1_reg;
reg         [ 8:0]  bit_count;
reg                 buffer_write_start;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    adc_data_ready_reg          <= 1'b0;
			adc_clock_reg               <= 1'b0;
			adc_clock_reg_1             <= 1'b0;
			adc_data_0_reg              <= 1'b0;
			adc_data_1_reg              <= 1'b0;
			
			bit_count                   <= 0;
			
			adc_channel_data_ready      <= 1'b0;
			adc_buffer_data             <= 32'h0;
			adc_channel_data_0          <= 32'h0;
			adc_channel_data_1          <= 32'h0;
			adc_channel_data_ch1        <= 32'h1;
			adc_channel_data_ch2        <= 32'h2;
			adc_channel_data_ch3        <= 32'h3;
			adc_channel_data_ch4        <= 32'h4;
			adc_channel_data_ch5        <= 32'h5;
			adc_channel_data_ch6        <= 32'h6;
			adc_channel_data_ch7        <= 32'h7;
			adc_channel_data_ch8        <= 32'h8;
			adc_channel_data_ready_ch1  <= 1'b0;
			adc_channel_data_ready_ch2  <= 1'b0;
			adc_channel_data_ready_ch3  <= 1'b0;
            adc_channel_data_ready_ch4  <= 1'b0;
            adc_channel_data_ready_ch5  <= 1'b0;
            adc_channel_data_ready_ch6  <= 1'b0;
            adc_channel_data_ready_ch7  <= 1'b0;
            adc_channel_data_ready_ch8  <= 1'b0;
			buffer_write_enable         <= 1'b0;
			buffer_write_start          <= 1'b0;
		end
	else if(start)
		begin
		    adc_data_ready_reg      <= adc_data_ready;
			adc_clock_reg           <= adc_clock;
			adc_clock_reg_1         <= adc_clock_reg;
			adc_data_0_reg          <= adc_data_0;
			adc_data_1_reg          <= adc_data_1;
			
		    if(adc_channel_data_ready)
		        begin
		            if(bit_count == 9'h020)
		                begin
		                    adc_channel_data_ch1        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch1  <= 1'b1;
		                    
		                    //adc_channel_data_ch5        <= adc_channel_data_1;
		                    //adc_channel_data_ready_ch5  <= 1'b1;
		                end
		            if(bit_count == 9'h040)
		                begin
		                    adc_channel_data_ch2        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch2  <= 1'b1;
		                    
		                    //adc_channel_data_ch6        <= adc_channel_data_1;
		                    //adc_channel_data_ready_ch6  <= 1'b1;
		                end
		            if(bit_count == 9'h060)
		                begin
		                    adc_channel_data_ch3        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch3  <= 1'b1;
		                    
		                    //adc_channel_data_ch7        <= adc_channel_data_1;
		                    //adc_channel_data_ready_ch7  <= 1'b1;
		                end
		            if(bit_count == 9'h080)
		                begin
		                    adc_channel_data_ch4        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch4  <= 1'b1;
		                    
		                    //adc_channel_data_ch8        <= adc_channel_data_1;
		                    //adc_channel_data_ready_ch8  <= 1'b1;
		                end
		                
		            if(bit_count == 9'h0A0)
		                begin
		                    adc_channel_data_ch5        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch5  <= 1'b1;
		                end
		            if(bit_count == 9'h0C0)
		                begin
		                    adc_channel_data_ch6        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch6  <= 1'b1;
		                end
		            if(bit_count == 9'h0E0)
		                begin
		                    adc_channel_data_ch7        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch7  <= 1'b1;
		                end
		            if(bit_count == 9'h100)
		                begin
		                    adc_channel_data_ch8        <= adc_channel_data_0;
		                    adc_channel_data_ready_ch8  <= 1'b1;
		                end
		        end
		        
		    if(buffer_write_start && !buffer_write_enable && adc_channel_data_ready_ch8)
		        begin
		        
		            buffer_write_enable         <= 1'b1;
		            
	                if(adc_channel_data_ready_ch1)
	                    begin
	                        adc_channel_data_ready_ch1  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch1;
	                    end
	                else if(adc_channel_data_ready_ch2)
	                    begin
	                        adc_channel_data_ready_ch2  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch2;
	                    end
	                else if(adc_channel_data_ready_ch3)
	                    begin
	                        adc_channel_data_ready_ch3  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch3;
	                    end
	                else if(adc_channel_data_ready_ch4)
	                    begin
	                        adc_channel_data_ready_ch4  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch4;
	                    end
	                else if(adc_channel_data_ready_ch5)
	                    begin
	                        adc_channel_data_ready_ch5  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch5;
	                    end
	                else if(adc_channel_data_ready_ch6)
	                    begin
	                        adc_channel_data_ready_ch6  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch6;
	                    end
	                else if(adc_channel_data_ready_ch7)
	                    begin
	                        adc_channel_data_ready_ch7  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch7;
	                    end   
	                else 
	                    begin
	                        adc_channel_data_ready_ch8  <= 1'b0;
	                        adc_buffer_data             <= adc_channel_data_ch8;
	                    end
	            end
		    else
		        begin
		            buffer_write_enable <= 1'b0;
		        end
		        
			
			if(adc_data_ready_reg == 1'b1)
			    begin
			        bit_count               <= 8'h00;
			        adc_channel_data_ready  <= 1'b0;
			        
			        if(sd_write_ready)
	                    begin
	                        if(!buffer_full)
	                            buffer_write_start  <= 1'b1;
	                        else
	                            buffer_write_start  <= 1'b0;
	                    end
			    end
			//else if((adc_clock_reg_1 == 1'b1) && (adc_clock_reg == 1'b0) && (bit_count < 8'h80))
			else if((adc_clock_reg_1 == 1'b1) && (adc_clock_reg == 1'b0) && (bit_count < 9'h100))
			    begin
			        bit_count           <= bit_count + 1;
			        adc_channel_data_0  <= {adc_channel_data_0[30:0],adc_data_0_reg};
			        adc_channel_data_1  <= {adc_channel_data_1[30:0],adc_data_1_reg};
	                
	                if( (bit_count == 9'h01F) || (bit_count == 9'h03F) || (bit_count == 9'h05F) || (bit_count == 9'h07F)
	                    || (bit_count == 9'h09F) || (bit_count == 9'h0BF) || (bit_count == 9'h0DF) || (bit_count == 9'h0FF)
	                    )
	                    adc_channel_data_ready  <= 1'b1;
			    end
			else
			    adc_channel_data_ready <= 1'b0;
		        
		end
	end


event_detect event_detect_ch1 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch1),
					.adc_count(adc_channel_data_ch1[23:0]),
					.event_detected(adc_event_detected_ch1));
					
event_detect event_detect_ch2 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch2),
					.adc_count(adc_channel_data_ch2[23:0]),
					.event_detected(adc_event_detected_ch2));
					
event_detect event_detect_ch3 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch3),
					.adc_count(adc_channel_data_ch3[23:0]),
					.event_detected(adc_event_detected_ch3));
					
event_detect event_detect_ch4 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch4),
					.adc_count(adc_channel_data_ch4[23:0]),
					.event_detected(adc_event_detected_ch4));
					
event_detect event_detect_ch5 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch5),
					.adc_count(adc_channel_data_ch5[23:0]),
					.event_detected(adc_event_detected_ch5));
					
event_detect event_detect_ch6 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch6),
					.adc_count(adc_channel_data_ch6[23:0]),
					.event_detected(adc_event_detected_ch6));
					
event_detect event_detect_ch7 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch7),
					.adc_count(adc_channel_data_ch7[23:0]),
					.event_detected(adc_event_detected_ch7));
					
event_detect event_detect_ch8 (
					.clock(clock),
					.reset(reset),
					.adc_count_valid(adc_channel_data_ready_ch8),
					.adc_count(adc_channel_data_ch8[23:0]),
					.event_detected(adc_event_detected_ch8));


endmodule
