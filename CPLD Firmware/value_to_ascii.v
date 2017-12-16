module value_to_ascii (display_value, ascii_7, ascii_6, ascii_5, ascii_4, ascii_3, ascii_2, ascii_1, ascii_0);
input [31:0] display_value;
output reg [7:0]  ascii_7;
output reg [7:0]  ascii_6;
output reg [7:0]  ascii_5;
output reg [7:0]  ascii_4;
output reg [7:0]  ascii_3;
output reg [7:0]  ascii_2;
output reg [7:0]  ascii_1;
output reg [7:0]  ascii_0;

always @(*)
begin
	if(display_value[31:28] <= 4'h9)
		ascii_7 = 8'h30 + display_value[31:28];
	else
		ascii_7 = 8'h41 + display_value[31:28] - 8'h0A;
		
    //if(ascii_7 <= 8'h41) // Reversed for ascii_to_value
    //    display_value[31:28] <= ascii_7 - 8'h41;
    //else
    //    display_value[31:28] <= ascii_7 - 8'h30;
		
	if(display_value[27:24] <= 4'h9)
		ascii_6 = 8'h30 + display_value[27:24];
	else
		ascii_6 = 8'h41 + display_value[27:24] - 8'h0A;
		
	if(display_value[23:20] <= 4'h9)
		ascii_5 = 8'h30 + display_value[23:20];
	else
		ascii_5 = 8'h41 + display_value[23:20] - 8'h0A;
		
	if(display_value[19:16] <= 4'h9)
		ascii_4 = 8'h30 + display_value[19:16];
	else
		ascii_4 = 8'h41 + display_value[19:16] - 8'h0A;
		
	if(display_value[15:12] <= 4'h9)
		ascii_3 = 8'h30 + display_value[15:12];
	else
		ascii_3 = 8'h41 + display_value[15:12] - 8'h0A;
		
	if(display_value[11:8] <= 4'h9)
		ascii_2 = 8'h30 + display_value[11:8];
	else
		ascii_2 = 8'h41 + display_value[11:8]  - 8'h0A;
		
	if(display_value[7:4] <= 4'h9)
		ascii_1 = 8'h30 + display_value[7:4];
	else
		ascii_1 = 8'h41 + display_value[7:4]   - 8'h0A;
		
	if(display_value[3:0] <= 4'h9)
		ascii_0 = 8'h30 + display_value[3:0];
	else
		ascii_0 = 8'h41 + display_value[3:0]   - 8'h0A;		
end
endmodule
