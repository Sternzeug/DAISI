#!/usr/bin/python

from footgen import *

#f = Footgen("QFN64_9x9")
#f.qfn(pitch = 0.5, pins = 64, width = 8.2, padheight = 0.254, padwidth = 0.60, silk_xsize = 9.0)
#f.thermal_pad(6.0, pin=65, copper_expansion = 0.4)
#f.via_array(columns=6, pitch=1.3, pin=65, pad=0.46, size=0.2, mask_clearance=-0.1, outer_only=True)
#f.finish()

#f = Footgen("OSC_ABR_2.5x2")
#f.so(pitch = 1.65, pins = 4, width = 0.7, padheight = 0.65, padwidth = 0.85)
#f.finish()

#f = Footgen("SMD2512")
#f.so(pitch = 0.0, pins = 2, width = 4.5, padheight = 3.2, padwidth = 1.1)
#f.silkbox(h=3.4, w = 6.3)
#f.finish()

#f = Footgen("TO-263-3")
#f.tabbed(pitch = 5.08, pins = 2, height = 5.08, padheight = 3.81, padwidth = 2.08, tabheight = 8.89, tabwidth = 11.43)
#f.silkbox(h=17.78, w = 11.43, arc=0.5)
#f.finish()

#f = Footgen("SOIC-20-W")
#f.so(pitch = 1.27, pins = 20, width = 8.255, padheight = 0.762, padwidth = 1.143)
#f.silkbox(h=13.0, w = 10.668, arc=0.5)
#f.finish()

#f = Footgen("TO-263-5")
#f.tabbed(pitch = 1.7, pins = 5, height = 5.02, padheight = 2.16, padwidth = 1.07, tabheight = 6.99, tabwidth = 10.8)
#f.silkbox(h=14.35, w = 10.8, arc=0.5)
#f.finish()

#f = Footgen("TO-261-4")
#f.tabbed(pitch = 2.3, pins = 3, height = 3.615, padheight = 2.22, padwidth = 1.02, tabheight = 2.15, tabwidth = 3.25)
#f.silkbox(h=7.85, w = 6.70)
#f.finish()

#f = Footgen("TO-261-5")
#f.tabbed(pitch = 1.5, pins = 4, height = 4.8, padheight = 1.5, padwidth = 1.0, tabheight = 1.5, tabwidth = 3.3)
#f.silkbox(h=7.65, w = 6.70)
#f.finish()

#f = Footgen("DIP-6")
#f.dip(pitch = 10.2, width=20.3, drill = 1.3, pins = 6, diameter = 2.0, pin1shape="circle", draw_silk=False)
#f.silkbox(w=25.4, h=25.4, arc=0.5, silkwidth=0.155)
#f.finish()


#f = Footgen("MICROSD")
#f.add_pad("CD1", x=6.25, y=-9.925, xsize=1.0, ysize=1.55)
#f.add_pad("", x=6.65, y=-7.5, xsize=0.8, ysize=1.4)
#f.add_pad("GND1", x=6.30, y=0.75, xsize=1.5, ysize=1.5)
#f.add_pad("1", x=3.85, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("2", x=2.75, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("3", x=1.65, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("4", x=0.55, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("5", x=-0.55, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("6", x=-1.65, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("7", x=-2.75, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("8", x=-3.85, y=0.875, xsize=0.70, ysize=1.75)
#f.add_pad("GND2", x=-5.05, y=0.75, xsize=1.3, ysize=1.5)
#f.add_pad("", x=-5.3, y=-6.85, xsize=0.8, ysize=1.5)
#f.add_pad("CD2", x=-4.975, y=-8.35, xsize=1.45, ysize=1.0)
#f.silkbox(h=3.5, w=11.50)
#f.finish()


#f = Footgen("MOLEX-5X1")
#f.add_pad("1", x=-10.0, y=0.0, xsize=2.0, ysize=2.0, drill=1.3, diameter=0.0, shape="rect")
#f.add_pad("2", x=-5.0, y=0.0, xsize=0.0, ysize=0.0, drill=1.3, diameter=2.0, shape="circle")
#f.add_pad("3", x=0.0, y=0.0, xsize=0.0, ysize=0.0, drill=1.3, diameter=2.0, shape="circle")
#f.add_pad("4", x=5.0, y=0.0, xsize=0.0, ysize=0.0, drill=1.3, diameter=2.0, shape="circle")
#f.add_pad("5", x=10.0, y=0.0, xsize=0.0, ysize=0.0, drill=1.3, diameter=2.0, shape="circle")
#f.silkbox(h=4.0, w=27.0)
#f.finish()

#f = Footgen("SMD1010")
#f.add_pad("1", x=0.0, y=-4.2, xsize=2.5, ysize=4.4)
#f.add_pad("2", x=0.0, y=4.2, xsize=2.5, ysize=4.4)
#f.silkbox(h=10.0, w=10.0, arc=5.0)
#f.finish()

#f = Footgen("SMD-6_3-DIA")
#f.add_pad("1", x=0.0, y=-2.5, xsize=1.6, ysize=3.2)
#f.add_pad("2", x=0.0, y=2.5, xsize=1.6, ysize=3.2)
#f.silkbox(h=6.6, w=6.6, arc=3.0)
#f.finish()

f = Footgen("DFN-8")
f.so(pitch = 1.27, pins = 8, width = 6.10, padheight = 0.45, padwidth = 0.7)
f.thermal_pad(6.0, pin=9, copper_expansion = 0.4)
f.silkbox(h=5.3, w = 6.3, arc=0.5)
f.finish()
