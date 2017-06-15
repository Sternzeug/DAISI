module storage_interface ( clock, reset, signal);

input	clock;
input	reset;
output	signal;

reg signal;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			signal <= 1'b1;
		end
	else
		begin
			signal <= ~signal;
		end
	end


endmodule
