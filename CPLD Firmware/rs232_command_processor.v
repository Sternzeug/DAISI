module rs232_command_processor (    clock, reset, rs_232_reset, rx_byte, rx_valid, command_valid, tx_bytes, tx_num_bytes, tx_valid, 
                                    adc_data_ch1, adc_data_ch2, adc_data_ch3, adc_data_ch4, adc_data_ch5, adc_data_ch6, adc_data_ch7, adc_data_ch8,
                                    adc_data_ready_ch1, adc_data_ready_ch2, adc_data_ready_ch3, adc_data_ready_ch4,
                                    adc_data_ready_ch5, adc_data_ready_ch6, adc_data_ready_ch7, adc_data_ready_ch8);

parameter MAX_BYTES	= 14;

parameter COMMAND_1_RX_BYTES	= 3;
parameter COMMAND_1_TX_BYTES	= 4;

parameter COMMAND_2_RX_BYTES	= 5;
parameter COMMAND_2_TX_BYTES	= 0;

parameter COMMAND_3_RX_BYTES	= 10;
parameter COMMAND_3_TX_BYTES	= 8;

parameter COMMAND_4_RX_BYTES	= 10;
parameter COMMAND_4_TX_BYTES	= 8;

parameter COMMAND_5_RX_BYTES	= 10;
parameter COMMAND_5_TX_BYTES	= 8;

parameter COMMAND_6_RX_BYTES	= 10;
parameter COMMAND_6_TX_BYTES	= 8;

parameter COMMAND_7_RX_BYTES	= 10;
parameter COMMAND_7_TX_BYTES	= 8;

parameter COMMAND_8_RX_BYTES	= 10;
parameter COMMAND_8_TX_BYTES	= 8;

parameter COMMAND_9_RX_BYTES	= 10;
parameter COMMAND_9_TX_BYTES	= 8;

parameter COMMAND_10_RX_BYTES	= 10;
parameter COMMAND_10_TX_BYTES	= 8;

parameter COMMAND_11_RX_BYTES	= 14;
parameter COMMAND_11_TX_BYTES	= 8;

input	        clock;
input	        reset;
input   [ 7:0]	rx_byte;
input 			rx_valid;
input   [31:0]  adc_data_ch1;
input   [31:0]  adc_data_ch2;
input   [31:0]  adc_data_ch3;
input   [31:0]  adc_data_ch4;
input   [31:0]  adc_data_ch5;
input   [31:0]  adc_data_ch6;
input   [31:0]  adc_data_ch7;
input   [31:0]  adc_data_ch8;
input           adc_data_ready_ch1;
input           adc_data_ready_ch2;
input           adc_data_ready_ch3;
input           adc_data_ready_ch4;
input           adc_data_ready_ch5;
input           adc_data_ready_ch6;
input           adc_data_ready_ch7;
input           adc_data_ready_ch8;

output reg [7:0]	            command_valid;
output reg [MAX_BYTES*8-1:0]    tx_bytes;
output reg [3:0]                tx_num_bytes;
output reg                      tx_valid;

output reg						rs_232_reset;

reg  [31:0] display_value_ch1;
wire [7:0]  volt1_ascii_7;
wire [7:0]  volt1_ascii_6;
wire [7:0]  volt1_ascii_5;
wire [7:0]  volt1_ascii_4;
wire [7:0]  volt1_ascii_3;
wire [7:0]  volt1_ascii_2;
wire [7:0]  volt1_ascii_1;
wire [7:0]  volt1_ascii_0;

reg  [31:0] display_value_ch2;
wire [7:0]  volt2_ascii_7;
wire [7:0]  volt2_ascii_6;
wire [7:0]  volt2_ascii_5;
wire [7:0]  volt2_ascii_4;
wire [7:0]  volt2_ascii_3;
wire [7:0]  volt2_ascii_2;
wire [7:0]  volt2_ascii_1;
wire [7:0]  volt2_ascii_0;

reg  [31:0] display_value_ch3;
wire [7:0]  volt3_ascii_7;
wire [7:0]  volt3_ascii_6;
wire [7:0]  volt3_ascii_5;
wire [7:0]  volt3_ascii_4;
wire [7:0]  volt3_ascii_3;
wire [7:0]  volt3_ascii_2;
wire [7:0]  volt3_ascii_1;
wire [7:0]  volt3_ascii_0;

reg  [31:0] display_value_ch4;
wire [7:0]  volt4_ascii_7;
wire [7:0]  volt4_ascii_6;
wire [7:0]  volt4_ascii_5;
wire [7:0]  volt4_ascii_4;
wire [7:0]  volt4_ascii_3;
wire [7:0]  volt4_ascii_2;
wire [7:0]  volt4_ascii_1;
wire [7:0]  volt4_ascii_0;

reg  [31:0] display_value_ch5;
wire [7:0]  volt5_ascii_7;
wire [7:0]  volt5_ascii_6;
wire [7:0]  volt5_ascii_5;
wire [7:0]  volt5_ascii_4;
wire [7:0]  volt5_ascii_3;
wire [7:0]  volt5_ascii_2;
wire [7:0]  volt5_ascii_1;
wire [7:0]  volt5_ascii_0;

reg  [31:0] display_value_ch6;
wire [7:0]  volt6_ascii_7;
wire [7:0]  volt6_ascii_6;
wire [7:0]  volt6_ascii_5;
wire [7:0]  volt6_ascii_4;
wire [7:0]  volt6_ascii_3;
wire [7:0]  volt6_ascii_2;
wire [7:0]  volt6_ascii_1;
wire [7:0]  volt6_ascii_0;

reg  [31:0] display_value_ch7;
wire [7:0]  volt7_ascii_7;
wire [7:0]  volt7_ascii_6;
wire [7:0]  volt7_ascii_5;
wire [7:0]  volt7_ascii_4;
wire [7:0]  volt7_ascii_3;
wire [7:0]  volt7_ascii_2;
wire [7:0]  volt7_ascii_1;
wire [7:0]  volt7_ascii_0;

reg  [31:0] display_value_ch8;
wire [7:0]  volt8_ascii_7;
wire [7:0]  volt8_ascii_6;
wire [7:0]  volt8_ascii_5;
wire [7:0]  volt8_ascii_4;
wire [7:0]  volt8_ascii_3;
wire [7:0]  volt8_ascii_2;
wire [7:0]  volt8_ascii_1;
wire [7:0]  volt8_ascii_0;

reg  [31:0] display_value_memory;
wire [7:0]  mem_ascii_7;
wire [7:0]  mem_ascii_6;
wire [7:0]  mem_ascii_5;
wire [7:0]  mem_ascii_4;
wire [7:0]  mem_ascii_3;
wire [7:0]  mem_ascii_2;
wire [7:0]  mem_ascii_1;
wire [7:0]  mem_ascii_0;

wire [31:0]  value_memory_index;
reg  [7:0]   ascii_7;
reg  [7:0]   ascii_6;
reg  [7:0]   ascii_5;
reg  [7:0]   ascii_4;
reg  [7:0]   ascii_3;
reg  [7:0]   ascii_2;
reg  [7:0]   ascii_1;
reg  [7:0]   ascii_0;

value_to_ascii value_to_ascii_inst_voltch1(
					.display_value(display_value_ch1),
					.ascii_7(volt1_ascii_7),
					.ascii_6(volt1_ascii_6),
					.ascii_5(volt1_ascii_5),
					.ascii_4(volt1_ascii_4),
					.ascii_3(volt1_ascii_3),
					.ascii_2(volt1_ascii_2),
					.ascii_1(volt1_ascii_1),
					.ascii_0(volt1_ascii_0));

value_to_ascii	value_to_ascii_inst_voltch2(
					.display_value(display_value_ch2),
					.ascii_7(volt2_ascii_7),
					.ascii_6(volt2_ascii_6),
					.ascii_5(volt2_ascii_5),
					.ascii_4(volt2_ascii_4),
					.ascii_3(volt2_ascii_3),
					.ascii_2(volt2_ascii_2),
					.ascii_1(volt2_ascii_1),
					.ascii_0(volt2_ascii_0));				

value_to_ascii	value_to_ascii_inst_voltch3(
					.display_value(display_value_ch3),
					.ascii_7(volt3_ascii_7),
					.ascii_6(volt3_ascii_6),
					.ascii_5(volt3_ascii_5),
					.ascii_4(volt3_ascii_4),
					.ascii_3(volt3_ascii_3),
					.ascii_2(volt3_ascii_2),
					.ascii_1(volt3_ascii_1),
					.ascii_0(volt3_ascii_0));						

value_to_ascii	value_to_ascii_inst_voltch4(
					.display_value(display_value_ch4),
					.ascii_7(volt4_ascii_7),
					.ascii_6(volt4_ascii_6),
					.ascii_5(volt4_ascii_5),
					.ascii_4(volt4_ascii_4),
					.ascii_3(volt4_ascii_3),
					.ascii_2(volt4_ascii_2),
					.ascii_1(volt4_ascii_1),
					.ascii_0(volt4_ascii_0));

value_to_ascii	value_to_ascii_inst_voltch5(
					.display_value(display_value_ch5),
					.ascii_7(volt5_ascii_7),
					.ascii_6(volt5_ascii_6),
					.ascii_5(volt5_ascii_5),
					.ascii_4(volt5_ascii_4),
					.ascii_3(volt5_ascii_3),
					.ascii_2(volt5_ascii_2),
					.ascii_1(volt5_ascii_1),
					.ascii_0(volt5_ascii_0));

value_to_ascii	value_to_ascii_inst_voltch6(
					.display_value(display_value_ch6),
					.ascii_7(volt6_ascii_7),
					.ascii_6(volt6_ascii_6),
					.ascii_5(volt6_ascii_5),
					.ascii_4(volt6_ascii_4),
					.ascii_3(volt6_ascii_3),
					.ascii_2(volt6_ascii_2),
					.ascii_1(volt6_ascii_1),
					.ascii_0(volt6_ascii_0));

value_to_ascii	value_to_ascii_inst_voltch7(
					.display_value(display_value_ch7),
					.ascii_7(volt7_ascii_7),
					.ascii_6(volt7_ascii_6),
					.ascii_5(volt7_ascii_5),
					.ascii_4(volt7_ascii_4),
					.ascii_3(volt7_ascii_3),
					.ascii_2(volt7_ascii_2),
					.ascii_1(volt7_ascii_1),
					.ascii_0(volt7_ascii_0));

value_to_ascii	value_to_ascii_inst_voltch8(
					.display_value(display_value_ch8),
					.ascii_7(volt8_ascii_7),
					.ascii_6(volt8_ascii_6),
					.ascii_5(volt8_ascii_5),
					.ascii_4(volt8_ascii_4),
					.ascii_3(volt8_ascii_3),
					.ascii_2(volt8_ascii_2),
					.ascii_1(volt8_ascii_1),
					.ascii_0(volt8_ascii_0));
			
value_to_ascii value_to_ascii_inst_memory(
 					//.display_value(display_value_memory),
					.display_value(value_memory_index),
 					.ascii_7(mem_ascii_7),
 					.ascii_6(mem_ascii_6),
 					.ascii_5(mem_ascii_5),
 					.ascii_4(mem_ascii_4),
 					.ascii_3(mem_ascii_3),
 					.ascii_2(mem_ascii_2),
 					.ascii_1(mem_ascii_1),
 					.ascii_0(mem_ascii_0));
					
ascii_to_value ascii_to_value_inst_memory(
 					.value(value_memory_index),
 					.ascii_7(ascii_7),
 					.ascii_6(ascii_6),
 					.ascii_5(ascii_5),
 					.ascii_4(ascii_4),
 					.ascii_3(ascii_3),
 					.ascii_2(ascii_2),
 					.ascii_1(ascii_1),
 					.ascii_0(ascii_0));
					
reg [1:0]   rx_valid_reg;
reg [7:0]   rx_byte_reg;
reg         tx_valid_reg;
reg         tx_valid_delay;

reg [MAX_BYTES*8-1:0]   rx_bytes;
	
always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			rs_232_reset            <= 0;
			rx_valid_reg            <= 2'b00;
			rx_byte_reg             <= 8'h00;
			rx_bytes                <= 0;
			command_valid           <= 0;
			tx_bytes                <= 0;
			tx_num_bytes            <= 0;
			tx_valid                <= 0;
			tx_valid_reg            <= 0;
			tx_valid_delay          <= 0;
			display_value_ch1       <= 32'h00000001; //0;
			display_value_ch2       <= 32'h00000002; //0;
			display_value_ch3       <= 32'h00000003; //0;
			display_value_ch4       <= 32'h00000004; //0;
			display_value_ch5       <= 32'h00000005; //0;
			display_value_ch6       <= 32'h00000006; //0;
			display_value_ch7       <= 32'h00000007; //0;
			display_value_ch8       <= 32'h00000008; //0;
			display_value_memory    <= 32'h000ABCDF; //0;
			ascii_0                 <= 0;
			ascii_1                 <= 0;
			ascii_2                 <= 0;
			ascii_3                 <= 0;
			ascii_4                 <= 0;
			ascii_5                 <= 0;
			ascii_6                 <= 0;
			ascii_7                 <= 0;
		end
	else
		begin
			rx_valid_reg    <= {rx_valid_reg[0],rx_valid};
			rx_byte_reg     <= rx_byte;
			tx_valid        <= tx_valid_reg;
			
			if(adc_data_ready_ch1 == 1'b1)
			    display_value_ch1  <= adc_data_ch1;
			if(adc_data_ready_ch2 == 1'b1)
			    display_value_ch2  <= adc_data_ch2;
			if(adc_data_ready_ch3 == 1'b1)
			    display_value_ch3  <= adc_data_ch3;
			if(adc_data_ready_ch4 == 1'b1)
			    display_value_ch4  <= adc_data_ch4;
			if(adc_data_ready_ch5 == 1'b1)
			    display_value_ch5  <= adc_data_ch5;
			if(adc_data_ready_ch6 == 1'b1)
			    display_value_ch6  <= adc_data_ch6;
			if(adc_data_ready_ch7 == 1'b1)
			    display_value_ch7  <= adc_data_ch7;
			if(adc_data_ready_ch8 == 1'b1)
			    display_value_ch8  <= adc_data_ch8;
			
			if((rx_valid_reg[1] == 0) && (rx_valid_reg[0] == 1))
				begin
					
					rx_bytes  <= {rx_bytes[(MAX_BYTES-1)*8-1:0],rx_byte_reg};
					
					//rx_bytes[MAX_BYTES*8-1:8] <= rx_bytes[(MAX_BYTES-1)*8-1:0];
					//rx_bytes[7:0] <= rx_byte;
					
					if(rx_byte_reg == 8'h0D) // Detect carriage return
					    begin
					        if(rx_bytes[COMMAND_1_RX_BYTES*8-1:0] == "cmd")
						        begin
							        command_valid           <= 1;
							        tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_1_TX_BYTES-1)*8]  <= {"resp",8'h0D};
							        tx_num_bytes            <= COMMAND_1_TX_BYTES+1;
							        tx_valid_reg            <= 1;
						        end
					        else if(rx_bytes[COMMAND_2_RX_BYTES*8-1:0] == "reset")
						        begin
							        command_valid           <= 2;
									rs_232_reset            <= 1;
						        end
							else if(rx_bytes[COMMAND_3_RX_BYTES*8-1:0] == "voltagech1")
								begin
									command_valid           <= 3;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_3_TX_BYTES-1)*8]  <= {    volt1_ascii_7, volt1_ascii_6, volt1_ascii_5, volt1_ascii_4, 
									                                                                    volt1_ascii_3, volt1_ascii_2, volt1_ascii_1, volt1_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_3_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end
							else if(rx_bytes[COMMAND_4_RX_BYTES*8-1:0] == "voltagech2")
								begin
									command_valid           <= 4;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_4_TX_BYTES-1)*8]  <= {    volt2_ascii_7, volt2_ascii_6, volt2_ascii_5, volt2_ascii_4, 
									                                                                    volt2_ascii_3, volt2_ascii_2, volt2_ascii_1, volt2_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_4_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end
							else if(rx_bytes[COMMAND_5_RX_BYTES*8-1:0] == "voltagech3")
								begin
									command_valid           <= 5;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_5_TX_BYTES-1)*8]  <= {    volt3_ascii_7, volt3_ascii_6, volt3_ascii_5, volt3_ascii_4, 
									                                                                    volt3_ascii_3, volt3_ascii_2, volt3_ascii_1, volt3_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_5_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end								
							else if(rx_bytes[COMMAND_6_RX_BYTES*8-1:0] == "voltagech4")
								begin
									command_valid           <= 6;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_6_TX_BYTES-1)*8]  <= {    volt4_ascii_7, volt4_ascii_6, volt4_ascii_5, volt4_ascii_4,
									                                                                    volt4_ascii_3, volt4_ascii_2, volt4_ascii_1, volt4_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_6_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end								
							else if(rx_bytes[COMMAND_7_RX_BYTES*8-1:0] == "voltagech5")
								begin
									command_valid           <= 7;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_7_TX_BYTES-1)*8]  <= {    volt5_ascii_7, volt5_ascii_6, volt5_ascii_5, volt5_ascii_4, 
									                                                                    volt5_ascii_3, volt5_ascii_2, volt5_ascii_1, volt5_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_7_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end								
							else if(rx_bytes[COMMAND_8_RX_BYTES*8-1:0] == "voltagech6")
								begin
									command_valid           <= 8;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_8_TX_BYTES-1)*8]  <= {    volt6_ascii_7, volt6_ascii_6, volt6_ascii_5, volt6_ascii_4, 
									                                                                    volt6_ascii_3, volt6_ascii_2, volt6_ascii_1, volt6_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_8_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end								
							else if(rx_bytes[COMMAND_9_RX_BYTES*8-1:0] == "voltagech7")
								begin
									command_valid           <= 9;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_9_TX_BYTES-1)*8]  <= {    volt7_ascii_7, volt7_ascii_6, volt7_ascii_5, volt7_ascii_4, 
									                                                                    volt7_ascii_3, volt7_ascii_2, volt7_ascii_1, volt7_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_9_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end								
							else if(rx_bytes[COMMAND_10_RX_BYTES*8-1:0] == "voltagech8")
								begin
									command_valid           <= 10;
									tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_10_TX_BYTES-1)*8]  <= {   volt8_ascii_7, volt8_ascii_6, volt8_ascii_5, volt8_ascii_4, 
									                                                                    volt8_ascii_3, volt8_ascii_2, volt8_ascii_1, volt8_ascii_0, 8'h0D};
							        tx_num_bytes            <= COMMAND_10_TX_BYTES+1;
							        tx_valid_reg            <= 1;
								end						
							else if(rx_bytes[COMMAND_11_RX_BYTES*8-1:64] == "memory")
								begin
									command_valid           <= 11;
									//tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_11_TX_BYTES-1)*8]  <= {   mem_ascii_7, mem_ascii_6, mem_ascii_5, mem_ascii_4, 
									//                                                                    mem_ascii_3, mem_ascii_2, mem_ascii_1, mem_ascii_0, 8'h0D};
							        //tx_num_bytes           <= COMMAND_11_TX_BYTES+1;
							        //tx_valid_reg           <= 1;
							        tx_valid_delay          <= 1;
									ascii_0				    <= rx_bytes[7:0];
									ascii_1				    <= rx_bytes[15:8];
									ascii_2				    <= rx_bytes[23:16];
									ascii_3				    <= rx_bytes[31:24];
									ascii_4				    <= rx_bytes[39:32];
									ascii_5				    <= rx_bytes[47:40];
									ascii_6				    <= rx_bytes[55:48];
									ascii_7				    <= rx_bytes[63:56];
								end
					    end
					else
					    begin
						 // command_valid <= 0;
						    tx_valid_reg <= 0;
						end
				end
		    else if(tx_valid_delay == 1)
		        begin
		            tx_valid_delay <= 0;
		            if(command_valid == 11)
		                begin
		                    tx_bytes[MAX_BYTES*8-1:(MAX_BYTES-COMMAND_11_TX_BYTES-1)*8]  <= {   mem_ascii_7, mem_ascii_6, mem_ascii_5, mem_ascii_4, 
									                                                            mem_ascii_3, mem_ascii_2, mem_ascii_1, mem_ascii_0, 8'h0D};
							tx_num_bytes           <= COMMAND_11_TX_BYTES+1;
							tx_valid_reg           <= 1;
		                end
		        end
			else if(rx_valid_reg[0] == 0)
			    tx_valid_reg <= 0;
		end
	end
endmodule
