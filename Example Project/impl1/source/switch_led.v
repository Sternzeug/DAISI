module Default_w_standby_top ( stdby_in, stdby1, switch0, switch1, switch2, switch3, switch3_gnd, echo, trig, osc_clk, led0, led1, led2, led3, led4, led5, led6, led7, tx, rx );

input	stdby_in;
output	stdby1, osc_clk;
input 	rx;
output 	tx;
input	switch0, switch1, switch2, switch3;
output 	switch3_gnd;
output	led0, led1, led2, led3, led4, led5, led6, led7;

input	echo;
output	trig;

wire	stby_flag ;

assign switch3_gnd = 1'b0;

assign tx = rx;
// Internal Oscillator
defparam OSCH_inst.NOM_FREQ = "20.46";		//  This is the default frequency

OSCH OSCH_inst( .STDBY(stdby1 ), 		// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
                .OSC(osc_clk),
                .SEDSTDBY());		//  this signal is not required if not using SED - see TN1199 for more details.


pwr_cntrllr pcm1 (.USERSTDBY(stdby_in ), .CLRFLAG(stby_flag ), .CFGSTDBY(1'b0 ),  
    .STDBY(stdby1 ), .SFLAG(stby_flag ) );


assign led0 = switch0;
assign led1 = switch1;
assign led2 = switch2;
assign led3 = switch3;

assign led4 = 1'b1;
assign led5 = 1'b1;
assign led6 = 1'b1;
assign led7 = 1'b1;
reg [15:0] count;
reg slow_clk; 
always@(posedge osc_clk)
	begin
	if (count == 8525)
		begin
		slow_clk <= ~slow_clk;
		count <= 0;
		end
	else
		count <= count + 1;
	end
endmodule
