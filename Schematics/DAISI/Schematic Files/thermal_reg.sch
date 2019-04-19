v 20130925 2
C 40000 40000 0 0 0 title-B.sym
T 54000 40100 9 10 1 0 0 0 1
S A Burrows
T 53900 40400 9 10 1 0 0 0 1
A
T 50100 40100 9 10 1 0 0 0 1
1
T 51600 40100 9 10 1 0 0 0 1
1
T 50100 40700 9 10 1 0 0 0 1
Thermal Regulation
T 50100 40400 9 10 1 0 0 0 1
THERMAL_REG.sch
C 41600 48400 1 0 0 TMP107.sym
{
T 41900 49950 5 10 0 0 0 0 1
device=TMP107
T 43300 49800 5 10 1 1 0 6 1
refdes=U10
T 41900 50150 5 10 0 0 0 0 1
footprint=IC_SOIC_8
}
C 44400 48400 1 0 0 TMP107.sym
{
T 44700 49950 5 10 0 0 0 0 1
device=TMP107
T 46100 49800 5 10 1 1 0 6 1
refdes=U11
T 44700 50150 5 10 0 0 0 0 1
footprint=IC_SOIC_8
}
C 47200 48400 1 0 0 TMP107.sym
{
T 47500 49950 5 10 0 0 0 0 1
device=TMP107
T 48900 49800 5 10 1 1 0 6 1
refdes=U12
T 47500 50150 5 10 0 0 0 0 1
footprint=IC_SOIC_8
}
C 49900 48400 1 0 0 TMP107.sym
{
T 50200 49950 5 10 0 0 0 0 1
device=TMP107
T 51600 49800 5 10 1 1 0 6 1
refdes=U13
T 50200 50150 5 10 0 0 0 0 1
footprint=IC_SOIC_8
}
C 41400 50500 1 0 0 3.3V-plus-1.sym
N 41600 49200 41600 50500 4
N 43600 49200 44000 49200 4
N 44400 48900 44000 48900 4
N 44000 48900 44000 49200 4
N 47200 48900 46800 48900 4
N 46800 48900 46800 49200 4
N 46800 49200 46400 49200 4
N 49900 48900 49500 48900 4
N 49200 49200 49500 49200 4
N 49500 49200 49500 48900 4
C 41900 50200 1 0 0 capacitor-1.sym
{
T 42100 50900 5 10 0 0 0 0 1
device=CAPACITOR
T 42100 51100 5 10 0 0 0 0 1
symversion=0.1
T 41900 50200 5 10 1 1 0 0 1
refdes=C72
T 42400 50200 5 10 1 1 0 0 1
value=0.1 μF
T 41900 50200 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 43400 50300 1 90 0 gnd-1.sym
N 41900 50400 41600 50400 4
N 42800 50400 43100 50400 4
C 44200 50500 1 0 0 3.3V-plus-1.sym
C 44700 50200 1 0 0 capacitor-1.sym
{
T 44900 50900 5 10 0 0 0 0 1
device=CAPACITOR
T 44900 51100 5 10 0 0 0 0 1
symversion=0.1
T 44700 50200 5 10 1 1 0 0 1
refdes=C73
T 45200 50200 5 10 1 1 0 0 1
value=0.1 μF
T 44700 50200 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 46200 50300 1 90 0 gnd-1.sym
N 44700 50400 44400 50400 4
N 45600 50400 45900 50400 4
N 44400 49200 44400 50500 4
C 47000 50500 1 0 0 3.3V-plus-1.sym
C 47500 50200 1 0 0 capacitor-1.sym
{
T 47700 50900 5 10 0 0 0 0 1
device=CAPACITOR
T 47700 51100 5 10 0 0 0 0 1
symversion=0.1
T 47500 50200 5 10 1 1 0 0 1
refdes=C74
T 48000 50200 5 10 1 1 0 0 1
value=0.1 μF
T 47500 50200 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 49000 50300 1 90 0 gnd-1.sym
N 47500 50400 47200 50400 4
N 48400 50400 48700 50400 4
N 47200 49200 47200 50500 4
C 49700 50500 1 0 0 3.3V-plus-1.sym
C 50200 50200 1 0 0 capacitor-1.sym
{
T 50400 50900 5 10 0 0 0 0 1
device=CAPACITOR
T 50400 51100 5 10 0 0 0 0 1
symversion=0.1
T 50200 50200 5 10 1 1 0 0 1
refdes=C75
T 50700 50200 5 10 1 1 0 0 1
value=0.1 μF
T 50200 50200 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 51700 50300 1 90 0 gnd-1.sym
N 50200 50400 49900 50400 4
N 51100 50400 51400 50400 4
N 49900 49200 49900 50500 4
N 43600 49500 44400 49500 4
N 46400 49500 47200 49500 4
N 49200 49500 49900 49500 4
C 51900 49800 1 0 0 3.3V-plus-1.sym
N 51900 49500 52100 49500 4
N 52100 49500 52100 49800 4
C 51800 48000 1 0 0 gnd-1.sym
C 49100 48000 1 0 0 gnd-1.sym
C 46300 48000 1 0 0 gnd-1.sym
C 43500 48000 1 0 0 gnd-1.sym
N 43600 48300 43600 48600 4
N 46400 48300 46400 48600 4
N 49200 48300 49200 48600 4
N 51900 48300 51900 48600 4
C 41400 49000 1 180 0 io-1.sym
{
T 40600 49000 5 10 0 1 180 0 1
net=TEMP_COMM:1
T 41400 49200 5 10 1 1 180 0 1
value=TEMP_COMM
}
N 41400 48900 41600 48900 4
C 41900 48000 1 0 0 io-1.sym
{
T 42700 48100 5 10 0 1 0 0 1
net=THERM_EN1:1
T 42100 48600 5 10 0 0 0 0 1
device=none
T 41800 47800 5 10 1 1 0 1 1
value=THERM_EN1
}
N 41400 48600 41400 48100 4
C 44700 48000 1 0 0 io-1.sym
{
T 45500 48100 5 10 0 1 0 0 1
net=THERM_EN2:1
T 44900 48600 5 10 0 0 0 0 1
device=none
T 44600 47800 5 10 1 1 0 1 1
value=THERM_EN2
}
N 44200 48600 44200 48100 4
C 47500 48000 1 0 0 io-1.sym
{
T 48300 48100 5 10 0 1 0 0 1
net=THERM_EN3:1
T 47700 48600 5 10 0 0 0 0 1
device=none
T 47500 47800 5 10 1 1 0 1 1
value=THERM_EN3
}
N 47000 48600 47000 48100 4
C 50200 48000 1 0 0 io-1.sym
{
T 51000 48100 5 10 0 1 0 0 1
net=THERM_EN4:1
T 50400 48600 5 10 0 0 0 0 1
device=none
T 50200 47700 5 10 1 1 0 1 1
value=THERM_EN4
}
N 49700 48600 49700 48100 4
N 45400 46700 46600 46700 4
N 48700 40800 48700 45700 4
C 48600 40500 1 0 0 gnd-1.sym
N 41600 48600 41400 48600 4
N 41900 48100 41400 48100 4
N 44700 48100 44200 48100 4
N 44200 48600 44400 48600 4
N 47200 48600 47000 48600 4
N 47500 48100 47000 48100 4
N 50200 48100 49700 48100 4
N 49900 48600 49700 48600 4
C 42600 43200 1 0 0 LT1161.sym
{
T 42600 46550 5 10 0 0 0 0 1
device=LT1161
T 43700 44700 5 10 1 1 0 6 1
refdes=U16
T 42600 46750 5 10 0 0 0 0 1
footprint=SOIC-20-W
}
N 42800 46500 43800 46500 4
N 43600 46600 43600 46500 4
C 43500 42700 1 0 0 gnd-1.sym
N 43800 46400 43800 46500 4
N 43400 46400 43400 46500 4
N 43400 43200 43400 43100 4
N 43400 43100 43800 43100 4
N 43800 43100 43800 43200 4
N 43600 43000 43600 43100 4
N 42500 44600 42600 44600 4
N 42500 44300 42600 44300 4
N 42500 44000 42600 44000 4
N 42500 43700 42600 43700 4
C 40800 46300 1 0 0 capacitor-1.sym
{
T 41000 47000 5 10 0 0 0 0 1
device=CAPACITOR
T 41000 47200 5 10 0 0 0 0 1
symversion=0.1
T 40700 46600 5 10 1 1 0 0 1
refdes=C105
T 41400 46600 5 10 1 1 0 0 1
value=0.1 μF
T 40800 46300 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 40800 45800 1 0 0 capacitor-1.sym
{
T 41000 46500 5 10 0 0 0 0 1
device=CAPACITOR
T 41000 46700 5 10 0 0 0 0 1
symversion=0.1
T 40700 46100 5 10 1 1 0 0 1
refdes=C106
T 41400 46100 5 10 1 1 0 0 1
value=0.1 μF
T 40800 45800 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 40800 45300 1 0 0 capacitor-1.sym
{
T 41000 46000 5 10 0 0 0 0 1
device=CAPACITOR
T 41000 46200 5 10 0 0 0 0 1
symversion=0.1
T 40700 45600 5 10 1 1 0 0 1
refdes=C107
T 41400 45600 5 10 1 1 0 0 1
value=0.1 μF
T 40800 45300 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 40800 44800 1 0 0 capacitor-1.sym
{
T 41000 45500 5 10 0 0 0 0 1
device=CAPACITOR
T 41000 45700 5 10 0 0 0 0 1
symversion=0.1
T 40700 45100 5 10 1 1 0 0 1
refdes=C108
T 41400 45100 5 10 1 1 0 0 1
value=0.1 μF
T 40800 44800 5 10 0 1 0 0 1
footprint=SMD_CHIP 603
}
C 40300 45000 1 0 0 gnd-1.sym
N 40400 45300 40400 45500 4
N 40800 46500 40600 46500 4
N 40600 45000 40600 47000 4
N 40800 46000 40600 46000 4
N 40800 45500 40600 45500 4
N 41900 44900 42600 44900 4
N 41700 45500 42000 45500 4
N 42000 45200 42000 45500 4
N 42000 45200 42600 45200 4
N 41700 46000 42200 46000 4
N 42200 45500 42200 46000 4
N 42200 45500 42600 45500 4
N 41700 46500 42400 46500 4
N 42400 45800 42400 46500 4
N 42400 45800 42600 45800 4
N 41700 45000 41900 45000 4
N 41900 45000 41900 44900 4
N 40800 45000 40600 45000 4
N 40600 45500 40400 45500 4
N 45000 41900 46600 41900 4
N 47500 41900 49200 41900 4
N 45400 43500 46600 43500 4
N 47500 46700 49200 46700 4
N 45400 46700 45400 45800 4
N 45700 46000 45600 46000 4
N 45600 46000 45600 45500 4
N 44600 45800 45400 45800 4
N 44600 45500 45600 45500 4
N 49200 41900 49200 46800 4
N 44600 45200 46200 45200 4
N 44600 44900 45600 44900 4
N 45600 44400 45700 44400 4
N 45600 44400 45600 44900 4
N 44600 44600 45400 44600 4
N 45400 44600 45400 43500 4
N 44600 44300 45200 44300 4
N 45200 44300 45200 42800 4
N 45200 42800 45700 42800 4
N 44600 44000 45000 44000 4
N 45000 44000 45000 41900 4
N 44600 43700 44800 43700 4
N 44800 43700 44800 41200 4
N 44800 41200 45700 41200 4
C 40800 46800 1 0 0 capacitor-1.sym
{
T 41000 47500 5 10 0 0 0 0 1
device=CAPACITOR
T 41000 47700 5 10 0 2 0 0 1
symversion=0.1
T 40700 47100 5 10 1 1 0 0 1
refdes=C104
T 41400 47100 5 10 1 1 0 0 1
value=50 μF
T 40800 46800 5 10 0 1 0 0 1
footprint=SMD-6_6mm-7_8mm
}
N 40800 47000 40600 47000 4
N 42800 46500 42800 47000 4
N 42800 47000 41700 47000 4
C 49000 46800 1 0 0 generic-power.sym
{
T 49200 47050 5 10 0 1 0 3 1
net=VMAIN:1
T 48900 47000 5 10 1 1 0 0 1
value=VMAIN
}
C 43400 46600 1 0 0 generic-power.sym
{
T 43600 46850 5 10 0 1 0 3 1
net=VMAIN:1
T 43300 46800 5 10 1 1 0 0 1
value=VMAIN
}
C 47500 46800 1 180 0 resistor-1.sym
{
T 47200 46400 5 10 0 0 180 0 1
device=RESISTOR
T 47500 46800 5 10 0 1 90 0 1
footprint=SMD2512
T 46600 46900 5 10 1 1 0 0 1
refdes=R79
T 47700 47000 5 10 1 1 180 0 1
value=220 mΩ
}
C 47600 45600 1 0 0 resistor-1.sym
{
T 47900 46000 5 10 0 0 0 0 1
device=RESISTOR
T 47600 45600 5 10 0 1 270 0 1
footprint=SMD2512
T 48000 46000 5 10 1 1 180 0 1
refdes=R80
T 48100 45900 5 10 1 1 0 0 1
value=60 Ω
}
C 46600 45600 1 0 0 resistor-1.sym
{
T 46900 46000 5 10 0 0 0 0 1
device=RESISTOR
T 46600 45600 5 10 0 1 270 0 1
footprint=SMD2512
T 46900 46000 5 10 1 1 180 0 1
refdes=R81
T 47000 45900 5 10 1 1 0 0 1
value=60 Ω
}
N 46200 46600 46200 46700 4
N 48700 45700 48500 45700 4
N 47600 45700 47500 45700 4
N 46200 45700 46200 45800 4
N 46200 45700 46600 45700 4
C 45700 45800 1 0 0 IRFZ34N.sym
{
T 46300 46300 5 10 0 0 0 0 1
device=NMOS_TRANSISTOR
T 45700 45800 5 10 0 0 0 0 1
footprint=TO-263-3
T 46400 46400 5 10 1 1 0 0 1
refdes=Q3
}
C 42500 44100 1 180 0 io-1.sym
{
T 41700 44000 5 10 0 1 180 0 1
net=THERM_EN1:1
T 42300 43500 5 10 0 0 180 0 1
device=none
T 41600 44000 5 10 1 1 180 1 1
value=THERM_EN1
}
C 42500 44700 1 180 0 io-1.sym
{
T 41700 44600 5 10 0 1 180 0 1
net=THERM_EN3:1
T 42300 44100 5 10 0 0 180 0 1
device=none
T 41600 44600 5 10 1 1 180 1 1
value=THERM_EN3
}
C 47500 42000 1 180 0 resistor-1.sym
{
T 47200 41600 5 10 0 0 180 0 1
device=RESISTOR
T 47500 42000 5 10 0 1 90 0 1
footprint=SMD2512
T 46600 42100 5 10 1 1 0 0 1
refdes=R76
T 47700 42200 5 10 1 1 180 0 1
value=220 mΩ
}
C 47600 40800 1 0 0 resistor-1.sym
{
T 47900 41200 5 10 0 0 0 0 1
device=RESISTOR
T 47600 40800 5 10 0 1 270 0 1
footprint=SMD2512
T 48000 41200 5 10 1 1 180 0 1
refdes=R77
T 48100 41100 5 10 1 1 0 0 1
value=60 Ω
}
C 46600 40800 1 0 0 resistor-1.sym
{
T 46900 41200 5 10 0 0 0 0 1
device=RESISTOR
T 46600 40800 5 10 0 1 270 0 1
footprint=SMD2512
T 47000 41200 5 10 1 1 180 0 1
refdes=R78
T 47100 41100 5 10 1 1 0 0 1
value=60 Ω
}
N 46200 41800 46200 41900 4
N 47600 40900 47500 40900 4
N 46200 40900 46600 40900 4
N 48500 40900 48700 40900 4
N 46200 40900 46200 41000 4
C 45700 41000 1 0 0 IRFZ34N.sym
{
T 46300 41500 5 10 0 0 0 0 1
device=NMOS_TRANSISTOR
T 45700 41000 5 10 0 0 0 0 1
footprint=TO-263-3
T 46400 41600 5 10 1 1 0 0 1
refdes=Q2
}
C 42500 43800 1 180 0 io-1.sym
{
T 41700 43700 5 10 0 1 180 0 1
net=THERM_EN2:1
T 42300 43200 5 10 0 0 180 0 1
device=none
T 41600 43700 5 10 1 1 180 1 1
value=THERM_EN2
}
C 42500 44400 1 180 0 io-1.sym
{
T 41700 44300 5 10 0 1 180 0 1
net=THERM_EN4:1
T 42300 43800 5 10 0 0 180 0 1
device=none
T 41600 44300 5 10 1 1 180 1 1
value=THERM_EN4
}
N 47500 45100 49200 45100 4
C 46600 45000 1 0 0 resistor-1.sym
{
T 46900 45400 5 10 0 0 0 0 1
device=RESISTOR
T 46600 45000 5 10 0 1 270 0 1
footprint=SMD2512
T 46900 45400 5 10 1 1 180 0 1
refdes=R82
T 47000 45300 5 10 1 1 0 0 1
value=220 mΩ
}
C 47600 44000 1 0 0 resistor-1.sym
{
T 47900 44400 5 10 0 0 0 0 1
device=RESISTOR
T 47600 44000 5 10 0 1 270 0 1
footprint=SMD2512
T 47900 44400 5 10 1 1 180 0 1
refdes=R83
T 48000 44300 5 10 1 1 0 0 1
value=60 Ω
}
C 46600 44000 1 0 0 resistor-1.sym
{
T 46900 44400 5 10 0 0 0 0 1
device=RESISTOR
T 46600 44000 5 10 0 1 270 0 1
footprint=SMD2512
T 46900 44400 5 10 1 1 180 0 1
refdes=R84
T 47000 44300 5 10 1 1 0 0 1
value=60 Ω
}
N 46600 44100 46200 44100 4
N 48500 44100 48700 44100 4
N 47600 44100 47500 44100 4
N 46200 44200 46200 44100 4
N 46200 45000 46200 45200 4
C 45700 44200 1 0 0 IRFZ34N.sym
{
T 46300 44700 5 10 0 0 0 0 1
device=NMOS_TRANSISTOR
T 45700 44200 5 10 0 0 0 0 1
footprint=TO-263-3
T 46400 44800 5 10 1 1 0 0 1
refdes=Q4
}
N 46600 45100 46200 45100 4
N 47500 43500 49200 43500 4
C 47500 43600 1 180 0 resistor-1.sym
{
T 47200 43200 5 10 0 0 180 0 1
device=RESISTOR
T 47500 43600 5 10 0 1 90 0 1
footprint=SMD2512
T 46500 43700 5 10 1 1 0 0 1
refdes=R73
T 47600 43800 5 10 1 1 180 0 1
value=220 mΩ
}
C 47600 42400 1 0 0 resistor-1.sym
{
T 47900 42800 5 10 0 0 0 0 1
device=RESISTOR
T 47600 42400 5 10 0 1 270 0 1
footprint=SMD2512
T 48000 42800 5 10 1 1 180 0 1
refdes=R74
T 48100 42700 5 10 1 1 0 0 1
value=60 Ω
}
C 46600 42400 1 0 0 resistor-1.sym
{
T 46900 42800 5 10 0 0 0 0 1
device=RESISTOR
T 46600 42400 5 10 0 1 270 0 1
footprint=SMD2512
T 46900 42800 5 10 1 1 180 0 1
refdes=R75
T 47100 42700 5 10 1 1 0 0 1
value=60 Ω
}
N 48700 42500 48500 42500 4
N 47600 42500 47500 42500 4
N 46200 42600 46200 42500 4
N 46600 42500 46200 42500 4
N 46200 43400 46200 43500 4
C 45700 42600 1 0 0 IRFZ34N.sym
{
T 46300 43100 5 10 0 0 0 0 1
device=NMOS_TRANSISTOR
T 45700 42600 5 10 0 0 0 0 1
footprint=TO-263-3
T 46400 43200 5 10 1 1 0 0 1
refdes=Q1
}