module rs232_decoder_encoder ( clock, reset, rx, tx, rx_byte);

input	clock;
input	reset;
input	rx;
output	tx;
output reg	[7:0] rx_byte;

reg [9:0] incoming_data;
reg [3:0] count;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			rx_byte <= 8'h00;
			incoming_data <= 10'h000;
			count <= 4'h0;
		end
	else
		begin
			incoming_data[9:0] <= {incoming_data[8:0], rx};
			if((incoming_data[9] == 1'b1) && (incoming_data[8] == 1'b0) && (count == 0))
				count <= 1;
			else if(count == 8)
				begin
					count <= 0;
					rx_byte <= incoming_data[8:1];
				end
			else if(count > 0)
				count <= count + 1;
			
		end
	end


endmodule
