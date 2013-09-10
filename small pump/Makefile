%.stl : %.scad
	openscad -o $@ $<
	cp $@ $(HOME)/DropBox/gcode

pump.scad pump-noholes.scad : pump_base.scad
	touch pump.scad pump-noholes.scad

all: pump.stl pump-noholes.stl

clean:
	rm *.stl
