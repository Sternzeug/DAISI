module adc_serial_interface (   clock, reset, start, adc_data_ready, adc_clock, adc_data_0, 
                                adc_channel_data_ch1, adc_channel_data_ch2,
                                adc_channel_data_ch3, adc_channel_data_ch4,
                                adc_channel_data_ch5, adc_channel_data_ch6,
                                adc_channel_data_ch7, adc_channel_data_ch8,
                                adc_channel_data_ready_ch1, adc_channel_data_ready_ch2,
                                adc_channel_data_ready_ch3, adc_channel_data_ready_ch4,
                                adc_channel_data_ready_ch5, adc_channel_data_ready_ch6,
                                adc_channel_data_ready_ch7, adc_channel_data_ready_ch8,
                                adc_channel_data, buffer_write_enable, buffer_full);

input	            clock;
input	            reset;
input               start;
input               adc_data_ready;
input               adc_clock;
input               adc_data_0;
input               buffer_full;

output reg          buffer_write_enable;
output reg  [31:0]  adc_channel_data;
output reg  [31:0]  adc_channel_data_ch1;
output reg  [31:0]  adc_channel_data_ch2;
output reg  [31:0]  adc_channel_data_ch3;
output reg  [31:0]  adc_channel_data_ch4;
output reg  [31:0]  adc_channel_data_ch5;
output reg  [31:0]  adc_channel_data_ch6;
output reg  [31:0]  adc_channel_data_ch7;
output reg  [31:0]  adc_channel_data_ch8;
output reg          adc_channel_data_ready_ch1;
output reg          adc_channel_data_ready_ch2;
output reg          adc_channel_data_ready_ch3;
output reg          adc_channel_data_ready_ch4;
output reg          adc_channel_data_ready_ch5;
output reg          adc_channel_data_ready_ch6;
output reg          adc_channel_data_ready_ch7;
output reg          adc_channel_data_ready_ch8;

reg                 adc_channel_data_ready;
reg                 adc_data_ready_reg;
reg                 adc_clock_reg;
reg                 adc_clock_reg_1;
reg                 adc_data_0_reg;
reg         [ 8:0]  bit_count;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    adc_data_ready_reg          <= 1'b0;
			adc_clock_reg               <= 1'b0;
			adc_clock_reg_1             <= 1'b0;
			adc_data_0_reg              <= 1'b0;
			
			bit_count                   <= 9'h1FF;
			
			adc_channel_data_ready      <= 1'b0;
			adc_channel_data            <= 32'h0000;
			adc_channel_data_ch1        <= 32'h0000;
			adc_channel_data_ch2        <= 32'h0000;
			adc_channel_data_ready_ch1  <= 1'b0;
			adc_channel_data_ready_ch2  <= 1'b0;
			buffer_write_enable         <= 1'b0;
		end
	else if(start)
		begin
		    buffer_write_enable     <= adc_channel_data_ready;
		    adc_data_ready_reg      <= adc_data_ready;
			adc_clock_reg           <= adc_clock;
			adc_clock_reg_1         <= adc_clock_reg;
			adc_data_0_reg          <= adc_data_0;
			
		    if(adc_channel_data_ready)
		    begin
		        if(bit_count == 9'h020)
		            begin
		                adc_channel_data_ch1        <= adc_channel_data;
		                adc_channel_data_ready_ch1  <= 1'b1;
		            end
		        else if(bit_count == 9'h040)
		            begin
		                adc_channel_data_ch2        <= adc_channel_data;
		                adc_channel_data_ready_ch2  <= 1'b1;
		            end
		        else if(bit_count == 9'h060)
		            begin
		                adc_channel_data_ch3        <= adc_channel_data;
		                adc_channel_data_ready_ch3  <= 1'b1;
		            end
		        else if(bit_count == 9'h080)
		            begin
		                adc_channel_data_ch4        <= adc_channel_data;
		                adc_channel_data_ready_ch4  <= 1'b1;
		            end
		        else if(bit_count == 9'h0A0)
		            begin
		                adc_channel_data_ch5        <= adc_channel_data;
		                adc_channel_data_ready_ch5  <= 1'b1;
		            end
		        else if(bit_count == 9'h0C0)
		            begin
		                adc_channel_data_ch6        <= adc_channel_data;
		                adc_channel_data_ready_ch6  <= 1'b1;
		            end
		        else if(bit_count == 9'h0E0)
		            begin
		                adc_channel_data_ch7        <= adc_channel_data;
		                adc_channel_data_ready_ch7  <= 1'b1;
		            end
		        else if(bit_count == 9'h100)
		            begin
		                adc_channel_data_ch8        <= adc_channel_data;
		                adc_channel_data_ready_ch8  <= 1'b1;
		            end
		    end
			
			if(adc_data_ready_reg == 1'b1)
			    begin
			        bit_count <= 9'h000;
			    end
			else if((adc_clock_reg_1 == 1'b1) && (adc_clock_reg == 1'b0) && (bit_count < 9'h100))
			    begin
			        bit_count <= bit_count + 1;
			        adc_channel_data <= {adc_channel_data[30:0],adc_data_0_reg};
			        if(buffer_full == 1'b0)
			            begin
			                if( (bit_count == 9'h01F) || (bit_count == 9'h03F) || (bit_count == 9'h05F) || (bit_count == 9'h07F) || 
			                    (bit_count == 9'h09F) || (bit_count == 9'h0BF) || (bit_count == 9'h0DF) || (bit_count == 9'h0FF))
			                    adc_channel_data_ready <= 1'b1;
			            end
			    end
			else
			    adc_channel_data_ready <= 1'b0;
		        
		end
	end


endmodule
