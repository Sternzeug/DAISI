module rs232_command_processor ( clock, reset, rs_232_reset, rx_byte, rx_valid, command_valid, tx_bytes, tx_num_bytes, tx_valid);

parameter MAX_BYTES	= 6;

parameter COMMAND_1_RX_BYTES	= 3;
parameter COMMAND_1_TX_BYTES	= 4;

parameter COMMAND_2_RX_BYTES	= 5;
parameter COMMAND_2_TX_BYTES	= 0;


input	        clock;
input	        reset;
input	[7:0]	rx_byte;
input 			rx_valid;

output reg [7:0]	            command_valid;
output reg [MAX_BYTES*8-1:0]    tx_bytes;
output reg [3:0]                tx_num_bytes;
output reg                      tx_valid;

output reg                      rs_232_reset;


reg rx_valid_last;

reg [MAX_BYTES*8-1:0]   rx_bytes;


always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			rx_valid_last   <= 0;
			rx_bytes        <= 0;
			command_valid   <= 0;
			tx_bytes        <= 0;
			tx_num_bytes    <= 0;
			tx_valid        <= 0;
			rs_232_reset    <= 0;
		end
	else
		begin
			rx_valid_last <= rx_valid;
			if((rx_valid_last == 0) && (rx_valid == 1))
				begin
					
					rx_bytes  <= {rx_bytes[(MAX_BYTES-1)*8-1:0],rx_byte};
					
					//rx_bytes[MAX_BYTES*8-1:8] <= rx_bytes[(MAX_BYTES-1)*8-1:0];
					//rx_bytes[7:0] <= rx_byte;
					
					if(rx_byte == 8'h0D) // Detect carriage return
					    begin
					        if({rx_bytes[COMMAND_1_RX_BYTES*8-1:0]} == "cmd")
						        begin
							        command_valid   <= 1;
							        tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_1_TX_BYTES-1)*8]  <= {"resp",8'h0D};
							        tx_num_bytes           <= COMMAND_1_TX_BYTES+1;
							        tx_valid               <= 1;
						        end
					        else if({rx_bytes[COMMAND_2_RX_BYTES*8-1:0]} == "reset")
						        begin
							        command_valid <= 2;
                                    rs_232_reset <= 1;
						        end
					    end
					else
					    begin
						    //command_valid <= 0;
						    tx_valid <= 0;
						end
				end
			else if(rx_valid == 0)
			    tx_valid <= 0;
		end
	end


endmodule
