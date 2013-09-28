include <parametric_involute_gear_v5.0.scad>;
rim_h = 1;
rim_w = 1;
gear_centre_d = 11.5;
gear_r = 7.5;
material_h = 6;
chamber_wall = 3;
clearance=0.5;
floor_h=material_h / 2 - rim_h;
shaft_d = 2;
fastening_d = 2;
// vertical position of center of pipe
pipe_vert_cent = (2 * material_h - 2 * rim_h)/2;
//showholes="true";
inout_d = 4;
outlet_offset = 7;


module pump_gear() {
gear (number_of_teeth=5,
			bore_diameter= shaft_d,
			circular_pitch=400,
			hub_diameter=1,
			rim_width=1,
			rim_thickness=material_h,
			gear_thickness=material_h,
			hub_thickness=1,
			involute_facets=20,
			clearance=0.2);
}

module body_hull(r, h) {
	hull() {
			cylinder(r = r, h = h);
			translate([gear_centre_d,0,0]) {cylinder(r = r, h = h);}
		}
}

module f_hole() {
translate([0,0,-0.1]) {
	cylinder(r = fastening_d/2, material_h+0.2);
	}
}

hole_offset = gear_r + chamber_wall/2 + clearance;
module f_holes() {
	if (showholes == "true") {
		union() {
			translate([-hole_offset, 0, 0]) { f_hole(); }
			translate([0, -hole_offset, 0]) { f_hole(); }
			translate([0, hole_offset, 0]) { f_hole(); }
			translate([gear_centre_d+hole_offset, 0, 0]) { f_hole(); }
			translate([gear_centre_d, -hole_offset, 0]) { f_hole(); }
			translate([gear_centre_d, hole_offset, 0]) { f_hole(); }
			translate([0, -inout_d/2 - chamber_wall/2 - 1, 0]) { move_to_outlet() {f_hole();} }
			
		}
	}
}

module inout_hole(r = 0) {
	hole() {cylinder(r = inout_d/2 + r, material_h);}
}

module out_blank(h = material_h, rim_s = 0, e = 0) {
	w = inout_d + 2 + chamber_wall * 2;

	move_to_outlet() { union() {
		cylinder(r = w/2 - rim_s + e, h);
		translate([-w/2 + rim_s, 0, 0]) { cube([w - rim_s * 2, w/2, h]); }
	}}
}

module shaft_holes() {
	if (showholes == "true") {
		translate([0,0,-0.05]) {
			union() {
			cylinder(r = shaft_d/2, material_h + 0.1);
			translate([gear_centre_d,0,0]) {cylinder(r = shaft_d/2, material_h + 0.1);}
			}
		}
	}
}

module housing_blank(h = material_h, h_block = material_h) {
	union() {
		body_hull(gear_r + chamber_wall + clearance, h);
		out_blank(h);
	}
}

module rim(e = 0) {
	difference() {
		union() {
			body_hull(gear_r + chamber_wall + clearance + e, rim_h);
			out_blank(rim_h, 0, e);
		}
		translate([0,0,-0.05]) {
			union() {
				body_hull(gear_r + chamber_wall - rim_w + e  + clearance, rim_h+0.1);
				out_blank(rim_h+0.1, rim_w, e);
			}
		}
	}
}

module outlet_cavity() {
	move_to_outlet() { cylinder(r = inout_d/2, material_h); }
	move_to_outlet() { translate([-inout_d/2, 0, 0]) { cube([inout_d, outlet_offset, material_h]); }}
}

module cavity() {
	union() {
		body_hull(gear_r + clearance, material_h);
		outlet_cavity();		
	}
}

module housing_lower() {

	difference() {
		union() {
			housing_blank(material_h, material_h - rim_h/2);
		}
		translate([0,0,floor_h]) { cavity(); }
		translate([0,0,material_h - rim_h + 0.01]){rim(0.1);}
		shaft_holes();
		f_holes();
		translate([gear_centre_d/2,gear_r,0]) { inout_hole(); }
	}
}

module housing_upper() {
	union() {
		difference() {
			union(){
				translate([0,0,-rim_h]){rim(0);}
				housing_blank(material_h - rim_h, material_h - rim_h/2);
			}
			translate([0,0,-floor_h - rim_h]) { cavity(); }
			shaft_holes();
			translate([0,0,- rim_h]) {f_holes();}
			move_to_outlet() { inout_hole(material_h > 3 ? 1 : 0); }
			if (material_h > 3) {
				mount_holes();
			}
		}
	}
}

module hole() {
	translate([0,0,-0.025]) {scale([1,1,1.05]) { child(0); }}
}

module move_to_outlet() {
	translate([gear_centre_d/2,-gear_r - outlet_offset,0]) { child(0); }
}

// motor mount bolt diameter
mount_d = 2;
// distance between mounting holes
mount_spacing = 15.5;
module mount_hole(x,y) {
	if (showholes == "true") {
		rotate([0,0,50]) {translate([x,y,0]) {hole() {cylinder(r = mount_d/2 - 0.1, h = material_h);}}}
	}
}

module mount_holes() {
	mount_hole(-mount_spacing/2,0);
	mount_hole(+mount_spacing/2,0);
	mount_hole(0,-mount_spacing/2);
	mount_hole(0,+mount_spacing/2);
}

module mounting_plate() {
	difference() {
	union() {
		housing_blank(material_h, material_h - rim_h/2);
		move_to_outlet() { cylinder(r = inout_d/2 + 3, h = material_h); }

	}
		//cylinder(r = gear_r + chamber_wall + clearance, h = material_h);
		shaft_holes();
		f_holes();
		mount_holes();
		move_to_outlet() { inout_hole(1); }

	}
}

ex = 5;

module exploded() {
	union() {
		translate([0,0,-floor_h-ex]) {housing_lower();}
		translate([0,0,material_h - floor_h + ex]) {housing_upper();}
		pump_gear();
		translate([gear_centre_d,0,0]) {pump_gear(); }
		translate([0,0,2 * material_h - floor_h + ex * 2]) { mounting_plate(); }
	}
}

housing_layout_width = 2 * (gear_r + chamber_wall + 5);

module tocam() {
	union() {
		translate([0, gear_centre_d, 0]) {rotate([0,0,-90]) {housing_lower();}}
		/*translate([housing_layout_width + 4, 0, material_h - rim_h]) {rotate([180,0,90]) {housing_upper();}}
		translate([2 * housing_layout_width - gear_r + 2, -4, 0]) {pump_gear();}
		translate([2 * housing_layout_width - gear_r + 2, gear_r * 2 - 2, 0]) {pump_gear();}
		if (material_h < 4) {
			translate([2 * housing_layout_width + gear_r * 1.5 + 5, 0,0]) { rotate([0,0,90]) {mounting_plate();} }
		}*/
	}

}

//exploded();

tocam();





