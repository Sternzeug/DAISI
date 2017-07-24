module rs232_command_processor ( clock, reset, rx_byte, rx_valid, command_valid);

input	clock;
input	reset;
input	[7:0]	rx_byte;
input 			rx_valid;

output reg  [7:0]	command_valid;

reg rx_valid_last;

reg [7:0] rx_byte_0;
reg [7:0] rx_byte_1;
reg [7:0] rx_byte_2;
reg [7:0] rx_byte_3;
reg [7:0] rx_byte_4;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			rx_valid_last <= 0;
			rx_byte_0 <= 0;
			rx_byte_1 <= 0;
			rx_byte_2 <= 0;
			rx_byte_3 <= 0;
			rx_byte_4 <= 0;
			command_valid <= 0;
		end
	else
		begin
			rx_valid_last <= rx_valid;
			if((rx_valid_last == 0) && (rx_valid == 1))
				begin
					rx_byte_0 <= rx_byte;
					rx_byte_1 <= rx_byte_0;
					rx_byte_2 <= rx_byte_1;
					rx_byte_3 <= rx_byte_2;
					rx_byte_4 <= rx_byte_3;
					
					if((rx_byte_1 == "c") && (rx_byte_0 == "m") && (rx_byte == "d"))
						begin
							command_valid <= 1;
						end
					else if((rx_byte_1 == "c") && (rx_byte_0 == "m") && (rx_byte == "g"))
						begin
							command_valid <= 2;
						end
					else
						command_valid <= 0;
				end
		end
	end


endmodule
