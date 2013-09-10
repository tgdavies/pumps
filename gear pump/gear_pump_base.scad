include <parametric_involute_gear_v5.0.scad>;
rim_h = 1;
rim_w = 1;
gear_centre_d = 21.1;
gear_r = 15;
material_h = 3;
chamber_wall = 3;
clearance=0.5;
floor_h=material_h / 2 - rim_h;
pipe_d=4;
pipe_wall = material_h * 2 - pipe_d - rim_h;
pipe_l=8;
pipe_b_w = pipe_d + pipe_wall * 2;
shaft_d = 2;
fastening_d = 2;
// vertical position of center of pipe
pipe_vert_cent = (2 * material_h - 2 * rim_h)/2;



module pump_gear() {
gear (number_of_teeth=5,
			bore_diameter= shaft_d,
			circular_pitch=750,
			hub_diameter=1,
			rim_width=1,
			rim_thickness=material_h-0.1,
			gear_thickness=material_h,
			hub_thickness=1,
			involute_facets=20,
			clearance=0.2);
}

module pipe_block(h) {
	cube([pipe_d + pipe_wall * 2, pipe_l - chamber_wall, h]);
}

module pipe() {
	rotate([-90,0,0]) {translate([0,0,-0.1]){cylinder(r = pipe_d/2, h = pipe_l + 0.2);}}
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
		}
	}
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
	}
}

module pipe_blocks(h, h_block) {
	union() {
		translate([gear_centre_d/2 - pipe_b_w/2, gear_r + chamber_wall , h - h_block]) {pipe_block(h_block);}
		translate([gear_centre_d/2 - pipe_b_w/2, -gear_r-pipe_l, h - h_block]) {pipe_block(h_block);}
	}
}

module rim(e = 0) {
	difference() {
		body_hull(gear_r + chamber_wall + clearance + e, rim_h);
		translate([0,0,-0.05]) {body_hull(gear_r + chamber_wall - rim_w + e  + clearance, rim_h+0.1);}
	}
}

module cavity() {
	union() {
		body_hull(gear_r + clearance, material_h);			
	}
}

module pipes() {
		translate([gear_centre_d/2, gear_r, pipe_vert_cent - pipe_d/2 ]) {pipe();}
		translate([gear_centre_d/2, -gear_r-pipe_l, pipe_vert_cent - pipe_d/2 ]) {pipe();}
}

// remove the overhanging material above the pipe opening
module pipe_overhang() {
	translate([-pipe_d/2,0,0]) {cube([pipe_d, chamber_wall + 0.1, pipe_d/2]);}
}
module pipes_overhang() {
		translate([gear_centre_d/2, gear_r+clearance, pipe_vert_cent]) {pipe_overhang();}
		translate([gear_centre_d/2, -gear_r-chamber_wall-clearance, pipe_vert_cent]) {pipe_overhang();}
}

module housing_lower() {

	difference() {
		union() {
			housing_blank(material_h, material_h - rim_h/2);
			translate([0,0,rim_h/2]){pipe_blocks(material_h - rim_h, material_h - rim_h/2);}
		}
		translate([0,0,floor_h]) { cavity(); }
		translate([0,0,material_h - rim_h + 0.01]){rim(0.1);}
		shaft_holes();
		f_holes();
		translate([0,0,material_h - rim_h/2]) { pipes(); }
		translate([0,0,material_h - rim_h - pipe_d/2]) { pipes_overhang(); }

	}
}

module housing_upper() {
	union() {
		difference() {
			union(){
				translate([0,0,-rim_h]){rim(0);}
				housing_blank(material_h - rim_h, material_h - rim_h/2);
				pipe_blocks(material_h - rim_h, material_h - rim_h/2);
			}
			translate([0,0,-floor_h - rim_h]) { cavity(); }
			shaft_holes();
			translate([0,0,- rim_h]) {f_holes();}
			translate([0,0,-rim_h/2]) { pipes(); }
			translate([0,0,-rim_h-pipe_d]) { pipes_overhang(); }
		}
	}
}

module hole() {
	translate([0,0,-0.025]) {scale([1,1,1.05]) { child(0); }}
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

module mounting_plate() {
	difference() {
		cylinder(r = gear_r + chamber_wall + clearance, h = material_h);
		shaft_holes();
		f_holes();
		mount_hole(-mount_spacing/2,0);
		mount_hole(+mount_spacing/2,0);
		mount_hole(0,-mount_spacing/2);
		mount_hole(0,+mount_spacing/2);
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

housing_layout_width = 2 * (gear_r + chamber_wall + pipe_l);

module tocam() {
	union() {
		rotate([0,0,90]) {housing_lower();}
		translate([housing_layout_width, 0, material_h - rim_h]) {rotate([180,0,90]) {housing_upper();}}
		translate([2 * housing_layout_width - gear_r + 3, 0, 0]) {pump_gear();}
		translate([2 * housing_layout_width - gear_r + 2, gear_r * 2 + 3, 0]) {pump_gear();}
		translate([2 * housing_layout_width + gear_r * 1.5, gear_r,0]) { mounting_plate(); }
	}

}

//exploded();

tocam();




