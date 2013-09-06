%.stl : %.scad
	openscad -o $@ $<
	cp $@ $(HOME)/DropBox/gcode

all: pump.stl pump-noholes.stl
