
$fn = 100;

// diameter of chamber
chamber_d = 20;
// thickness of chamber walls
chamber_wall = 3;
// height of ridge/depression around chamber
ridge_h = 1;
// width of ridge/depression around chamber
ridge_w = 1;
// thickness of material
material_h = 3;
// clearance between impeller blades and chamber walls
impeller_clearance = 0.5;
// clearance between impeller blades and top/bottom
impeller_v_clearance = 0.25;
// no. of blades
blade_count = 3;
// diameter of motor shaft
shaft_d = 2;
// thickness of hub walls
hub_wall_thickness = 1.5;
// outlet diameter
outlet_d = 4;
// extra distance between outlet hole and chamber
outlet_offset = 0;
// diameter of holes for fastening the layers of the chamber together
chamber_hole_d = 2;
// thickness of chamber floor and ceiling
chamber_floor = (material_h * 2 - (material_h + impeller_v_clearance + ridge_h)) / 2;
// inlet hole diameter
inlet_d = hub_wall_thickness * 2 + 6;
// motor mount bolt diameter
mount_d = 2;
// distance between mounting holes
mount_spacing = 15.5;

module impeller_blade() {
	cube([chamber_d/2,1.5,material_h]);
}

module blades() {
	for (i = [0 : blade_count - 1]) {
		rotate(a=[0,0,(360 / blade_count) * i]) {
		 impeller_blade();
		}
	}
}

module impeller() {
		difference() {
			union() {
				cylinder(r = shaft_d/2 + hub_wall_thickness, h = material_h);
				intersection() {
					blades();
					translate([0,0,0]) {cylinder(r = chamber_d / 2 - impeller_clearance, material_h - impeller_v_clearance);}
				}				
			}
			if (showholes == "true") {
				hole() {cylinder(r = shaft_d/2, h = material_h);}
			}
		}
}

module chamber_hole() {
	cylinder(r = chamber_hole_d/2, h = material_h);
}
module chamber_edge_hole() {
	translate([chamber_d/2 + chamber_wall/2,0,0]) {chamber_hole();}
}
// a positive of the holes to be subtracted
module outer_holes() {
	n = 30;
	if (showholes == "true") {
		hole() {union() {
			rotate([0,0,n]){chamber_edge_hole();}
			rotate([0,0,n+90]){chamber_edge_hole();}
			rotate([0,0,n+180]){chamber_edge_hole();}
			rotate([0,0,n+270]){chamber_edge_hole();}
		}}
	}
}

module p_outlet_blank(size, height) {
	hull() {
		to_outlet() {cylinder(r = size, h = height);}
		rotate([0,0,45]){translate([0,-(chamber_d/2-outlet_d/2),0]){cylinder(r = size, h = height);}}
	}
}

module outlet_blank() {
	/*hull() {
		to_outlet() {cylinder(r = outlet_d/2 + chamber_wall, h = material_h);}
		rotate([0,0,45]){translate([0,-(chamber_d/2-outlet_d/2),0]){cylinder(r = outlet_d/2 + chamber_wall, h = material_h);}}
	}*/
	p_outlet_blank(outlet_d/2 + chamber_wall, material_h);
}

module chamber_blank() {
	difference() {
		union() {
			cylinder(r = chamber_d/2 + chamber_wall, h = material_h);
			outlet_blank();
		}
		outer_holes();
	}
}

module chamber_ridge(m) {
	difference() {
		cylinder(r = chamber_d/2 + chamber_wall, h = ridge_h);
		hole() {cylinder(r = chamber_d/2 + chamber_wall - ridge_w - m, h = ridge_h);}
		hole() {outlet_blank();}
	}
}

module outlet_ridge(m) {
	difference() {
		p_outlet_blank(outlet_d/2 + chamber_wall, ridge_h);
		hole() {p_outlet_blank(outlet_d/2 + chamber_wall - ridge_w - m, ridge_h);}
		hole() {cylinder(r = chamber_d/2 + chamber_wall - ridge_w - m, h = ridge_h);}
	}
}

module ridge(m=0) {
	union() {
		chamber_ridge(m);
		outlet_ridge(m);
	}
}

module to_outlet() {
	translate([chamber_d/2+outlet_d/2+outlet_offset,0,0]) { child(0); }
}

module outlet_cavity() {
	hull() {
		to_outlet() {
			union() {
				translate([0,0,outlet_d/2]) {cylinder(r = outlet_d/2, h = 2 * material_h - chamber_floor - outlet_d/2);}
				intersection() {
					translate([0,0,outlet_d/2 + chamber_floor]) {sphere(r = outlet_d/2);}
					cylinder(r = outlet_d, h = outlet_d/2);
				}
			}
		}
		rotate([0,0,45]){translate([0,-(chamber_d/2-outlet_d/2),chamber_floor]){cylinder(r = outlet_d/2, h = 2 * (material_h - chamber_floor));}}
	}

}

module chamber_cavity() {
		union() {
			cylinder(r = chamber_d/2, h = material_h);
		}
}

module hole() {
	translate([0,0,-0.025]) {scale([1,1,1.05]) { child(0); }}
}

module inlet_hole() {
	hole() {cylinder(r = inlet_d/2, h = material_h);}
}

module outlet_hole(a = 0) {
	to_outlet() {hole() {cylinder(r = outlet_d/2 + a, h = material_h);}}
}

module shaft_hole() {
	hole() {cylinder(r = shaft_d/2 + 0.25, h = material_h);}
}

module mount_hole(x,y) {
	rotate([0,0,50]) {translate([x,y,0]) {hole() {cylinder(r = mount_d/2 - 0.1, h = material_h);}}}
}


module chamber_b() {
	union() {
		difference() {
			union() {
				difference() {
					chamber_blank();
					translate([0,0,material_h - ridge_h]) {cylinder(r = 1000, h = ridge_h + 0.01);}
				}
				translate([0,0,material_h - ridge_h]) { ridge(); } 
			}
			translate([0,0,material_h - ridge_h]) { outer_holes();} // drill the ridge
			translate([0,0,chamber_floor]) { union() {chamber_cavity(); }}
			outlet_cavity();
			inlet_hole();

		}
	}
}

module chamber_t() {
	difference() {
		chamber_blank();
		translate([0,0,-chamber_floor]) { union() {chamber_cavity();  } }
		outlet_hole();
		if (showholes == "true") {
			shaft_hole();
		}
		translate([0,0,-material_h]) { outlet_cavity();}
		translate([0,0,-0.01]) {scale([1.001, 1.001, 1]) { ridge(0.1); } }
	}
}

module mount() {
	difference() {
		chamber_blank();
		outlet_hole(1);
		if (showholes == "true") {
			shaft_hole();
			mount_hole(-mount_spacing/2,0);
			mount_hole(+mount_spacing/2,0);
			mount_hole(0,-mount_spacing/2);
			mount_hole(0,+mount_spacing/2);
		}
	}
}

//impeller();

//outlet_cavity();

//chamber_b();
module cutaway() {
difference() {
 union() {
	color([0,1,1,1]) {translate([0,0,material_h - ridge_h ]){chamber_t();}}
	translate([0,0,chamber_floor + impeller_v_clearance]){impeller();}
	color([1,1,0,0.4]) {chamber_b();}
	}
	cube(100,100,100);
	}
}

module tocam() {
union() {
	translate([-chamber_d - 5,0,0]) {mount();}
	impeller();
	translate([chamber_d + chamber_wall + 3,0,0]) { chamber_b(); }
	//rotate([180,0,0]) {translate([0,0,-material_h]) { chamber_t(); }}
	rotate([180,0,0]) {translate([(chamber_d + chamber_wall) * 2 + 15,0,-material_h]) { chamber_t(); }}
	}
}
	
	//ridge();
	//chamber_cavity();
	
	tocam();
	
		