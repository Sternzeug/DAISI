module temp_decoder_encoder ( clock, clock_4x, reset, rxtx, rx_byte, rx_valid, tx_bytes, tx_num_bytes, tx_valid, tx_switch);

parameter MAX_BYTES	= 5;

input				clock;
input               clock_4x;
input				reset;
inout				rxtx;
input [MAX_BYTES*8-1:0]    tx_bytes;
input [3:0]                tx_num_bytes;
input                      tx_valid;
output reg	[7:0]	rx_byte;
output reg 			rx_valid;
output reg          tx_switch;

reg [9:0] incoming_data;
reg [3:0] rx_count;

reg [1:0] rx_reg;

wire      rx;
reg       tx;

assign rx = (tx_switch) ? 1'b1 : rxtx;

assign rxtx = (tx_switch) ? tx : 1'bz;

always@(posedge clock or posedge reset)
    begin
        if(reset)
            begin
                rx_reg          <= 2'b00;
                
                rx_byte         <= 8'h00;
			    rx_valid        <= 1'b0;
			    incoming_data   <= 10'h000;
			    rx_count        <= 4'h0;
            end
        else
            begin
                rx_reg  <= {rx_reg[0],rx};
                   
                incoming_data[9:0] <= {rx_reg[0], incoming_data[9:1]};
	            if((incoming_data[9] == 1'b0) && (incoming_data[8] == 1'b1) && (rx_count == 0))
		            begin
			            rx_count    <= 1;
			            rx_valid    <= 1'b0;
		            end
	            else if(rx_count == 9)
		            begin
			            rx_count    <= 0;
			            rx_byte     <= incoming_data[8:1];
			            rx_valid    <= 1'b1;
		            end
	            else if(rx_count > 0)
		            begin
			            rx_count    <= rx_count + 1;
			            rx_valid    <= 1'b0;
		            end
	            else
		            rx_valid <= 0;   
            end
    end


reg [9:0]               outgoing_data;
reg [3:0]               tx_count;
reg [MAX_BYTES*8-1:0]   tx_bytes_reg;
reg [3:0]               tx_byte_count;
reg                     tx_start;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			tx              <= 1'b1;
			outgoing_data   <= 10'h3FF;
			tx_count        <= 4'h0;
			tx_bytes_reg    <= 0;
			tx_byte_count   <= 0;
			tx_start        <= 0;
			tx_switch       <= 1'b0;
		end
	else
		begin
			tx <= outgoing_data[0];
			
			if((tx_count == 0) && (tx_start == 0))
			    begin
			        if((tx_valid == 1) && (tx_byte_count == 0))
			            begin
			                tx_bytes_reg <= tx_bytes;
			                tx_start <= 1;
			                tx_byte_count <= 1;
                        end
                    else if (tx_byte_count == tx_num_bytes)
		                begin
		                    tx_byte_count <= 0;
		                    tx_start <= 0;
		                end
                    else if (tx_byte_count > 0)
		                begin
		                    tx_bytes_reg[MAX_BYTES*8-1:0] <= {tx_bytes_reg[(MAX_BYTES-1)*8-1:0],8'hFF};
		                    tx_start <= 1;
		                    tx_byte_count <= tx_byte_count + 1;
		                end
		            
		            else
		                tx_start <= 0;
			    end
			 else
			    tx_start <= 0;
			    
			    
			
			if((tx_start == 1'b1) && (tx_count == 0))
				begin
				    outgoing_data   <= {1'b1, tx_bytes_reg[MAX_BYTES*8-1:(MAX_BYTES-1)*8], 1'b0};
					tx_count        <= 1;
					tx_switch       <= 1'b1;
				end
			else if(tx_count == 10)
				begin
					outgoing_data   <= 10'h3FF;
					tx_count        <= 0;
					tx_switch       <= 1'b0;
				end
			else if(tx_count > 0)
				begin
					outgoing_data   <= {1'b1, outgoing_data[9:1]};
					tx_count        <= tx_count + 1;
					tx_switch       <= 1'b1;
				end
		end
	end


endmodule
