module Default_w_standby_top ( stdby_in, stdby1, switch0, switch1, switch2, switch3, switch3_gnd, echo, trig, 
								osc_clk, led0, led1, led2, led3, led4, led5, led6, led7 );

input	stdby_in;
output	stdby1, osc_clk;

input	switch0, switch1, switch2, switch3;
output 	switch3_gnd;
output	led0, led1, led2, led3, led4, led5, led6, led7;

input	echo;
output	trig;


wire	stby_flag ;

assign switch3_gnd = 1'b0;


// Internal Oscillator
defparam OSCH_inst.NOM_FREQ = "2.08";		//  This is the default frequency

OSCH OSCH_inst( .STDBY(stdby1 ), 		// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
                .OSC(osc_clk),
                .SEDSTDBY());		//  this signal is not required if not using SED - see TN1199 for more details.


pwr_cntrllr pcm1 (.USERSTDBY(stdby_in ), .CLRFLAG(stby_flag ), .CFGSTDBY(1'b0 ),  
    .STDBY(stdby1 ), .SFLAG(stby_flag ) );


reg				trig;
reg		[17:0] 	count;
reg 	[ 7:0] 	count_save0;
reg 	[ 7:0] 	count_save1;
reg 	[ 7:0] 	count_save2;
reg 	[ 7:0] 	count_save3;
reg 	[ 9:0] 	count_sum;
wire	[ 7:0]	count_average;
reg		[ 7:0]	distance;

assign led0 = stdby_in ? 1'b1 : ~distance[0];
assign led1 = stdby_in ? 1'b1 : ~distance[1];
assign led2 = stdby_in ? 1'b1 : ~distance[2];
assign led3 = stdby_in ? 1'b1 : ~distance[3];
assign led4 = stdby_in ? 1'b1 : ~distance[4];
assign led5 = stdby_in ? 1'b1 : ~distance[5];
assign led6 = stdby_in ? 1'b1 : ~distance[6];
assign led7 = stdby_in ? 1'b1 : ~distance[7];

assign count_average = count_sum[9:2];

always @(*)
begin
	if(count_average[7])
		distance = 7'b10000000;
	else if(count_average[6])
		distance = 7'b01000000;
	else if(count_average[5])
		distance = 7'b00100000;
	else if(count_average[4])
		distance = 7'b00010000;
	else if(count_average[3])
		distance = 7'b00001000;
	else if(count_average[2])
		distance = 7'b00000100;
	else if(count_average[1])
		distance = 7'b00000010;
	else if(count_average[0])
		distance = 7'b00000001;
	else
		distance = 7'b00000000;
end

reg		echo_last;

always @(posedge osc_clk or posedge stdby_in)
begin
	if (stdby_in)
	begin
		count 		<= 0;
		echo_last	<= 0;
		count_save0 <= 0;
		count_save1 <= 0;
		count_save2 <= 0;
		count_save3 <= 0;
		count_sum 	<= 0;
	end
	else
	begin
	    count <= count + 1;
		
		echo_last <= echo;
		
		if(count < 22)
			trig <= 1'b1;
		else
			trig <= 1'b0;
		
		if((count > 30) && (echo_last == 1) && (echo == 0))
		begin
			count_save0 <= count[15:8];
			count_save1 <= count_save0;
			count_save2 <= count_save1;
			count_save3 <= count_save2;
			
			count_sum 	<= count_save0 + count_save1 + count_save2 + count_save3;
		end
	end
end


endmodule
