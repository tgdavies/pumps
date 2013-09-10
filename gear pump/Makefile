%.stl : %.scad
	openscad -o $@ $<
	cp $@ $(HOME)/DropBox/gcode

all: gear-pump.stl gear-pump-noholes.stl

clean:
	rm *.stl
