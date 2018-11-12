module pseudo_adc ( clock, reset, source, adc_count);

input	            clock;
input	            reset;
inout	            source;
output      [19:0]  adc_count;

reg                 source_reg;
reg         [21:0]  count_sum;
reg         [19:0]  count_1;
reg         [19:0]  count_2;
reg         [19:0]  count_3;
reg         [19:0]  count_4;
reg         [19:0]  counter;
reg                 switch_direction;

assign source = (switch_direction) ? 1'b0 : 1'bz;
assign adc_count = count_sum[21:2];

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    source_reg          <= 0;
		    count_sum           <= 0;
		    count_1             <= 0;
		    count_2             <= 0;
		    count_3             <= 0;
		    count_4             <= 0;
		    counter             <= 0;
			switch_direction    <= 1;
		end
	else
		begin
		    source_reg          <= source;
			if((switch_direction == 1'b0) && (source_reg == 1'b1))
			    begin
			        count_sum           <= {2'b00,count_1} + {2'b00,count_2} + {2'b00,count_3} + {2'b00,count_4};
			        count_1             <= counter;
			        count_2             <= count_1;
			        count_3             <= count_2;
			        count_4             <= count_3;
			        switch_direction    <= 1'b1;
			        counter             <= 0;
			    end
			else if((switch_direction == 1'b1) && (counter == 20'h1FFF))
			    begin
			        switch_direction    <= 1'b0;
			        counter             <= 0;
			    end
			else if((switch_direction == 1'b0) || (source_reg == 1'b0))
			    begin
			        if(counter < 20'hFFFFF)
			            counter <= counter + 1;
			    end
			else
			    counter <= 0;
		end
	end


endmodule
