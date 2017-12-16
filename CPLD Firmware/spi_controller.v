module spi_controller ( clock, reset, wb_cyc, wb_stb, wb_we, wb_adr, wb_dat_i, wb_dat_o, wb_ack, 
                        adc_sample_start, buffer_read_enable, buffer_data, buffer_half_filled,
                        adc_init, sd_init, sd_write_error);

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
input               buffer_half_filled;

output reg          adc_init;
output reg          sd_init;
output reg          sd_write_error;

// Transaction state machine = advances from one SPI transaction to the next, as the SPI controller completes

parameter TRANSACTION_START		                = 5'h00;
parameter TRANSACTION_ADC_RST_EN                = 5'h01;
parameter TRANSACTION_ADC_RST	                = 5'h02;
parameter TRANSACTION_ADC_WAIT                  = 5'h03;
parameter TRANSACTION_ADC_FORMAT                = 5'h04;
parameter TRANSACTION_ADC_EN	                = 5'h05;
parameter TRANSACTION_SD_CLK_INIT               = 5'h06;
parameter TRANSACTION_SD_CMD0                   = 5'h07;
parameter TRANSACTION_SD_CMD8                   = 5'h08;
parameter TRANSACTION_SD_CMD_CLK                = 5'h09;
parameter TRANSACTION_SD_CMD55                  = 5'h0A;
parameter TRANSACTION_SD_ACMD41                 = 5'h0B;
parameter TRANSACTION_SD_CMD_CLK_2              = 5'h0C;
parameter TRANSACTION_SD_CMD1                   = 5'h0D;
parameter TRANSACTION_SD_CMD58                  = 5'h0E;
parameter TRANSACTION_SD_CMD_CLK_3              = 5'h0F;
parameter TRANSACTION_SD_CMD24                  = 5'h10;
parameter TRANSACTION_WAIT_FOR_BUFFER_FULL      = 5'h11;
parameter TRANSACTION_SD_CMD24_TOK              = 5'h12;
parameter TRANSACTION_SD_CMD24_DATA             = 5'h13;
parameter TRANSACTION_SD_CMD24_CRC              = 5'h14;
parameter TRANSACTION_SD_CMD24_RESP             = 5'h15;
parameter TRANSACTION_SD_WAIT_FOR_WRITE_READY   = 5'h16;
parameter TRANSACTION_DONE		                = 5'h17;

parameter TRANSACTION_SD_INIT       = TRANSACTION_SD_CLK_INIT;
parameter TRANSACTION_SD_WRITE      = TRANSACTION_SD_CMD_CLK_3;
parameter TRANSACTION_SD_WRITE_CONT = TRANSACTION_WAIT_FOR_BUFFER_FULL;
parameter TRANSACTION_ADC_INIT      = TRANSACTION_ADC_RST_EN;

parameter SPI_DEVICE_NONE           = 3'b000;
parameter SPI_DEVICE_1              = 3'b001;
parameter SPI_DEVICE_2              = 3'b010;
parameter SPI_DEVICE_3              = 3'b100;

parameter SPI_SD_SLOW               = 8'd49; // 84 MHz / (49 + 1) =  1.68 MHz
parameter SPI_SD_FAST               = 8'd03; // 84 MHz / ( 3 + 1) = 21.00 MHz

reg         done;
	
reg	[4:0]	transaction_state;
reg         transaction_start;
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

reg [2:0]   spi_device;
reg [7:0]   spi_clock_divider;

reg         adc_drdy_reg;

reg [15:0]  command_iteration;

reg         continue_transaction;
reg         last_transaction;

reg [31:0]  sd_write_address;


always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			transaction_state		<= TRANSACTION_START;
			transaction_start       <= 1'b0;
            transaction_write_bytes <= 4'h0;
            transaction_read_bytes  <= 4'h0;
            write_data_0            <= 8'h00;
            write_data_1            <= 8'h00;
            spi_device              <= SPI_DEVICE_NONE;
            spi_clock_divider       <= SPI_SD_SLOW;
            
            adc_drdy_reg            <= 1'b0;
            adc_sample_start        <= 1'b0;
            
            command_iteration       <= 15'h0000;
            
            continue_transaction    <= 1'b0;
            last_transaction        <= 1'b0;
            
            buffer_read_enable      <= 1'b0;
            
            sd_write_address        <= 32'h0000;
            
            adc_init                <= 1'b0;
            sd_init                 <= 1'b0;
            
            sd_write_error          <= 1'b0;
		end
	else
		begin
			case(transaction_state)
				TRANSACTION_START : 
					begin
                        //transaction_state		<= TRANSACTION_ADC_RST_EN;
                        //transaction_state		<= TRANSACTION_SD_CLK_INIT;
                        //transaction_state		<= TRANSACTION_SD_CMD_CLK_3;
                        
                        transaction_state       <= TRANSACTION_SD_INIT;
                        
                        transaction_start       <= 1'b0;
                        transaction_write_bytes <= 4'h0;
                        transaction_read_bytes  <= 4'h0;
                        write_data_0            <= 8'h00;
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'h00;
                        command_iteration       <= 16'h0000;
                        continue_transaction    <= 1'b0;
                        last_transaction        <= 1'b0;
                        buffer_read_enable      <= 1'b0;
					end
				TRANSACTION_SD_CLK_INIT : 
					begin
					    if(done)
					        begin
                                transaction_start       <= 1'b0;
                                sd_init                 <= 1'b0;
                                
                                if(command_iteration == 16'h3FFF)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD0;
                                        command_iteration       <= 16'h0;
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
                        spi_device              <= SPI_DEVICE_3;
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
					    if(done)
					        begin
					            if(read_data_1 == 8'h01)
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
                        spi_device              <= SPI_DEVICE_2;
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
					    if(done)
					        begin
					            if(read_data_1 == 8'h01)
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
                        spi_device              <= SPI_DEVICE_2;
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
					    if(done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD55;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD_CLK;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_3;
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
					    if(done)
					        begin
					            //if(read_data_1 == 8'h01)
                                    transaction_state		<= TRANSACTION_SD_ACMD41;
                                //else
                                //    transaction_state		<= TRANSACTION_SD_CMD55;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD55;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
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
					    if(done)
					        begin
					            if(read_data_1 == 8'h00)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD58;
                                        command_iteration       <= 16'h0;
                                    end
                                else if(command_iteration == 16'h00FF)
					                begin
                                        transaction_state		<= TRANSACTION_DONE;
                                        command_iteration       <= 16'h0;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CMD_CLK;
                                        command_iteration       <= command_iteration + 1;
                                    end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_ACMD41;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
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
				TRANSACTION_SD_CMD_CLK_2 : 
					begin
					    if(done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD1;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD_CLK_2;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_3;
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
				TRANSACTION_SD_CMD1 : 
					begin
					    if(done)
					        begin
					            if(command_iteration == 16'hFFFF || read_data_1 == 8'h00)
					                begin
                                        transaction_state		<= TRANSACTION_DONE;
                                        //command_iteration       <= 16'h0;
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
                                transaction_state		<= TRANSACTION_SD_CMD1;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
                        spi_clock_divider       <= SPI_SD_SLOW;
                        transaction_write_bytes <= 4'h6;
                        write_data_0            <= 8'h41; // {2'b01, 6'b<command index>}
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'hF9;
                        transaction_read_bytes  <= 4'h6;
					end
                TRANSACTION_SD_CMD58 : 
					begin
					    if(done)
					        begin
					            //if(command_iteration == 16'hFFFF || read_data_1 == 8'h00)
					             //   begin
                                        //transaction_state		<= TRANSACTION_SD_CMD_CLK_3;   //<-------
                                        
                                        transaction_state       <= TRANSACTION_ADC_INIT;
                                        sd_init                 <= 1'b1;
                                        sd_write_error          <= 1'b0;
                                        //command_iteration       <= 16'h0;
                                //    end
                                //else
                                //    begin
                                //        transaction_state		<= TRANSACTION_SD_CMD_CLK;
                                //        command_iteration       <= command_iteration + 1;
                                 //   end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD58;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
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
				/////////////////////////
				TRANSACTION_SD_CMD_CLK_3 : 
					begin
					    if(done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD24;
                                //transaction_state		<= TRANSACTION_SD_CMD17;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD_CLK_3;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_3;
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
					    if(done)
					        begin
					            transaction_state		<= TRANSACTION_WAIT_FOR_BUFFER_FULL;
                                command_iteration       <= 16'h0000;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
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
					    if(buffer_half_filled)
					        transaction_state		<= TRANSACTION_SD_CMD24_TOK;
                        else
                            transaction_state		<= TRANSACTION_WAIT_FOR_BUFFER_FULL;
                        spi_device              <= SPI_DEVICE_3;
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
                        last_transaction        <= 1'b0;
					end	
				TRANSACTION_SD_CMD24_TOK : 
					begin
					    if(done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD24_DATA;
                                command_iteration       <= 16'h0000;
                                transaction_start       <= 1'b0;
                                buffer_read_enable      <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_TOK;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'hFC;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
                        continue_transaction    <= 1'b1;
                        last_transaction        <= 1'b0;
					end
				TRANSACTION_SD_CMD24_DATA : 
					begin
					    if(done)
					        begin
					            if(command_iteration == 16'h007F) // 127 + 1 iterations (128 * 4 bytes = 512 bytes)
					                begin
                                        transaction_state		<= TRANSACTION_SD_CMD24_CRC;
                                        command_iteration       <= 16'h0000;
                                        buffer_read_enable      <= 1'b0;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_CMD24_DATA;
                                        command_iteration       <= command_iteration + 1;
                                        buffer_read_enable      <= 1'b1;                                      
                                    end
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_DATA;
                                transaction_start       <= 1'b1;
                                buffer_read_enable      <= 1'b0;
                            end
                        spi_device              <= SPI_DEVICE_2;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h4;
                        //write_data_0            <= (command_iteration << 2);        // iteration count * 4
                        //write_data_1            <= (command_iteration << 2) + 1;    // iteration count * 4 + 1
                        //write_data_2            <= (command_iteration << 2) + 2;    // iteration count * 4 + 2
                        //write_data_3            <= (command_iteration << 2) + 3;    // iteration count * 4 + 3
                        
                        write_data_0            <= buffer_data[31:24];
                        write_data_1            <= buffer_data[23:16];
                        write_data_2            <= buffer_data[15: 8];
                        write_data_3            <= buffer_data[ 7: 0];
                        
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
                        continue_transaction    <= 1'b1;
                        last_transaction        <= 1'b0;
					end
				TRANSACTION_SD_CMD24_CRC : 
					begin
					    if(done)
					        begin
                                transaction_state		<= TRANSACTION_SD_CMD24_RESP;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_CRC;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'hFF;
                        write_data_1            <= 8'hFF;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
                        continue_transaction    <= 1'b1;
                        last_transaction        <= 1'b0;
					end
				TRANSACTION_SD_CMD24_RESP : 
					begin
					    if(done)
					        begin
					            if((read_data_0[4] == 1'b0) && (read_data_0[0] == 1'b1))
					                begin
                                        //transaction_state		<= TRANSACTION_DONE;
                                        transaction_state		<= TRANSACTION_SD_WAIT_FOR_WRITE_READY;
                                        transaction_start       <= 1'b0;
                                        
                                        if(read_data_0[3:1] != 3'b010)
                                            sd_write_error      <= 1'b1;
                                        
                                        sd_write_address        <= sd_write_address + 1;
                                        
                                        last_transaction        <= 1'b1;
                                        continue_transaction    <= 1'b0;
                                    end
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_CMD24_RESP;
                                transaction_start       <= 1'b1;
                                continue_transaction    <= 1'b1;
                                last_transaction        <= 1'b0;
                            end
                        spi_device              <= SPI_DEVICE_2;
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
					    if(done)
					        begin
					            if(read_data_0 == 8'hFF)
					                begin
                                        transaction_state		<= TRANSACTION_SD_WRITE_CONT;
                                    end
                                else
                                    begin
                                        transaction_state		<= TRANSACTION_SD_WAIT_FOR_WRITE_READY;
                                    end
                                transaction_start       <= 1'b0;
                                last_transaction        <= 1'b1;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_SD_WAIT_FOR_WRITE_READY;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_2;
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
					    if(done)
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
                        spi_device              <= SPI_DEVICE_1;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h11;
                        write_data_1            <= 8'h27;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
                        
                        adc_sample_start        <= 1'b0;
					end
				TRANSACTION_ADC_RST : 
					begin
					    if(done)
					        begin
                                transaction_state		<= TRANSACTION_ADC_WAIT;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_RST;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_1;
                        spi_clock_divider       <= SPI_SD_FAST;
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
					    if(done)
					        begin
					            if(read_data_0 == 8'h24)
                                    transaction_state		<= TRANSACTION_ADC_FORMAT;
                                else
                                    transaction_state		<= TRANSACTION_ADC_WAIT;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_WAIT;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_1;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h1;
                        write_data_0            <= 8'h91;
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h1;
					end
			    TRANSACTION_ADC_FORMAT : 
					begin
					    if(done)
					        begin
					            transaction_state		<= TRANSACTION_ADC_EN;
                                transaction_start       <= 1'b0;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_FORMAT;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_1;
                        spi_clock_divider       <= SPI_SD_FAST;
                        transaction_write_bytes <= 4'h2;
                        write_data_0            <= 8'h14;
                        write_data_1            <= 8'hE0;
                        write_data_2            <= 8'hFF;
                        write_data_3            <= 8'hFF;
                        write_data_4            <= 8'hFF;
                        write_data_5            <= 8'hFF;
                        transaction_read_bytes  <= 4'h0;
					end
				TRANSACTION_ADC_EN : 
					begin
					    if(done)
					        begin 
                                transaction_state       <= TRANSACTION_SD_WRITE;
                                adc_init                <= 1'b1;
                                
                                adc_sample_start        <= 1'b1;
                                transaction_start       <= 1'b0;
                                command_iteration       <= 16'h0000;
                            end
                        else
                            begin
                                transaction_state		<= TRANSACTION_ADC_EN;
                                transaction_start       <= 1'b1;
                            end
                        spi_device              <= SPI_DEVICE_1;
                        spi_clock_divider       <= SPI_SD_FAST;
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
                        write_data_0            <= 8'h00;
                        write_data_1            <= 8'h00;
                        write_data_2            <= 8'h00;
                        write_data_3            <= 8'h00;
                        write_data_4            <= 8'h00;
                        write_data_5            <= 8'h00;
                        continue_transaction    <= 1'b0;
                        buffer_read_enable      <= 1'b0;
					end
				default : 
					begin
						transaction_state		<= TRANSACTION_START;
					end
			endcase
					
		end
	end




// SPI controller state machine - steps through the necessary WISHBONE communication needed for a single SPI transaction

parameter IDLE           	    = 4'h0;
parameter WRITE_SPI_CLK_PRESCALE= 4'h1;
parameter WRITE_SPI_CHIP_SEL    = 4'h2;
parameter WRITE_SPI_MST_EN	    = 4'h3;
parameter READ_TRDY			    = 4'h4;
parameter WRITE_TXDR		    = 4'h5;
parameter READ_RRDY             = 4'h6;
parameter READ_RXDR             = 4'h7;
parameter WRITE_SPI_MST_DIS     = 4'h8;
parameter READ_TIP              = 4'h9;
parameter DONE  			    = 4'hA;

assign wb_stb = wb_cyc;

reg	[3:0]	state;
reg	[3:0]	next_state;
reg [3:0]   write_byte;
reg [3:0]   read_byte;

reg         transaction_in_progress;

always@(posedge clock or posedge reset)
	begin
	if(reset)
		begin
			wb_cyc		<= 1'b0;
			wb_we		<= 1'b0;
			wb_adr		<= 8'h00;
			wb_dat_i	<= 8'h00;
			state		<= 4'h0;
			next_state  <= 4'h0;
			done        <= 1'b0;
			write_byte  <= 4'h0;
			read_byte   <= 4'h0;
			read_data_0 <= 8'h00;
			read_data_1 <= 8'h00;
			read_data_2 <= 8'h00;
			read_data_3 <= 8'h00;
			read_data_4 <= 8'h00;
			read_data_5 <= 8'h00;
			transaction_in_progress <= 1'b0;
		end
	else
		begin
			case(state)
				IDLE : 
					begin
						if(~wb_ack)
							begin
							    if(transaction_start)
							        begin
							            state		<= next_state;
							            if(next_state == DONE)
							                done    <= 1'b1;
							        end
							    else
							        begin
							            if(continue_transaction && transaction_in_progress)
							                next_state  <= READ_TRDY;
							            else
							                next_state  <= WRITE_SPI_CLK_PRESCALE;
							        end
							end
						else
						    state		<= IDLE;  
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
						wb_adr		<= 8'h57;	// Clock prescale register
						wb_dat_i	<= spi_clock_divider;	// Prescale value
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
						wb_adr		<= 8'h58;	// SPI master chip select
						wb_dat_i	<= {5'b11111,~spi_device[2:0]};	// SPI chip select
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
					end
				WRITE_TXDR : 
					begin
						if(wb_ack)
						    begin
							    state		<= IDLE;
							    if((write_byte == transaction_write_bytes))
						            read_byte  <= read_byte + 1;
						        else
						            write_byte  <= write_byte + 1;
							end
						else
							state		<= WRITE_TXDR;
						wb_cyc		<= 1'b1;
						wb_we		<= 1'b1;
						wb_adr		<= 8'h59;	// SPI TX data reg
						
						if((write_byte == transaction_write_bytes))
						    begin
						        wb_dat_i	<= 8'hFF;
						    end
						else
						    begin
						        if(write_byte == 0)
						            wb_dat_i	<= write_data_0;	// TX data
						        else if(write_byte == 1)
						            wb_dat_i	<= write_data_1;	// TX data
						        else if(write_byte == 2)
						            wb_dat_i	<= write_data_2;	// TX data
						        else if(write_byte == 3)
						            wb_dat_i	<= write_data_3;	// TX data
						        else if(write_byte == 4)
						            wb_dat_i	<= write_data_4;	// TX data
						        else
						            wb_dat_i	<= write_data_5;	// TX data
						    end
						    
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
							    else if(read_byte == 6)
							        read_data_5 <= wb_dat_o;
							    else
							        begin
							            read_data_0 <= 8'h00;
							            read_data_1 <= 8'h00;
							            read_data_2 <= 8'h00;
							            read_data_3 <= 8'h00;
							            read_data_4 <= 8'h00;
							            read_data_5 <= 8'h00;
							        end
							    if((write_byte == transaction_write_bytes) && (read_byte >= transaction_read_bytes))
							        begin
							            if(continue_transaction & ~last_transaction)
							                begin
							                    next_state	<= DONE;
							                    transaction_in_progress <= 1'b1;
							                end
							            else
								            next_state	<= WRITE_SPI_MST_DIS;
								    end
								else
								    begin
								        next_state	<= WRITE_TXDR;
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
						state		<= IDLE;
						next_state	<= IDLE;
						wb_cyc		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
						done        <= 1'b0;
						write_byte  <= 4'h0;
			            read_byte   <= 4'h0;
					end
				default : 
					begin
						state		<= IDLE;
						wb_cyc		<= 1'b0;
						wb_we		<= 1'b0;
						wb_adr		<= 8'b0;
						wb_dat_i	<= 8'b0;
					end
			endcase
					
		end
	end
	
	



endmodule
