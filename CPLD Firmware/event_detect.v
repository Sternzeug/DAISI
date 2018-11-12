module event_detect ( clock, reset, adc_count_valid, adc_count, event_detected);

input	            clock;
input	            reset;
input               adc_count_valid;
input signed [23:0] adc_count;

output reg          event_detected;

parameter NOISE_THRESHOLD = 25'sd16106; // ~ 600uV

reg                 adc_count_valid_reg;
reg signed [23:0]   last_adc_count;
reg                 first_sample;
reg                 event_trigger;  

always@(posedge clock or posedge reset)
	begin
	    if(reset)
		    begin
		        adc_count_valid_reg <= 1'b0;
		        last_adc_count      <= 1'b0;
		        first_sample        <= 1'b1;
		        event_trigger       <= 1'b0;
		        event_detected      <= 1'b0;
		    end
	    else
		    begin
			    adc_count_valid_reg <= adc_count_valid;
			
			    if((adc_count_valid_reg == 1'b0) && (adc_count_valid == 1'b1))
			        begin
			        
			            last_adc_count  <= adc_count;
			            first_sample    <= 1'b0;
			            
			            if((first_sample == 1'b0) && (event_trigger == 1'b0) && ((adc_count - last_adc_count) > NOISE_THRESHOLD))
                            event_trigger       <= 1'b1;
                        else if((event_trigger == 1'b1) && (adc_count < last_adc_count))
                            begin
                                event_trigger   <= 1'b0;
                                event_detected  <= 1'b1;
                            end
			        end
			    else
			        event_detected  <= 1'b0;
		    end
	end
endmodule
