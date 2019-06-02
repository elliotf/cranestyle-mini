include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

walter_bracket_pivot_height = 8;

bracket_arm_swivel_clearance = 0.25;
bracket_arm_spacing = 42.5;
bracket_divot_angle = 28.5;
bracket_divot_diam = 12;
bracket_divot_depth = 3;


// swivel_divot_angle = 30; // what walter has; a purposeful difference from bracket's angle?
swivel_divot_angle = bracket_divot_angle;
swivel_divot_diam = 12.2;
swivel_divot_depth = 3;
swivel_bearing_recess_height = 1;
swivel_height = swivel_divot_diam+2+2*(swivel_bearing_recess_height);

swivel_bearing_od = 16; // 625
swivel_bearing_id = 5; // 625
swivel_bearing_height = 5; // 625

swivel_bearing_hole = swivel_bearing_od + tolerance*2;

// FIXME: make numbers based on:
// * should be influenced by the height of a captive nut
// * should be influenced by the length of the motor and available screw lengths
m5_bolt_head_height = m5_socket_head_height;
motor_plate_thickness = 4;
motor_plate_clearance_bevel_height = 5;
motor_plate_pivot_screw_diam = swivel_bearing_id+tolerance;
motor_plate_screw_hole_recess_height = 1; // FIXME: be based on length of motor and available screw lengths

module divot(large_diam,depth,angle) {
  small_diam = large_diam - 2*(depth*(tan(angle)));

  hull() {
    hole(swivel_divot_diam,0.001,resolution);
    hole(small_diam,depth*2,resolution);
  }
}

module extruder_motor_plate() {
  rounded_diam = nema17_side - nema17_hole_spacing;

  module body() {
    rounded_cube(nema17_side,nema17_side,motor_plate_thickness,rounded_diam);

    hull() {
      bevel_smaller_diam = motor_plate_pivot_screw_diam+extrude_width*2*2;
      bevel_larger_diam = bevel_smaller_diam + motor_plate_clearance_bevel_height*2;

      hole(bevel_larger_diam,motor_plate_thickness,resolution);
      translate([0,0,bottom*(motor_plate_thickness/2+motor_plate_clearance_bevel_height-1)]) {
        hole(bevel_smaller_diam,2,resolution);
      }
    }
  }

  module holes() {
    translate([0,0,motor_plate_thickness/2]) {
      hole(m5_nut_diam,m5_bolt_head_height,6);

      translate([0,0,-m5_bolt_head_height/2-0.3-25/2]) {
        hole(motor_plate_pivot_screw_diam,25,resolution);
      }
    }

    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*(nema17_hole_spacing/2),y*(nema17_hole_spacing/2),bottom*motor_plate_thickness/2]) {
          hole(m3_socket_head_diam,motor_plate_screw_hole_recess_height*2,resolution);
          hole(m3_loose_diam,motor_plate_thickness*3,resolution);
        }
      }
    }
  }

  m5_nut_height = 6;
  echo("Need an M5 screw/bolt with a thread length of : ", motor_plate_thickness + motor_plate_clearance_bevel_height - m5_bolt_head_height + swivel_height + m5_nut_height);

  difference() {
    body();
    holes();
  }
}

module walter_extruder_motor_plate() {
  color("lightblue") import("./walter/Dual Axis Extruder Mount - Motor Plate.stl");
}

module extruder_swivel() {
  extra_meat = extrude_width*4*2;
  swivel_width = bracket_arm_spacing-bracket_arm_swivel_clearance*2;
  swivel_depth = max(swivel_bearing_hole,swivel_divot_diam) + extra_meat;

  module profile() {
    rounded_square(swivel_width,swivel_depth,extra_meat);
  }

  module body() {
    linear_extrude(height=swivel_height,center=true,convexity=3) {
      profile();
    }

    translate([0,0,30]) {
    }
  }

  module holes() {
    for(x=[left,right]) {
      translate([x*swivel_width/2,0,0]) {
        rotate([0,90,0]) {
          divot(swivel_divot_diam,swivel_divot_depth,swivel_divot_angle);
        }
      }
    }

    bearing_bevel_height = 1;
    bearing_bevel_id = swivel_bearing_hole-bearing_bevel_height*2;
    hole(bearing_bevel_id,swivel_height*2,resolution);
    for(z=[top,bottom]) {
      translate([0,0,z*(swivel_height/2-swivel_bearing_recess_height)]) {
        hull() {
          hole(swivel_bearing_hole,swivel_bearing_height*2,resolution);
          hole(bearing_bevel_id,(bearing_bevel_height+swivel_bearing_height)*2,resolution);
        }
        translate([0,0,-z*(swivel_bearing_height/2)]) {
          % color("silver",0.5) {
            difference() {
              hole(swivel_bearing_od,swivel_bearing_height,resolution);
              hole(swivel_bearing_id,swivel_bearing_height+1,resolution);
            }
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module walter_extruder_swivel() {
  color("lightblue") import("./walter/Dual Axis Extruder Mount - Swivel.stl");
}

module walter_extruder_bracket() {
  color("#56e") import("./walter/Dual Axis Extruder Mount - Bracket.stl");
}

module walter_extruder_assembly() {
  compensation_angle = 115-90;
  translate([0,37.5,-23.25-mgn9_rail_width/2]) {
    rotate([0,0,180]) {
      rotate([compensation_angle,0,0]) {
        walter_extruder_bracket();

        translate([0,0,0]) {
          rotate([-compensation_angle,0,0]) {
            walter_extruder_swivel();

            translate([0,0,-19]) {
              walter_extruder_motor_plate();

              translate([0,0,nema17_len+40]) {
                color("dimgrey") motor_nema17();
              }
            }
          }
        }
      }
    }
  }
}

module extruder_assembly() {
  compensation_angle = 115-90;

  translate([0,37.5,-23.25-mgn9_rail_width/2]) {
    rotate([0,0,180]) {
      rotate([compensation_angle,0,0]) {
        walter_extruder_bracket();

        translate([0,0,walter_bracket_pivot_height]) {
          rotate([-compensation_angle,0,0]) {
            extruder_swivel();

            translate([0,0,swivel_height/2+motor_plate_clearance_bevel_height+motor_plate_thickness/2-swivel_bearing_recess_height]) {
              extruder_motor_plate();

              translate([0,0,nema17_len + motor_plate_thickness/2 + 0.5]) {
                color("dimgrey") motor_nema17();
              }
            }
          }
        }
      }
    }
  }
}

module extruder_motor_plate_to_print() {
  rotate([180,0,0]) {
    extruder_motor_plate();
  }
}
module extruder_swivel_to_print() {
  extruder_swivel();
}

module extruder_bracket_to_print() {
  walter_extruder_bracket();
}

translate([-bracket_arm_spacing/2-10,0,0]) {
  translate([0,50,0]) {
    walter_extruder_assembly();
  }

  //rotate([180,0,0]) {
    walter_extruder_motor_plate();
  //}
}

translate([bracket_arm_spacing/2+10,0,0]) {
  translate([0,50,0]) {
    extruder_assembly();
  }

  //rotate([180,0,0]) {
    extruder_motor_plate();
  //}
}
