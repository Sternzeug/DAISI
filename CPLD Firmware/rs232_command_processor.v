module rs232_command_processor ( clock, reset, rs_232_reset, rx_byte, rx_valid, command_valid, tx_bytes, tx_num_bytes, tx_valid, adc_data, adc_data_valid);

parameter MAX_BYTES	= 11;

parameter COMMAND_1_RX_BYTES	= 3;
parameter COMMAND_1_TX_BYTES	= 4;

parameter COMMAND_2_RX_BYTES	= 5;
parameter COMMAND_2_TX_BYTES	= 0;

parameter COMMAND_3_RX_BYTES	= 10;
parameter COMMAND_3_TX_BYTES	= 8;

parameter COMMAND_4_RX_BYTES	= 10;
parameter COMMAND_4_TX_BYTES	= 8;

input	        clock;
input	        reset;
input   [ 7:0]	rx_byte;
input 			rx_valid;
input   [31:0]  adc_data;
input           adc_data_valid;

output reg [7:0]	            command_valid;
output reg [MAX_BYTES*8-1:0]    tx_bytes;
output reg [3:0]                tx_num_bytes;
output reg                      tx_valid;

output reg						rs_232_reset;

reg  [31:0] display_value_volt;
wire [7:0]  volt_ascii_7;
wire [7:0]  volt_ascii_6;
wire [7:0]  volt_ascii_5;
wire [7:0]  volt_ascii_4;
wire [7:0]  volt_ascii_3;
wire [7:0]  volt_ascii_2;
wire [7:0]  volt_ascii_1;
wire [7:0]  volt_ascii_0;

wire [31:0] display_value_memory;
wire [7:0]  mem_ascii_7;
wire [7:0]  mem_ascii_6;
wire [7:0]  mem_ascii_5;
wire [7:0]  mem_ascii_4;
wire [7:0]  mem_ascii_3;
wire [7:0]  mem_ascii_2;
wire [7:0]  mem_ascii_1;
wire [7:0]  mem_ascii_0;

//assign display_value_volt = 32'h0123ABCD;
assign display_value_memory = 32'h11110AAF;

value_to_ascii value_to_ascii_inst_volt(
					.display_value(display_value_volt),
					.value_ascii_7(volt_ascii_7),
					.value_ascii_6(volt_ascii_6),
					.value_ascii_5(volt_ascii_5),
					.value_ascii_4(volt_ascii_4),
					.value_ascii_3(volt_ascii_3),
					.value_ascii_2(volt_ascii_2),
					.value_ascii_1(volt_ascii_1),
					.value_ascii_0(volt_ascii_0));

value_to_ascii value_to_ascii_inst_memory(
					.display_value(display_value_memory),
					.value_ascii_7(mem_ascii_7),
					.value_ascii_6(mem_ascii_6),
					.value_ascii_5(mem_ascii_5),
					.value_ascii_4(mem_ascii_4),
					.value_ascii_3(mem_ascii_3),
					.value_ascii_2(mem_ascii_2),
					.value_ascii_1(mem_ascii_1),
					.value_ascii_0(mem_ascii_0));
				
reg rx_valid_last;

reg [MAX_BYTES*8-1:0]   rx_bytes;
	
always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			rs_232_reset        <= 0;
			rx_valid_last       <= 0;
			rx_bytes            <= 0;
			command_valid       <= 0;
			tx_bytes            <= 0;
			tx_num_bytes        <= 0;
			tx_valid            <= 0;
			display_value_volt  <= 0;
		end
	else
		begin
			rx_valid_last <= rx_valid;
			
			if(adc_data_valid == 1'b1)
			    display_value_volt  <= adc_data;
			
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
							else if({rx_bytes[COMMAND_3_RX_BYTES*8-1:0]} == "voltagech1")
								begin
									command_valid <= 3;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_3_TX_BYTES-1)*8]  <= {volt_ascii_7, volt_ascii_6, volt_ascii_5, volt_ascii_4, volt_ascii_3, volt_ascii_2, volt_ascii_1, volt_ascii_0, 8'h0D};
							        tx_num_bytes           <= COMMAND_3_TX_BYTES+1;
							        tx_valid               <= 1;
								end
							else if({rx_bytes[COMMAND_4_RX_BYTES*8-1:0]} == "getmemory8")
								begin
									command_valid <= 4;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_4_TX_BYTES-1)*8]  <= {mem_ascii_7, mem_ascii_6, mem_ascii_5, mem_ascii_4, mem_ascii_3, mem_ascii_2, mem_ascii_1, mem_ascii_0, 8'h0D};
							        tx_num_bytes           <= COMMAND_4_TX_BYTES+1;
							        tx_valid               <= 1;
								end
					    end
					else
					    begin
						 //   command_valid <= 0;
						    tx_valid <= 0;
						end
				end
			else if(rx_valid == 0)
			    tx_valid <= 0;
		end
	end
endmodule
