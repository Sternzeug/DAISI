module spi_controller ( clock, reset, wb_cyc, wb_stb, wb_we, wb_adr, wb_dat_i, wb_dat_o, wb_ack);

input				clock;
input				reset;
output reg			wb_cyc;
output reg			wb_stb;
output reg			wb_we;
output reg	[7:0]	wb_adr; 
output reg	[7:0]	wb_dat_i;
input		[7:0]	wb_dat_o;
input				wb_ack;

parameter WRITE_ADDR_DATA	= 3'b000;
parameter WAIT_FOR_ACK		= 3'b001;
parameter IDLE				= 3'b010;
parameter WRITE_ADDR_DATA_2	= 3'b011;
parameter WAIT_FOR_ACK_2	= 3'b101;
parameter IDLE_2			= 3'b110;

reg	[2:0]	state;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			wb_cyc		<= 1'b0;
			wb_stb		<= 1'b0;
			wb_we		<= 1'b0;
			wb_adr		<= 8'h00;
			wb_dat_i	<= 8'h00;
			state		<= 2'b00;
		end
	else
		begin
			case(state)
				WRITE_ADDR_DATA : 
					begin
						state		<= WAIT_FOR_ACK;
						wb_cyc		<= 1'b1;
						wb_stb		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h59;
						wb_dat_i	<= 8'h91;
					end
				WAIT_FOR_ACK : 
					begin
						if(wb_ack)
							state		<= IDLE;
						else
							state		<= WAIT_FOR_ACK;
						wb_cyc		<= wb_cyc;
						wb_stb		<= wb_stb;
						wb_we		<= wb_we;
						wb_adr		<= wb_adr;
						wb_dat_i	<= wb_dat_i;
					end
				IDLE : 
					begin
						if(~wb_ack)
							state		<= WRITE_ADDR_DATA_2;
						else
							state		<= IDLE;
						wb_cyc		<= 1'b0;
						wb_stb		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
				WRITE_ADDR_DATA_2 : 
					begin
						state		<= WAIT_FOR_ACK_2;
						wb_cyc		<= 1'b1;
						wb_stb		<= 1'b1;
						wb_we		<= 1'b0;
						wb_adr		<= 8'h5B;
						wb_dat_i	<= 8'h00;
					end
				WAIT_FOR_ACK_2 : 
					begin
						if(wb_ack)
							state		<= IDLE_2;
						else
							state		<= WAIT_FOR_ACK_2;
						wb_cyc		<= wb_cyc;
						wb_stb		<= wb_stb;
						wb_we		<= wb_we;
						wb_adr		<= wb_adr;
						wb_dat_i	<= wb_dat_i;
					end
				IDLE_2 : 
					begin
						state		<= IDLE_2;
						wb_cyc		<= 1'b0;
						wb_stb		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
				default : 
					begin
						state		<= 3'b000;
						wb_cyc		<= 1'b0;
						wb_stb		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
			endcase
					
		end
	end


endmodule
