module ascii_to_value (value, ascii_7, ascii_6, ascii_5, ascii_4, ascii_3, ascii_2, ascii_1, ascii_0);
output reg [31:0] value;
input [7:0] ascii_7;
input [7:0] ascii_6;
input [7:0] ascii_5;
input [7:0] ascii_4;
input [7:0] ascii_3;
input [7:0] ascii_2;
input [7:0] ascii_1;
input [7:0] ascii_0;

always @(*)
begin
	if(ascii_7 >= 8'h41)
		value[31:28] <= ascii_7 - 8'h41 + 8'h0A;
	else
		value[31:28] <= ascii_7 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[27:24] <= ascii_6 - 8'h41 + 8'h0A;
	else
		value[27:24] <= ascii_6 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[23:20] <= ascii_5 - 8'h41 + 8'h0A;
	else
		value[23:20] <= ascii_5 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[19:16] <= ascii_4 - 8'h41 + 8'h0A;
	else
		value[19:16] <= ascii_4 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[15:12] <= ascii_3 - 8'h41 + 8'h0A;
	else
		value[15:12] <= ascii_3 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[11:8]  <= ascii_2 - 8'h41 + 8'h0A;
	else
		value[11:8]  <= ascii_2 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[7:4]   <= ascii_1 - 8'h41 + 8'h0A;
	else
		value[7:4]   <= ascii_1 - 8'h30;
	if(ascii_7 >= 8'h41) 
		value[3:0]   <= ascii_0 - 8'h41 + 8'h0A;
	else
		value[3:0]   <= ascii_0 - 8'h30;
end
endmodule
