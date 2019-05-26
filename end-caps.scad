include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;
use <./duet-wifi-mount.scad>;

// FIXME/TODO:
//   * holes for wires
//     * extruder motor
//     * X motor
//     * Y motor
//     * Z motor
//     * bed power/thermistor
//     * X carriage bundle
//   * anchors for wires

y_idler_screw_hole_length = 28;
duet_mounting_hole_offset_y = end_cap_thickness-duet_hole_from_end-(duet_overall_length-duet_length); // mounting hole relative to extrusion edge
duet_mounting_hole_offset_z = -20/2-duet_mount_thickness-duet_mount_bevel_height-tolerance;

end_cap_rim_width = wall_thickness*2;

cavity_width = end_cap_width - end_cap_rim_width*2;
cavity_height = abs(end_cap_height - 10 - end_cap_rim_width) - abs(duet_mounting_hole_offset_z) + duet_mount_bevel_height;
cavity_depth = end_cap_thickness - 0.2*6; // 6 extrusion layers 0.2 thick, or 4 extrusion layers 0.3 thick -- enough?
cavity_rounded = rounded_diam-(end_cap_width-cavity_width);

module end_cap(end=front) {
  y_idler_screw_shoulder_pos_z = 20/2+y_idler_dist_z_from_extrusion+gt2_toothed_idler_height;
  module body() {
    translate([-40+end_cap_extrusion_width_to_cover/2,front*end_cap_thickness/2,-end_cap_height/2+20/2]) {
      rotate([90,0,0]) {
        rounded_cube(end_cap_width,end_cap_height,end_cap_thickness,end_cap_overhang*2);
      }
    }

    if (y_idler_in_endcap) {
      translate([y_idler_pos_x,y_idler_dist_y_from_extrusion,20/2]) {
        hull() {
          hole(m5_thread_into_hole_diam+extrude_width*2,y_idler_dist_z_from_extrusion*2,resolution);
          translate([0,0,-1]) {
            hole(end_cap_thickness,2,resolution);
          }
        }
      }
    }
  }

  module holes() {
    // idler hole
    if (y_idler_in_endcap) {
      translate([-40+50,-end_cap_thickness/2,y_idler_screw_shoulder_pos_z-y_idler_screw_hole_length/2]) {
        hole(m5_thread_into_hole_diam,y_idler_screw_hole_length+1,resolution);
      }
    }
    
    // end_cap_extrusion mounting holes
    for(x=[10,30,70,90]) {
      translate([-40+x,-end_cap_thickness,0]) {
        rotate([-90,0,0]) {
          if (countersink_all_the_things) {
            echo("EXTRUSION MOTOR MOUNT: FCS M5 x ", end_cap_thickness+5);
            translate([0,0,0.75]) {
              hole(m5_loose_diam,end_cap_thickness*2+1,resolution);

              // countersink heads
              hull() {
                hole(m5_loose_diam,m5_fsc_head_diam-m5_loose_diam,resolution);
                translate([0,0,-1]) {
                  hole(m5_fsc_head_diam,2,resolution);
                }
              }
            }
          } else {
            translate([0,0,end_cap_thickness/2+m5_socket_head_height+0.2]) {
              hole(m5_loose_diam,end_cap_thickness,resolution);
            }
            hole(m5_nut_diam+tolerance,m5_socket_head_height*2,resolution);
          }
        }
      }
    }

    translate([10,0,20/2-end_cap_height+cavity_height/2+wall_thickness*2]) {
      rotate([90,0,0]) {
        rounded_cube(cavity_width,cavity_height,cavity_depth*2,cavity_rounded,resolution);
      }
    }

    // trim the bottom to be able to see better
    translate([0,0,-10-end_cap_height/2]) {
      // cube([end_cap_width*2,end_cap_thickness*4,25],center=true);
    }
  }

  difference() {
    body();
    holes();
  }
}

end_cap();

module end_cap_front() {
  end_cap(front);
}

module end_cap_rear() {
  duet_port_access_hole_width = 85; // wider to be able to see the activity lights?
  duet_port_access_hole_height = 8;
  duet_port_access_hole_offset_x = 10;
  duet_port_access_hole_offset_z = duet_mounting_hole_offset_z-duet_board_thickness/2-duet_port_access_hole_height/2;

  power_plug_hole_diam = 11;
  power_plug_bevel_height = 2;
  power_plug_bevel_id = 13;
  power_plug_bevel_od = 13;
  power_plug_body_diameter = power_plug_hole_diam+extrude_width*8*2;
  power_plug_area_thickness = 4;

  power_plug_pos_x = 10+left*(end_cap_width/2-end_cap_rim_width-power_plug_body_diameter/2);
  power_plug_pos_y = end_cap_thickness;
  power_plug_pos_z = 10-end_cap_height+end_cap_rim_width+power_plug_body_diameter/2;

  wire_hole_wall_depth = 3;
  wire_hole_wall_thickness = wall_thickness*2;
  wire_hole_rounded_diam = 4;
  wire_hole_width = 30;
  wire_hole_height = 6.5;
  wire_hole_pos_x = power_plug_pos_x + power_plug_body_diameter /2 + 8 + wire_hole_width/2;
  wire_hole_pos_y = end_cap_thickness-wire_hole_wall_depth/2;
  wire_hole_pos_z = power_plug_pos_z;

  module body() {
    mirror([0,1,0]) {
      end_cap();
    }

    mount_body_diam = m3_thread_into_hole_diam+wall_thickness*4;

    for(x=[left,right]) {
      translate([10+x*duet_hole_spacing_x/2,0,duet_mounting_hole_offset_z+duet_mount_bevel_height+duet_mount_thickness/2]) {
        hull() {
          cube([mount_body_diam,1,duet_mount_thickness],center=true);
          translate([0,duet_mounting_hole_offset_y,0]) {
            hole(mount_body_diam,duet_mount_thickness,resolution);
          }
        }

        translate([0,duet_mounting_hole_offset_y,0]) {
          hull() {
            hole(mount_body_diam,duet_mount_thickness,resolution);
            translate([0,0,-duet_mount_bevel_height/2-duet_mount_thickness/2]) {
              hole(m3_thread_into_hole_diam+extrude_width*2,duet_mount_bevel_height,resolution);
            }
          }
        }
      }
    }

    // power plug area
    translate([power_plug_pos_x,power_plug_pos_y,power_plug_pos_z]) {
      translate([0,-power_plug_bevel_height/2-power_plug_area_thickness/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=power_plug_area_thickness+power_plug_bevel_height,center=true,convexity=3) {
            difference() {
              square([power_plug_body_diameter,power_plug_body_diameter],center=true);
              translate([power_plug_body_diameter/2,power_plug_body_diameter/2]) {
                rotate([0,0,180]) {
                  round_corner_filler_profile(power_plug_body_diameter,resolution);
                }
              }
            }
            translate([-power_plug_body_diameter/2,power_plug_body_diameter/2]) {
              round_corner_filler_profile(cavity_rounded,resolution);
            }
            translate([power_plug_body_diameter/2,-power_plug_body_diameter/2]) {
              round_corner_filler_profile(cavity_rounded,resolution);
            }
          }
        }
      }
    }

    // wire holes for X stepper, extruder stepper, maybe Y endstop
    translate([wire_hole_pos_x,wire_hole_pos_y,wire_hole_pos_z]) {
      rotate([90,0,0]) {
        rounded_cube(wire_hole_width+wire_hole_wall_thickness*2,wire_hole_height+wire_hole_wall_thickness*2,wire_hole_wall_depth,wire_hole_rounded_diam+wire_hole_wall_thickness*2);
      }
    }
  }

  module holes() {
    // hole to access duet wifi ports, maybe too small for a usb cable, but useful for microSD card access in a bind
    translate([duet_port_access_hole_offset_x,0,duet_port_access_hole_offset_z]) {
      rotate([90,0,0]) {
        rounded_cube(duet_port_access_hole_width,duet_port_access_hole_height,end_cap_thickness*3,4,resolution);
      }
    }

    for(x=[left,right]) {
      translate([10+x*duet_hole_spacing_x/2,duet_mounting_hole_offset_y,duet_mounting_hole_offset_z]) {
        hole(m3_thread_into_hole_diam,2*(duet_mount_bevel_height+duet_mount_thickness)-extrude_width*4,resolution);
      }
    }

    translate([power_plug_pos_x,power_plug_pos_y,power_plug_pos_z]) {
      rotate([-90,0,0]) {
        translate([0,0,-end_cap_thickness/2-power_plug_bevel_height-0.2]) {
          hole(power_plug_hole_diam,end_cap_thickness,resolution);
        }

        hull() {
          hole(power_plug_bevel_id,power_plug_bevel_height*2,resolution);
          translate([0,0,1]) {
            hole(power_plug_bevel_od,2,resolution);
          }
        }
      }
    }

    translate([wire_hole_pos_x,wire_hole_pos_y,wire_hole_pos_z]) {
      rotate([90,0,0]) {
        rounded_cube(wire_hole_width,wire_hole_height,wire_hole_wall_depth+1,wire_hole_rounded_diam);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module end_cap_assembly() {
  translate([0,0,-20/2]) {
    translate([0,150/2,0]) {
      end_cap_rear();
    }
    translate([0,-150/2,0]) {
      end_cap_front();
    }

    // duet wifi
    translate([10,150/2-duet_hole_spacing_y/2+duet_mounting_hole_offset_y,duet_mounting_hole_offset_z-duet_board_thickness/2]) {
      rotate([180,0,0]) {
        color("#3d526d") duet_wifi();
      }

      translate([0,-duet_hole_spacing_y/2,duet_mount_thickness+duet_mount_bevel_height]) {
        mirror([0,1,0]) {
          long_clamp();
        }
      }
    }
  }
}
