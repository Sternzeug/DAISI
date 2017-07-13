[ActiveSupport MAP]
Device = LCMXO2-7000HE;
Package = TQFP144;
Performance = 4;
LUTS_avail = 6864;
LUTS_used = 45;
FF_avail = 6979;
FF_used = 43;
INPUT_LVCMOS33 = 3;
OUTPUT_LVCMOS33 = 16;
BIDI_LVCMOS33 = 3;
IO_avail = 115;
IO_used = 22;
EBR_avail = 26;
EBR_used = 0;
; Begin PLL Section
Instance_Name = pll_inst/PLLInst_0;
Type = EHXPLLJ;
CLKOP_Post_Divider_A_Input = DIVA;
CLKOS_Post_Divider_B_Input = DIVB;
CLKOS2_Post_Divider_C_Input = DIVC;
CLKOS3_Post_Divider_D_Input = DIVD;
Pre_Divider_A_Input = VCO_PHASE;
Pre_Divider_B_Input = DIVD;
Pre_Divider_C_Input = VCO_PHASE;
Pre_Divider_D_Input = VCO_PHASE;
VCO_Bypass_A_Input = VCO_PHASE;
VCO_Bypass_B_Input = VCO_PHASE;
VCO_Bypass_C_Input = VCO_PHASE;
VCO_Bypass_D_Input = VCO_PHASE;
FB_MODE = CLKOP;
CLKI_Divider = 1;
CLKFB_Divider = 12;
CLKOP_Divider = 3;
CLKOS_Divider = 125;
CLKOS2_Divider = 1;
CLKOS3_Divider = 105;
Fractional_N_Divider = 0;
CLKOP_Desired_Phase_Shift(degree) = 0;
CLKOP_Trim_Option_Rising/Falling = RISING;
CLKOP_Trim_Option_Delay = 0;
CLKOS_Desired_Phase_Shift(degree) = 0;
CLKOS_Trim_Option_Rising/Falling = RISING;
CLKOS_Trim_Option_Delay = 0;
CLKOS2_Desired_Phase_Shift(degree) = 0;
CLKOS3_Desired_Phase_Shift(degree) = 0;
; End PLL Section
;
; start of EFB statistics
I2C = 0;
SPI = 1;
TimerCounter = 0;
UFM = 0;
PLL = 0;
; end of EFB statistics
;
