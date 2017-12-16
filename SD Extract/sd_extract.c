#include <stdio.h>
#include <stdlib.h>

#define MAX_CHANNELS    8

#define SAMPLE_RATE     16000.0

int main () {


    printf("HASP DAISI SD Card Extraction Tool\n");
    printf("Usage: sd_extract <data blocks to read>\n\n");

    FILE            *sd_card;
    FILE            *output_file;
    unsigned char   data_block[512];
    int             read_status;
    unsigned int    adc_sample[MAX_CHANNELS];
    int             adc_count[MAX_CHANNELS];
    float           adc_voltage[MAX_CHANNELS];
    int             i,block,channel;
    unsigned long   sample_index = 0;
    float           sample_time = 0.0;
     
    sd_card = fopen("/dev/sdb", "rb"); /* rb for reading as binary */
    if(sd_card == NULL) {
        printf("Unable to open sd card\n");    
        exit(EXIT_FAILURE);
    }
    
    output_file = fopen("adc_data.txt", "wb"); /* rb for reading as binary */
    if(output_file == NULL) {
        printf("Unable to open output file\n");    
        exit(EXIT_FAILURE);
    }
    
    printf("Time");
    fprintf(output_file,"Time");
     
    for(channel=0;channel<MAX_CHANNELS;channel++) 
    {
        printf("\tRaw ADC Value\tADC Count\tADC Voltage");
        fprintf(output_file,"\tRaw ADC Value\tADC Count\tADC Voltage");
    }
    
    printf("\n\n");
    fprintf(output_file,"\n\n");
    
    for(block=0;block<30000;block++)
    {
        read_status = fread(data_block, 512, 1, sd_card);
        if(read_status != 1) 
        {
            printf("Unable to read block\n");    
            exit(EXIT_FAILURE);
        }
        
        //printf("%i\n",read_status);
        
        for(i=0;i<512;i=i+4*MAX_CHANNELS) 
        {
        
            sample_time = sample_index * (1.0/SAMPLE_RATE);
            printf("%12.9f",sample_time);
            fprintf(output_file,"%12.9f",sample_time);
        
            for(channel=0;channel<MAX_CHANNELS;channel++) 
            {
                adc_sample[channel] =   (   data_block[channel*4+i+0] << 24) + 
                                        (   data_block[channel*4+i+1] << 16) + 
                                        (   data_block[channel*4+i+2] << 8 ) + 
                                            data_block[channel*4+i+3];
                adc_count[channel] = adc_sample[channel] & 0x00FFFFFF;
                if(adc_count[channel] >= 0x800000)
                    adc_count[channel] = adc_count[channel] | 0xFF000000;
                adc_voltage[channel] = (2.5 * adc_count[channel])/0x800000;
                
                printf("\t%08x\t%9i\t%12.9f",adc_sample[channel],adc_count[channel],adc_voltage[channel]);
                fprintf(output_file,"\t%08x\t%9i\t%12.9f",adc_sample[channel],adc_count[channel],adc_voltage[channel]);
            }
            
            
            printf("\n");
            fprintf(output_file,"\n");
            
            sample_index++;
        }
    }
 
    fclose(sd_card);
    fclose(output_file);

    return 0;

}
