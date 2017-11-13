#include <stdio.h>
#include <stdlib.h>


int main () {


    printf("HASP DAISI SD Card Extraction Tool\n");
    printf("Usage: sd_extract <data blocks to read>\n\n");

    FILE            *sd_card;
    unsigned char   data_block[512];
    int             read_status;
    unsigned int    adc_sample;
    int             adc_count;
    float           adc_voltage;
    int             i;
     
    sd_card = fopen("/dev/sdb", "rb"); /* rb for reading as binary */
    if(sd_card == NULL) {
        printf("Unable to open disk\n");    
        exit(EXIT_FAILURE);
    }
     
    read_status = fread(data_block, 512, 1, sd_card);
    if(read_status != 1) {
        printf("Unable to read block\n");    
        exit(EXIT_FAILURE);
    }
    
    //printf("%i\n",read_status);
    
    printf("\tRaw ADC Value\tADC Count\tADC Voltage\n\n");
    
    for(i=0;i<512;i=i+4) {
        adc_sample = (data_block[i] << 24) + (data_block[i+1] << 16) + (data_block[i+2] << 8) + data_block[i+3];
        adc_count = adc_sample & 0x00FFFFFF;
        if(adc_count >= 0x800000)
            adc_count = adc_count | 0xFF000000;
        adc_voltage = (2.5 * adc_count)/0x800000;
        printf("\t%08x\t%9i\t%12.9f\n",adc_sample,adc_count,adc_voltage);
    }
 
    fclose(sd_card);

    return 0;

}
