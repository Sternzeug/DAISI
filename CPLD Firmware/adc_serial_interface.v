module adc_serial_interface ( clock, reset, start, adc_data_ready, adc_clock, adc_data_0, adc_channel_data, buffer_write_enable, buffer_full);

input	            clock;
input	            reset;
input               start;
input               adc_data_ready;
input               adc_clock;
input               adc_data_0;
input               buffer_full;

output reg          buffer_write_enable;
output reg  [31:0]  adc_channel_data;

reg                 adc_channel_data_ready;
reg                 adc_data_ready_reg;
reg                 adc_clock_reg;
reg                 adc_clock_reg_1;
reg                 adc_data_0_reg;
reg         [ 5:0]  bit_count;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    adc_data_ready_reg      <= 1'b0;
			adc_clock_reg           <= 1'b0;
			adc_clock_reg_1         <= 1'b0;
			adc_data_0_reg          <= 1'b0;
			
			bit_count               <= 6'h3F;
			
			adc_channel_data_ready  <= 1'b0;
			adc_channel_data        <= 32'h0000;
			buffer_write_enable     <= 1'b0;
		end
	else if(start)
		begin
		    buffer_write_enable     <= adc_channel_data_ready;
		    adc_data_ready_reg      <= adc_data_ready;
			adc_clock_reg           <= adc_clock;
			adc_clock_reg_1         <= adc_clock_reg;
			adc_data_0_reg          <= adc_data_0;
			
			
			if(adc_data_ready_reg == 1'b1)
			    begin
			        bit_count <= 6'h00;
			    end
			else if((adc_clock_reg_1 == 1'b1) && (adc_clock_reg == 1'b0) && (bit_count < 6'h20))
			    begin
			        bit_count <= bit_count + 1;
			        adc_channel_data <= {adc_channel_data[30:0],adc_data_0_reg};
			        if((bit_count == 6'h1F) && (buffer_full == 1'b0))
			            adc_channel_data_ready <= 1'b1;
			    end
			else
			    adc_channel_data_ready <= 1'b0;
		        
		end
	end


endmodule
