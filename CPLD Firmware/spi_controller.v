module spi_controller ( clock_126, clock, reset, wb_cyc, wb_stb, wb_we, wb_adr, wb_dat_i, wb_dat_o, wb_ack, 
                        adc_sample_start, buffer_read_enable, buffer_data, buffer_ready,
                        adc_disable, sd_disable,
                        adc_init, sd_init_1, sd_init_2, sd_write_error, sd_write_ready, sd_busy,
                        regulator_3_3v_adc_en, regulator_3_3v_sd_en, 
                        record_bytes, record_num_bytes, record_valid,
                        ms_pulse);

parameter MAX_BYTES	= 78; // Override in top.v

input               clock_126;
input				clock;
input				reset;
output reg			wb_cyc;
output    			wb_stb;
output reg			wb_we;
output reg	[7:0]	wb_adr; 
output reg	[7:0]	wb_dat_i;
input		[7:0]	wb_dat_o;
input				wb_ack;

output reg          adc_sample_start;
output reg          buffer_read_enable;
input      [31:0]   buffer_data;
input               buffer_ready;

input               adc_disable;
input               sd_disable;
output reg          adc_init;
output reg          sd_init_1;
output reg          sd_init_2;
output reg          sd_write_error;

output reg          sd_write_ready;
output reg          sd_busy;

input               ms_pulse;
output reg          regulator_3_3v_adc_en;
output reg          regulator_3_3v_sd_en;

input [MAX_BYTES*8-1:0]    record_bytes;
input [7:0]                record_num_bytes;
input                      record_valid;

// Transaction state machine = advances from one SPI transaction to the next, as the SPI controller completes

parameter TRANSACTION_MAIN		                = 6'h00;
parameter TRANSACTION_ADC_RST_EN                = 6'h01;
parameter TRANSACTION_ADC_RST	                = 6'h02;
parameter TRANSACTION_ADC_WAIT                  = 6'h03;
parameter TRANSACTION_ADC_CONF                  = 6'h04;
parameter TRANSACTION_ADC_REF                   = 6'h05;
parameter TRANSACTION_ADC_FORMAT                = 6'h06;
parameter TRANSACTION_ADC_DECIMATION            = 6'h07;
parameter TRANSACTION_ADC_DECIMATION_SET        = 6'h08;
parameter TRANSACTION_ADC_WAIT_2                = 6'h09;
parameter TRANSACTION_ADC_DECIMATION_CLEAR      = 6'h0A;
parameter TRANSACTION_ADC_CHANNEL_GAIN          = 6'h0B;
parameter TRANSACTION_ADC_SYNC_1                = 6'h0C;
parameter TRANSACTION_ADC_SYNC_2                = 6'h0D;
parameter TRANSACTION_SYNC_WAIT                 = 6'h0E;
parameter TRANSACTION_ADC_ERROR_CHECK_1         = 6'h0F;
parameter TRANSACTION_ADC_ERROR_CHECK_2         = 6'h10;
parameter TRANSACTION_ADC_ERROR_CHECK_3         = 6'h11;
parameter TRANSACTION_ADC_ERROR_CHECK_4         = 6'h12;
parameter TRANSACTION_ADC_ERROR_CHECK_5         = 6'h13;
parameter TRANSACTION_ADC_ERROR_CHECK_6         = 6'h14;
parameter TRANSACTION_ADC_ERROR_CHECK_7         = 6'h15;
parameter TRANSACTION_ADC_EN                    = 6'h16;

parameter TRANSACTION_SD_CLK_INIT               = 6'h17;
parameter TRANSACTION_SD_CMD0                   = 6'h18;
parameter TRANSACTION_SD_CMD8                   = 6'h19;   
parameter TRANSACTION_SD_CMD_CLK                = 6'h1A;
parameter TRANSACTION_SD_CMD55                  = 6'h1B;
parameter TRANSACTION_SD_ACMD41                 = 6'h1C; 
parameter TRANSACTION_SD_CMD58                  = 6'h1D;    
parameter TRANSACTION_SD_CMD6                   = 6'h1E;
parameter TRANSACTION_SD_CMD_CLK_2              = 6'h1F;
parameter TRANSACTION_SD_CMD_CLK_3              = 6'h20;
parameter TRANSACTION_SD_CMD24                  = 6'h21;
parameter TRANSACTION_WAIT_FOR_BUFFER_FULL      = 6'h22;
parameter TRANSACTION_SD_CMD24_TOK              = 6'h23;
parameter TRANSACTION_SD_CMD24_DATA             = 6'h24;       
parameter TRANSACTION_SD_CMD24_CRC              = 6'h25;
parameter TRANSACTION_SD_CMD24_RESP             = 6'h26;
parameter TRANSACTION_SD_WAIT_FOR_WRITE_READY   = 6'h27;
parameter TRANSACTION_DONE	                    = 6'h28;	   
parameter TRANSACTION_SD_INIT       = TRANSACTION_SD_CLK_INIT;
parameter TRANSACTION_SD_INIT_2     = TRANSACTION_SD_CMD0;
parameter TRANSACTION_SD_WRITE      = TRANSACTION_SD_CMD_CLK_3;
parameter TRANSACTION_SD_WRITE_CONT = TRANSACTION_WAIT_FOR_BUFFER_FULL;
parameter TRANSACTION_ADC_INIT      = TRANSACTION_ADC_RST_EN;

parameter SPI_DEVICE_ADC            = 6'b000001;
parameter SPI_DEVICE_SD_1           = 6'b000010;
parameter SPI_DEVICE_SD_2           = 6'b000100;

parameter SPI_DEVICE_SD_3           = 6'b001000;
parameter SPI_DEVICE_SD_4           = 6'b010000;
parameter SPI_DEVICE_NONE           = 6'b100000;

/////  84 MHz - Working values /////
//parameter SPI_SD_SLOW               = 8'd49; // 84 MHz / (49 + 1) =  1.68 MHz
//parameter SPI_ADC_FAST              = 8'd03; // 84 MHz / ( 3 + 1) = 21.00 MHz
//parameter SPI_SD_FAST               = 8'd02; // 84 MHz / ( 2 + 1) = 28.00 MHz

/////  126 MHz - Values /////
parameter SPI_SD_SLOW               = 8'd63; // 126 MHz / (63 + 1) =  1.96875 MHz
parameter SPI_ADC_FAST              = 8'd06; // 126 MHz / ( 5 + 1) = 21.00 MHz
parameter SPI_SD_FAST               = 8'd02; // 126 MHz / ( 2 + 1) = 42.00 MHz


reg         done;
reg         done_reg;
	
reg	[5:0]	transaction_state;
reg         transaction_start;
reg         transaction_done;
reg [3:0]   transaction_write_bytes;
reg [3:0]   transaction_read_bytes;

reg [7:0]   write_data_0;
reg [7:0]   write_data_1;
reg [7:0]   write_data_2;
reg [7:0]   write_data_3;
reg [7:0]   write_data_4;
reg [7:0]   write_data_5;

reg [7:0]   read_data_0;
reg [7:0]   read_data_1;
reg [7:0]   read_data_2;
reg [7:0]   read_data_3;
reg [7:0]   read_data_4;
reg [7:0]   read_data_5;

reg [7:0]   read_data_reg_0;
reg [7:0]   read_data_reg_1;
reg [7:0]   read_data_reg_2;
reg [7:0]   read_data_reg_3;
reg [7:0]   read_data_reg_4;
reg [7:0]   read_data_reg_5;

reg [5:0]   spi_device;
reg [7:0]   spi_clock_divider;

reg [15:0]  command_iteration;

reg         continue_transaction;
reg         last_transaction;

reg [31:0]  sd_write_address;
reg [5:0]   sd_spi_device;

reg [15:0]  ms_timer;
reg         ms_timer_reset;

reg [31:0]  data_block_number;

reg         transaction_start_delay;

reg [7:0]   adc_channel_select;


reg [MAX_BYTES*8-1:0]   record_bytes_reg;
reg [7:0]               record_num_bytes_reg;
reg                     record_shift;


always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
		    done_reg                <= 1'b0;
			transaction_state		<= TRANSACTION_MAIN;
			transaction_start       <= 1'b0;
			transaction_done        <= 1'b0;
            transaction_write_bytes <= 4'h0;
            transaction_read_bytes  <= 4'h0;
            write_data_0            <= 8'h00;
            write_data_1            <= 8'h00;
            spi_device              <= SPI_DEVICE_NONE;
            spi_clock_divider       <= SPI_SD_SLOW;
            
            adc_sample_start        <= 1'b0;
            
            command_iteration       <= 0;
            
            continue_transaction    <= 1'b0;
            last_transaction        <= 1'b0;
            
            buffer_read_enable      <= 1'b0;
            
            sd_write_address        <= 32'h0000;
            sd_spi_device           <= SPI_DEVICE_SD_1;
            
            adc_init                <= 1'b0;
            sd_init_1               <= 1'b0;
            sd_init_2               <= 1'b0;
            sd_write_ready          <= 1'b0;
            sd_busy                 <= 1'b0;
            sd_write_error          <= 1'b0;
            
            ms_timer                <= 0;
            ms_timer_reset          <= 1'b0;
            
            regulator_3_3v_sd_en    <= 1'b0;
		    regulator_3_3v_adc_en   <= 1'b0;
		    
		    data_block_number       <= 0;
		    
		    transaction_start_delay <= 1'b0;
		    
		    adc_channel_select      <= 8'h00;
		    
		    record_bytes_reg        <= 0;
		    record_num_bytes_reg    <= 0;
		    record_shift            <= 0;
		    
		    read_data_reg_0         <= 8'h00;
			read_data_reg_1         <= 8'h00;
			read_data_reg_2         <= 8'h00;
			read_data_reg_3         <= 8'h00;
			read_data_reg_4         <= 8'h00;
			read_data_reg_5         <= 8'h00;
		end
	else
		begin
		
		    done_reg    <= done;
		    
		    if((done_reg == 1'b0) && (done == 1'b1))
		        begin
		            transaction_done       <= 1'b1;
		            read_data_reg_0        <= read_data_0;
			        read_data_reg_1        <= read_data_1;
			        read_data_reg_2        <= read_data_2;
			        read_data_reg_3        <= read_data_3;
			        read_data_reg_4        <= read_data_4;
			        read_data_reg_5        <= read_data_5;
		        end
		    else
		        transaction_done       <= 1'b0;
		    
		    transaction_start_delay <= transaction_start;
		    
		    if(ms_timer_reset)
		        begin
		            ms_timer        <= 0;
		            ms_timer_reset  <= 1'b0;
		        end
		    else if(ms_pulse == 1'b1)
		        begin
		            ms_timer        <= ms_timer + 1;
		        end
		    
		    if((record_valid == 1'b1) && (record_num_bytes_reg == 0))
		        begin
		            record_bytes_reg        <= record_bytes;
		            record_num_bytes_reg    <= record_num_bytes;
		        end
		    else if (record_shift == 1'b1)
		        begin
		            record_bytes_reg[MAX_BYTES*8-1:0]   <= {record_bytes_reg[(MAX_BYTES-4)*8-1:0],32'hFFFFFFFF};
                    if(record_num_bytes_reg >= 4)
                        record_num_bytes_reg <= record_num_bytes_reg - 4;
                    else
                        record_num_bytes_reg <= 0;
		        end
		
			case(transaction_state)
				TRANSACTION_MAIN : 
					begin
                        if(ms_timer == 16'd2000)    // Delay startup by 1s
                            begin
                            
                                
                                if(!sd_init_1 && regulator_3_3v_sd_en && !sd_disable)
                                    begin
                                        transaction_state   <= TRANSACTION_SD_INIT;
                                        sd_spi_device       <= SPI_DEVICE_SD_1;
                                    end
                                //else if(!sd_init_2 && regulator_3_3v_sd_en && !sd_disable)
                                //    begin
                                //        transaction_state   <= TRANSACTION_SD_INIT_2;
                                //        sd_spi_device       <= SPI_DEVICE_SD_2;
                                //    end
                                else if(!adc_init && regulator_3_3v_adc_en && !adc_disable)
                                    begin
                                        transaction_state   <= TRANSACTION_ADC_INIT;
                                    end
                                else if(adc_init && sd_init_1)// && sd_init_2)
                                    begin
                                        transaction_state   <= TRANSACTION_SD_WRITE;
                                        //transaction_state   <= TRANSACTION_SD_WRITE_CONT;
                                        sd_spi_device       <= SPI_DEVICE_SD_1;
                                    end
                                else if(adc_init && sd_init_1 && sd_write_ready)// && sd_init_2)
                                    begin
                                        transaction_state   <= TRANSACTION_SD_WRITE_CONT;
                                        sd_spi_device       <= SPI_DEVICE_SD_1;
                                    end
                                else
                                    transaction_state    <= TRANSACTION_MAIN;
                            
                                ms_timer_reset          <= 1'b1;
                            end
                        else
                            begin
                                transaction_state    <= TRANSACTION_MAIN;
                                
                                if(adc_disable)
                                    begin
                                        regulator_3_3v_adc_en   <= 1'b0;
                                        adc_init                <= 1'b0;
                                    end
                                
                                if(sd_disable)
                                    begin
                                        regulator_3_3v_sd_en    <= 1'b0;
                                        sd_write_ready          <= 1'b0;
                                        sd_init_1               <= 1'b0;
                                        //sd_init_2   <= 1'b0;
                                    end
                            
                            
                                if(ms_timer == 16'd1000)
                                    begin
                                        if(sd_init_1 && !adc_disable)
                                            regulator_3_3v_adc_en <= 1'b1;
                                        else if(!sd_disable)
                                            regulator_3_3v_sd_en <= 1'b1;
                                    end
                            end     
                        
                        transaction_start       <= 1'b0;
                        transaction_write_bytes <= 4'h0;
                        transaction_read_bytes  <= 4'h0;
                        write_data_0            <= 8'h00;
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'h00;
                        command_iteration       <= 0;
                        continue_transaction    <= 1'b0;
                        last_transaction        <= 1'b0;
                        buffer_read_enable      <= 1'b0;
					end
				TRANSACTION_SD_CLK_INIT : 
					begin
					    if(transaction_done)
					        begin
                                transaction_start       <= 1'b0;
                                //sd_init_1               <= 1'b0;
                                
                                if(command_iteration == 16'h3FFF)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD0;
                                        command_iteration       <= 0;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CLK_INIT;
                                        command_iteration       <= command_iteration + 1;
                                    end
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CLK_INIT;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_NONE;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'hF;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SD_CMD0 : 
					begin
					    if(transaction_done)
					        begin
					            if(read_data_reg_1 == 8'h01)
                                    transaction_state		<= TRANSACTION_SD_CMD8;
                                else
                                    transaction_state		<= TRANSACTION_SD_CMD0;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD0;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h40; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'h95;
                        transaction_read_bytes  <= 4'h6;
					end
				TRANSACTION_SD_CMD8 : 
					begin
					    if(transaction_done)
					        begin
					            if(read_data_reg_1 == 8'h01)
                                    transaction_state		<= TRANSACTION_SD_CMD_CLK;
                                else
                                    transaction_state		<= TRANSACTION_SD_CMD8;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD8;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h48; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h01;
                        write_data_4            <= 8'hAA;
                        write_data_5            <= 8'h87;
                        transaction_read_bytes  <= 4'h6;
					end
				TRANSACTION_SD_CMD_CLK : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD55;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD_CLK;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_NONE;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h4;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SD_CMD55 : 
					begin
					    if(transaction_done)
					        begin
                                    transaction_state		<= TRANSACTION_SD_ACMD41;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD55;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h77; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'h65;
                        transaction_read_bytes  <= 4'h6;
					end
				TRANSACTION_SD_ACMD41 : 
					begin
					    if(transaction_done)
					        begin
					            if(read_data_reg_1 == 8'h00)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD58;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CMD_CLK;
                                    end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_ACMD41;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h69; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h40;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'h77;
                        transaction_read_bytes  <= 4'h6;
					end
                TRANSACTION_SD_CMD58 : 
					begin
					    if(transaction_done)
					        begin
					            if(read_data_reg_1 == 8'h00)
					                begin
                                        
                                        transaction_state       <= TRANSACTION_SD_CMD6;
                                        sd_write_error          <= 1'b0;
                                    end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD58;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h7A; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h40;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h6;
					end
				TRANSACTION_SD_CMD6 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state       <= TRANSACTION_SD_CMD_CLK_2;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD6;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h46; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h8F;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'h3F;
                        write_data_4            <= 8'hF1;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h6;
					end
				TRANSACTION_SD_CMD_CLK_2 : 
					begin
					    if(transaction_done)
					        begin        
                                if(command_iteration == 16'h000B)
					                begin
                                        transaction_state       <= TRANSACTION_MAIN;
                                        command_iteration       <= 0;
                                        if(sd_spi_device == SPI_DEVICE_SD_1)
                                            sd_init_1           <= 1'b1;
                                        else
                                            sd_init_2           <= 1'b1;
                                        sd_write_error          <= 1'b0;
                                        ms_timer_reset          <= 1'b1;
                                        
                                        //transaction_state       <= TRANSACTION_SD_CMD_CLK_3;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CMD_CLK_2;
                                        command_iteration       <= command_iteration + 1;
                                    end
                                
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD_CLK_2;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h6;
					end
				/////////////////////////////////// High Speed SD ///////////////////////////////////
				TRANSACTION_SD_CMD_CLK_3 : 
					begin
					    if(transaction_done)
					        begin
                                if(command_iteration == 16'h001F)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD24;
                                        command_iteration       <= 0;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CMD_CLK_3;
                                        command_iteration       <= command_iteration + 1;
                                    end
                                
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD_CLK_3;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h4;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SD_CMD24 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_WAIT_FOR_BUFFER_FULL;
                                transaction_start       <= 1'b0;
                                
                                //transaction_state       <= TRANSACTION_MAIN;
                                //command_iteration       <= 0;
                                //if(sd_spi_device == SPI_DEVICE_SD_1)
                                //    sd_init_1           <= 1'b1;
                                //else
                                //    sd_init_2           <= 1'b1;
                                //sd_write_error          <= 1'b0;
                                //ms_timer_reset          <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h59; // {2'b01, 6'b<command index>}
                        write_data_1            <= sd_write_address[31:24];
                        write_data_2            <= sd_write_address[23:16];
                        write_data_3            <= sd_write_address[15: 8];
                        write_data_4            <= sd_write_address[ 7: 0];
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h6;
                        
					end
				TRANSACTION_WAIT_FOR_BUFFER_FULL : 
					begin
					    if(adc_disable || sd_disable)
					        transaction_state		<= TRANSACTION_MAIN;
					    else if(buffer_ready || !sd_write_ready)
					        transaction_state		<= TRANSACTION_SD_CMD24_TOK;
                        else
                            transaction_state		<= TRANSACTION_WAIT_FOR_BUFFER_FULL;
                        spi_device              <= SPI_DEVICE_NONE;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_start       <= 1'b0;
                        transaction_write_bytes <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
                        continue_transaction    <= 1'b1;
					end	
				TRANSACTION_SD_CMD24_TOK : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD24_DATA;
                                transaction_start       <= 1'b0;
                                //buffer_read_enable      <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_TOK;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hFC;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SD_CMD24_DATA : 
					begin
					    if(transaction_done)
					        begin
					            if(command_iteration == 16'h007F) // 127 + 1 iterations (128 * 4 bytes = 512 bytes)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD24_CRC;
                                        command_iteration       <= 0;
                                        buffer_read_enable      <= 1'b0;
                                        record_shift            <= 1'b0;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CMD24_DATA;
                                        command_iteration       <= command_iteration + 1;
                                        if(command_iteration >= 7)
                                            buffer_read_enable      <= 1'b1;
                                        else
                                            record_shift            <= 1'b1;                                  
                                    end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_DATA;
                                transaction_start       <= 1'b1;
                                buffer_read_enable      <= 1'b0;
                                record_shift            <= 1'b0;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h4;
                        
                        if(command_iteration == 0)
                            begin
                                write_data_0            <= data_block_number[31:24];
                                write_data_1            <= data_block_number[23:16];
                                write_data_2            <= data_block_number[15: 8];
                                write_data_3            <= data_block_number[ 7: 0];
                            end
                        else if(command_iteration < 8)
                            begin
                                if(record_num_bytes_reg > 0)
                                    begin
                                        write_data_0    <= record_bytes_reg[MAX_BYTES*8-1:(MAX_BYTES-1)*8];
                                        write_data_1    <= record_bytes_reg[(MAX_BYTES-1)*8-1:(MAX_BYTES-2)*8];
                                        write_data_2    <= record_bytes_reg[(MAX_BYTES-2)*8-1:(MAX_BYTES-3)*8];
                                        write_data_3    <= record_bytes_reg[(MAX_BYTES-3)*8-1:(MAX_BYTES-4)*8];
                                    end
                                 else
                                    begin
                                        write_data_0    <= 8'hFF;
                                        write_data_1    <= 8'hFF;
                                        write_data_2    <= 8'hFF;
                                        write_data_3    <= 8'hFF;
                                    end
                            end
                        else
                            begin
                                write_data_0            <= buffer_data[31:24];
                                write_data_1            <= buffer_data[23:16];
                                write_data_2            <= buffer_data[15: 8];
                                write_data_3            <= buffer_data[ 7: 0];
                            end
                            
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SD_CMD24_CRC : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD24_RESP;
                                transaction_start       <= 1'b0;
                                
                                data_block_number       <= data_block_number + 1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_CRC;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SD_CMD24_RESP : 
					begin
					    if(transaction_done)
					        begin
					            if((read_data_reg_0[4] == 1'b0) && (read_data_reg_0[0] == 1'b1))
					                begin
                                        transaction_state		<= TRANSACTION_SD_WAIT_FOR_WRITE_READY;
                                        
                                        if(read_data_reg_0[3:1] != 3'b010)
                                            sd_write_error      <= 1'b1;
                                        
                                        sd_write_address        <= sd_write_address + 1;
                                        
                                        last_transaction        <= 1'b1;  //<------
                                    end
                                 transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_RESP;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_SD_WAIT_FOR_WRITE_READY : 
					begin
					    if(transaction_done)
					        begin
					            if(read_data_reg_0 == 8'hFF)
					                begin
					                    transaction_state		<= TRANSACTION_SD_WRITE_CONT;
                                            
                                        if((!sd_write_ready) && (ms_timer >= 16'd050))
                                            begin
                                                sd_write_ready  <= 1'b1;
                                                ms_timer_reset  <= 1'b1;
                                            end
                                        
                                        sd_busy                 <= 1'b0;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_WAIT_FOR_WRITE_READY;
                                        sd_busy                 <= 1'b1;
                                        
                                        //if(sd_spi_device == SPI_DEVICE_SD_1)
                                        //    sd_spi_device <= SPI_DEVICE_SD_2;
                                        //else
                                            sd_spi_device <= SPI_DEVICE_SD_1;
                                    end
                                transaction_start       <= 1'b0;
                                continue_transaction    <= 1'b0;
                                last_transaction        <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_WAIT_FOR_WRITE_READY;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= sd_spi_device;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////					
			    TRANSACTION_ADC_RST_EN : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_RST;
                                transaction_start       <= 1'b0;
                                adc_init                <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_RST_EN;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h11;   // General User Configuration 1 Register
                        //write_data_1            <= 8'h27; // Prototype board option
                        //write_data_1            <= 8'h13;   // Powerdown VCM, output reference, powerdown internal oscillator, 1 write reset 
                        //write_data_1            <= 8'h17;   // Powerdown VCM, output reference, power internal oscillator, 1 write reset
                        //write_data_1            <= 8'h37;   // Power VCM, output reference, power internal oscillator, 1 write reset
                        //write_data_1            <= 8'h07;   // Powerdown VCM, do not output reference, power internal oscillator, 1 write reset 
                        write_data_1            <= 8'h67;   // High resolution mode, power VCM, do not output reference, power internal oscillator, 1 write reset 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
                        
                        adc_sample_start        <= 1'b0;
					end
				TRANSACTION_ADC_RST : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_WAIT;
                                transaction_start       <= 1'b0;
                                ms_timer_reset          <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_RST;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h8;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_WAIT : 
					begin
                        if(ms_timer == 16'd0004)    // Wait for ADC to complete reset before further communication
                            begin
                                transaction_state   <= TRANSACTION_ADC_CONF;  
                                ms_timer_reset      <= 1'b1;
                            end
                        else
                            begin
                                transaction_state    <= TRANSACTION_ADC_WAIT;
                            end  
                        
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_start       <= 1'b0;
                        transaction_write_bytes <= 4'h0;
                        transaction_read_bytes  <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        buffer_read_enable      <= 1'b0;
					end
			    TRANSACTION_ADC_CONF : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_REF;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_CONF;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h11;   // General User Configuration 1 Register
                        //write_data_1            <= 8'h17;   // Powerdown VCM, output reference, powerdown internal oscillator, 1 write reset 
                        //write_data_1            <= 8'h16;   // Powerdown VCM, output reference, power internal oscillator, 2 write reset
                        //write_data_1            <= 8'h06;   // Power VCM, do not output reference, power internal oscillator, 2 write reset
                        //write_data_1            <= 8'h66;   // High resolution, power VCM, do not output reference, power internal oscillator, 2 write reset
                        write_data_1            <= 8'h76;   // High resolution, power VCM, output reference, power internal oscillator, 2 write reset
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_REF : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_FORMAT;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_REF;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h15;   // Reference Mux Config Register
                        write_data_1            <= 8'h40;   // Internal reference
                        //write_data_1            <= 8'h00;   // External reference
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_FORMAT : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_DECIMATION;
					            //transaction_state   <= TRANSACTION_ADC_ERROR_CHECK_1;   // skip sync
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_FORMAT;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h14;   // DOUT Format Register
                        write_data_1            <= 8'hE0;   // One DOUT line, CRC header
                        //write_data_1            <= 8'h60;   // Two DOUT lines, CRC header
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
			    TRANSACTION_ADC_DECIMATION : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_DECIMATION_SET;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_DECIMATION;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h61;   // Decimation LSB Register
                        write_data_1            <= 8'h80;   // 2048 / 16   128 = 0x10 - for 16 kHz
                        //write_data_1            <= 8'h40;   // 2048 / 32   64 = 0x40 - for 32 kHz
                        //write_data_1            <= 8'h20;   // 2048 / 64   32 = 0x20 - for 64 kHz
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_DECIMATION_SET : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_WAIT_2;
                                transaction_start       <= 1'b0;
                                ms_timer_reset          <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_DECIMATION_SET;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h64;   // SRC Update Register
                        write_data_1            <= 8'h01;   // Trigger update
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_WAIT_2 : 
					begin
                        if(ms_timer == 16'd0004)    // Wait for ADC to complete decimation rate change
                            begin
                                transaction_state   <= TRANSACTION_ADC_DECIMATION_CLEAR;  
                                ms_timer_reset      <= 1'b1;
                            end
                        else
                            begin
                                transaction_state    <= TRANSACTION_ADC_WAIT_2;
                            end  
                        
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_start       <= 1'b0;
                        transaction_write_bytes <= 4'h0;
                        transaction_read_bytes  <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        buffer_read_enable      <= 1'b0;
					end
				TRANSACTION_ADC_DECIMATION_CLEAR : 
					begin
					    if(transaction_done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_CHANNEL_GAIN;
                                //transaction_state		<= TRANSACTION_ADC_SYNC_1;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_DECIMATION_CLEAR;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h64;   // SRC Update Register
                        write_data_1            <= 8'h00;   // Clear update
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_CHANNEL_GAIN : 
					begin
					    if(transaction_done)
					        begin
					            if(adc_channel_select == 8'h07)
					                begin
                                        transaction_state		<= TRANSACTION_ADC_SYNC_1;
                                        adc_channel_select      <= 8'h00;
                                    end
                               else
					                begin
                                        transaction_state		<= TRANSACTION_ADC_CHANNEL_GAIN;
                                        adc_channel_select      <= adc_channel_select + 1;
                                    end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_CHANNEL_GAIN;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= adc_channel_select;   // Channel x Config Register
                        //write_data_1            <= 8'h00;   // Set gain to 1
                        write_data_1            <= 8'hC0;   // Set gain to 8
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
					
			    TRANSACTION_ADC_SYNC_1 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_SYNC_2;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_SYNC_1;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h12;   // General User Configuration 2 Register
                        write_data_1            <= 8'h09;   // Strong SDO drive strength, assert sync
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_SYNC_2 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_SYNC_WAIT;
                                transaction_start       <= 1'b0;
                                ms_timer_reset          <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_SYNC_2;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h12;   // General User Configuration 2 Register
                        write_data_1            <= 8'h08;   // Deassert sync
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_SYNC_WAIT : 
					begin
                        if(ms_timer == 16'd0004)    // Wait for ADC to complete reset before further communication
                            begin
                                transaction_state   <= TRANSACTION_ADC_ERROR_CHECK_1;  
                                ms_timer_reset      <= 1'b1;
                            end
                        else
                            begin
                                transaction_state    <= TRANSACTION_SYNC_WAIT;
                            end  
                        
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_start       <= 1'b0;
                        transaction_write_bytes <= 4'h0;
                        transaction_read_bytes  <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        buffer_read_enable      <= 1'b0;
					end
				TRANSACTION_ADC_ERROR_CHECK_1 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_2;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_1;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hD9;   // 
                        write_data_1            <= 8'hFF;   // 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_ADC_ERROR_CHECK_2 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_3;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_2;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hDB;   // 
                        write_data_1            <= 8'hFF;   // 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
			    TRANSACTION_ADC_ERROR_CHECK_3 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_4;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_3;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hDD;   // 
                        write_data_1            <= 8'hFF;   // 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_ADC_ERROR_CHECK_4 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_5;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_4;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hDE;   // 
                        write_data_1            <= 8'hFF;   // 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_ADC_ERROR_CHECK_5 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_6;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_5;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hDF;   // 
                        write_data_1            <= 8'hFF;   // 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_ADC_ERROR_CHECK_6 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_7;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_6;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hCD;
                        write_data_1            <= 8'hFF; 
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_ADC_ERROR_CHECK_7 : 
					begin
					    if(transaction_done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_EN;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_ERROR_CHECK_7;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hD4;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
				TRANSACTION_ADC_EN : 
					begin
					    if(transaction_done)
					        begin 
                                transaction_state       <= TRANSACTION_MAIN;
                                adc_init                <= 1'b1;
                                
                                adc_sample_start        <= 1'b1;
                                transaction_start       <= 1'b0;
                                ms_timer_reset          <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_EN;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_ADC;
                        spi_clock_divider       <= SPI_ADC_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h13;
                        write_data_1            <= 8'h80; // Enable ADC sample via ADC serial interface
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_DONE : 
					begin
                        transaction_state		<= TRANSACTION_DONE;
                        transaction_start       <= 1'b0;
                        spi_device              <= SPI_DEVICE_NONE;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h0;
                        transaction_read_bytes  <= 4'h0;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        continue_transaction    <= 1'b0;
                        buffer_read_enable      <= 1'b0;
					end
				default : 
					begin
						transaction_state		<= TRANSACTION_MAIN;
						ms_timer_reset          <= 1'b1;
					end
			endcase
					
		end
	end




// SPI controller state machine - steps through the necessary WISHBONE communication needed for a single SPI transaction

parameter IDLE           	    = 4'h0;
parameter WAIT_FOR_START 	    = 4'h1;
parameter WRITE_SPI_CLK_PRESCALE= 4'h2;
parameter WRITE_SPI_CHIP_SEL    = 4'h3;
parameter WRITE_SPI_MST_EN	    = 4'h4;
parameter READ_TRDY			    = 4'h5;
parameter WRITE_TXDR		    = 4'h6;
parameter READ_RRDY             = 4'h7;
parameter READ_RXDR             = 4'h8;
parameter WRITE_SPI_MST_DIS     = 4'h9;
parameter READ_TIP              = 4'hA;
parameter DONE  			    = 4'hB;

assign wb_stb = wb_cyc;

reg	[3:0]	state;
reg	[3:0]	next_state;
reg [3:0]   write_byte;
reg [3:0]   read_byte;

reg [7:0]   current_divider;
reg [5:0]   current_device;

reg         start;
reg         transaction_start_reg;
reg         transaction_in_progress;

reg         continue_transaction_reg;
reg         last_transaction_reg;
reg [3:0]   transaction_write_bytes_reg;
reg [3:0]   transaction_read_bytes_reg;
reg [7:0]   write_data;
reg [7:0]   write_data_reg_0;
reg [7:0]   write_data_reg_1;
reg [7:0]   write_data_reg_2;
reg [7:0]   write_data_reg_3;
reg [7:0]   write_data_reg_4;
reg [7:0]   write_data_reg_5;

always@(posedge clock_126 or posedge reset)
	begin
	if(reset)
		begin
		    start                       <= 1'b0;
		    transaction_start_reg       <= 1'b0;
			wb_cyc		                <= 1'b0;
			wb_we		                <= 1'b0;
			wb_adr		                <= 8'h00;
			wb_dat_i	                <= 8'h00;
			state		                <= IDLE;
			next_state                  <= WAIT_FOR_START;
			done                        <= 1'b0;
			write_byte                  <= 4'h0;
			transaction_write_bytes_reg <= 0;
			transaction_read_bytes_reg  <= 0;
			read_byte                   <= 4'h0;
			read_data_0                 <= 8'h00;
			read_data_1                 <= 8'h00;
			read_data_2                 <= 8'h00;
			read_data_3                 <= 8'h00;
			read_data_4                 <= 8'h00;
			read_data_5                 <= 8'h00;
			write_data                  <= 8'h00;
			write_data_reg_0            <= 8'h00;
			write_data_reg_1            <= 8'h00;
			write_data_reg_2            <= 8'h00;
			write_data_reg_3            <= 8'h00;
			write_data_reg_4            <= 8'h00;
			write_data_reg_5            <= 8'h00;
			continue_transaction_reg    <= 0;
			last_transaction_reg        <= 0;
			transaction_in_progress     <= 1'b0;
			current_divider             <= 8'h00;
			current_device              <= 6'h00;
		end
	else
		begin
		    
		    transaction_start_reg       <= transaction_start_delay;
		    continue_transaction_reg    <= continue_transaction;
			last_transaction_reg        <= last_transaction;
			write_data_reg_0            <= write_data_0;
	        write_data_reg_1            <= write_data_1;
	        write_data_reg_2            <= write_data_2;
	        write_data_reg_3            <= write_data_3;
	        write_data_reg_4            <= write_data_4;
	        write_data_reg_5            <= write_data_5;
	        transaction_write_bytes_reg <= transaction_write_bytes;
	        transaction_read_bytes_reg  <= transaction_read_bytes;
		    
		    
		    if((transaction_start_reg == 1'b0) && (transaction_start_delay == 1'b1))
		        begin
		            start                       <= 1'b1;
		            read_data_0                 <= 8'h00;
		            read_data_1                 <= 8'h00;
		            read_data_2                 <= 8'h00;
		            read_data_3                 <= 8'h00;
		            read_data_4                 <= 8'h00;
		            read_data_5                 <= 8'h00;
		            
			        
			        current_divider             <= spi_clock_divider;
					current_device              <= ~spi_device;
		        end
		    else if(transaction_start_delay == 1'b0)
		        start   <= 1'b0;
		    
			case(state)
				IDLE : 
					begin
						if(~wb_ack)
							begin
					            state		<= next_state;
					            if(next_state == DONE)
					                done    <= 1'b1;
							end
						else
						    state		<= IDLE;  
						wb_cyc		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
				WAIT_FOR_START :
				    begin
						if(start)
					        begin
					            state		<= IDLE; 
					        end
					    else
					        begin
					            state		<= WAIT_FOR_START; 
					            if(continue_transaction_reg && transaction_in_progress)
					                begin
					                    next_state      <= READ_TRDY;
					                end
					            else //if(current_divider != spi_clock_divider)
					                begin
					                    next_state      <= WRITE_SPI_CLK_PRESCALE;
					                end
					            /*else if(current_device != spi_device)
					                begin
					                    next_state      <= WRITE_SPI_CHIP_SEL;
					                    current_device  <= spi_device;
					                end
					            else
					                begin
					                    next_state      <= WRITE_SPI_MST_EN;
					                end*/
					            
					        end   
						wb_cyc		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
				WRITE_SPI_CLK_PRESCALE : 
					begin
						if(wb_ack)
							state		<= IDLE;
						else
							state		<= WRITE_SPI_CLK_PRESCALE;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h57;	        // Clock prescale register
						wb_dat_i	<= current_divider;	// Prescale value
						next_state	<= WRITE_SPI_CHIP_SEL;
						write_byte  <= 0;
			            read_byte   <= 0;
			            transaction_in_progress <= 0;
					end
				WRITE_SPI_CHIP_SEL : 
					begin
						if(wb_ack)
							state		<= IDLE;
						else
							state		<= WRITE_SPI_CHIP_SEL;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h58;	                        // SPI master chip select
						wb_dat_i	<= {2'b11,current_device[5:0]};	// SPI chip select
						next_state	<= WRITE_SPI_MST_EN;
						write_byte  <= 0;
			            read_byte   <= 0;
					end
				WRITE_SPI_MST_EN : 
					begin
						if(wb_ack)
							state		<= IDLE;
						else
							state		<= WRITE_SPI_MST_EN;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h56;	// Control reg 2
						wb_dat_i	<= 8'hC0;	// SPI master enable
						next_state	<= READ_TRDY;
						write_byte  <= 0;
			            read_byte   <= 0;
					end
				
				READ_TRDY : 
					begin
						if(wb_ack)
							begin
							    state		<= IDLE;
								if(wb_dat_o[4]) // Proceed if TRDY flag is set, otherwise poll SPI status register for TRDY==1
									next_state	<= WRITE_TXDR;
								else
									next_state	<= READ_TRDY;
							end
						else
							state		<= READ_TRDY;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b0;
						wb_adr		<= 8'h5A;	// SPI status
						wb_dat_i	<= 8'h00;
						
						if((write_byte == transaction_write_bytes_reg))
						    begin
						        write_data	<= 8'hFF;
						    end
						else
						    begin
						        if(write_byte == 0)
						            write_data	<= write_data_reg_0;	// TX data
						        else if(write_byte == 1)
						            write_data	<= write_data_reg_1;	// TX data
						        else if(write_byte == 2)
						            write_data	<= write_data_reg_2;	// TX data
						        else if(write_byte == 3)
						            write_data	<= write_data_reg_3;	// TX data
						        else if(write_byte == 4)
						            write_data	<= write_data_reg_4;	// TX data
						        else
						            write_data	<= write_data_reg_5;	// TX data
						    end
					end
				WRITE_TXDR : 
					begin
						if(wb_ack)
						    begin
							    state		<= IDLE;
							    if((write_byte == transaction_write_bytes_reg))
						            read_byte  <= read_byte + 1;
						        else
						            write_byte  <= write_byte + 1;
							end
						else
							state		<= WRITE_TXDR;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h59;	// SPI TX data reg
						wb_dat_i	<= write_data;
						    
						next_state	<= READ_RRDY;
					end
				READ_RRDY : 
					begin
						if(wb_ack)
							begin
							    state		<= IDLE;
								if(wb_dat_o[3]) // Proceed if RRDY flag is set, otherwise poll SPI status register for RRDY==1
									next_state	<= READ_RXDR;
								else
									next_state	<= READ_RRDY;
							end
						else
							state		<= READ_RRDY;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b0;
						wb_adr		<= 8'h5A;	// SPI status
						wb_dat_i	<= 8'h00;
					end
				READ_RXDR : 
					begin
						if(wb_ack)
							begin
							    state		<= IDLE;
							    if(read_byte == 1)
							        read_data_0 <= wb_dat_o;
							    else if(read_byte == 2)
							        read_data_1 <= wb_dat_o;
							    else if(read_byte == 3)
							        read_data_2 <= wb_dat_o;
							    else if(read_byte == 4)
							        read_data_3 <= wb_dat_o;
							    else if(read_byte == 5)
							        read_data_4 <= wb_dat_o;
							    else
							        read_data_5 <= wb_dat_o;

							    if((write_byte == transaction_write_bytes_reg) && (read_byte >= transaction_read_bytes_reg))
							        begin
							            if((continue_transaction_reg == 1'b1) && (last_transaction_reg == 1'b0))
							                begin
							                    next_state	<= DONE;
							                    transaction_in_progress <= 1'b1;
							                end
							            else
								            next_state	<= WRITE_SPI_MST_DIS;
								    end
								else
								    begin
								        next_state	<= READ_TRDY;
								    end
							end
						else
							state		<= READ_RXDR;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b0;
						wb_adr		<= 8'h5B;	// SPI data receive
						wb_dat_i	<= 8'h00;
					end
				WRITE_SPI_MST_DIS : 
					begin
						if(wb_ack)
							state		<= IDLE;
						else
							state		<= WRITE_SPI_MST_DIS;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h56;	// Control reg 2
						wb_dat_i	<= 8'h40;	// SPI master disable
						next_state	<= READ_TIP;
					end
				READ_TIP : 
					begin
						if(wb_ack)
							begin
							    state		<= IDLE;
								if(~wb_dat_o[7]) // Proceed if TIP flag is not set, otherwise poll SPI status register for TIP==0
									next_state	<= DONE;
								else
									next_state	<= READ_TIP;
							end
						else
							state		<= READ_TIP;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b0;
						wb_adr		<= 8'h5A;	// SPI status
						wb_dat_i	<= 8'h00;
					end
				DONE : 
					begin
					    if(!start)
					        begin
						        state		<= IDLE;
						        done        <= 1'b0;
						    end
						else
						    state       <= DONE;
						next_state	<= WAIT_FOR_START;
						wb_cyc		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
						//done        <= 1'b0;
						write_byte  <= 4'h0;
			            read_byte   <= 4'h0;
					end
				default : 
					begin
						state		<= IDLE;
						next_state	<= WAIT_FOR_START;
						wb_cyc		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
			endcase
					
		end
	end
	
	



endmodule
