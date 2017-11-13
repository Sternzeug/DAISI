module rs232_decoder_encoder ( clock, clock_4x, reset, rx, tx, rx_byte, rx_valid, tx_bytes, tx_num_bytes, tx_valid);

parameter MAX_BYTES	= 11;

input				clock;
input               clock_4x;
input				reset;
input				rx;
input [MAX_BYTES*8-1:0]    tx_bytes;
input [3:0]                tx_num_bytes;
input                      tx_valid;
output reg			tx;
output reg	[7:0]	rx_byte;
output reg 			rx_valid;

reg [9:0] incoming_data;
reg [3:0] rx_count;

reg       rx_reg;
reg [2:0] rx_sample_count;
reg [2:0] rx_sample_time;


always@(posedge clock_4x or posedge reset)
    begin
        if(reset)
            begin
                rx_reg          <= 1'b0;
                rx_sample_time  <= 3'h4;
                rx_sample_count <= 3'h0;
                
                rx_byte         <= 8'h00;
			    rx_valid        <= 1'b0;
			    incoming_data   <= 10'h000;
			    rx_count        <= 4'h0;
            end
        else
            begin
                rx_reg  <= rx;
                if((rx_reg != rx) || (rx_sample_count == rx_sample_time))
                    begin
                        rx_sample_count <= 3'h0;
                        if(rx_reg != rx)
                            rx_sample_time  <= 3'h4;
                        else 
                            rx_sample_time  <= 3'h3;
                   
                        incoming_data[9:0] <= {rx, incoming_data[9:1]};
			            if((incoming_data[9] == 1'b0) && (incoming_data[8] == 1'b1) && (rx_count == 0))
				            begin
					            rx_count    <= 1;
					            rx_valid    <= 0;
				            end
			            else if(rx_count == 9)
				            begin
					            rx_count    <= 0;
					            rx_byte     <= incoming_data[8:1];
					            rx_valid    <= 1;
				            end
			            else if(rx_count > 0)
				            begin
					            rx_count    <= rx_count + 1;
					            rx_valid    <= 0;
				            end
			            else
				            rx_valid <= 0;   
				    end
                else
                    rx_sample_count <= rx_sample_count + 3'h1;
            end
    end


reg [9:0] outgoing_data;
reg [3:0] tx_count;
reg [MAX_BYTES*8-1:0]    tx_bytes_reg;
reg [3:0] tx_byte_count;
reg tx_start;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			tx <= 1'b1;
			outgoing_data <= 10'h3FF;
			tx_count <= 4'h0;
			tx_bytes_reg <= 0;
			tx_byte_count <= 0;
			tx_start <= 0;
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
				    outgoing_data <= {1'b1, tx_bytes_reg[MAX_BYTES*8-1:(MAX_BYTES-1)*8], 1'b0};
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
