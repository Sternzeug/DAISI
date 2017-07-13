module rs232_decoder_encoder ( clock, reset, rx, tx, rx_byte, rx_valid);

input				clock;
input				reset;
input				rx;
output reg			tx;
output reg	[7:0]	rx_byte;
output reg 			rx_valid;

reg [9:0] incoming_data;
reg [3:0] rx_count;


always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			rx_byte <= 8'h00;
			rx_valid <= 1'b0;
			incoming_data <= 10'h000;
			rx_count <= 4'h0;
		end
	else
		begin
			incoming_data[9:0] <= {rx, incoming_data[9:1]};
			if((incoming_data[9] == 1'b0) && (incoming_data[8] == 1'b1) && (rx_count == 0))
				begin
					rx_count <= 1;
					rx_valid <= 0;
				end
			else if(rx_count == 9)
				begin
					rx_count <= 0;
					rx_byte <= incoming_data[8:1];
					rx_valid <= 1;
				end
			else if(rx_count > 0)
				begin
					rx_count <= rx_count + 1;
					rx_valid <= 0;
				end
			else
				rx_valid <= 0;
			
		end
	end

reg [9:0] outgoing_data;
reg [3:0] tx_count;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			tx <= 1'b1;
			outgoing_data <= 10'h3FF;
			tx_count <= 4'h0;
		end
	else
		begin
			tx <= outgoing_data[0];
			if((rx_valid == 1'b1) && (tx_count == 0))
				begin
					outgoing_data <= {1'b1, rx_byte[7:0], 1'b0};
					tx_count <= 1;
				end
			else if(tx_count == 9)
				begin
					outgoing_data <= 10'h3FF;
					tx_count <= 0;
				end
			else if(tx_count > 0)
				begin
					outgoing_data <= {1'b1, outgoing_data[9:1]};
					tx_count <= tx_count + 1;
				end
		end
	end


endmodule
