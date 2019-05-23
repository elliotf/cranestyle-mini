include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;
use <./duet-wifi-mount.scad>;

// FIXME:
//   * mount for 5.5x2.5 power input female plug
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

cavity_width = end_cap_width - wall_thickness*4;
cavity_height = abs(end_cap_height - 10 - wall_thickness*2) - abs(duet_mounting_hole_offset_z) + duet_mount_bevel_height;
cavity_depth = end_cap_thickness - 0.2*6; // 6 extrusion layers thick?

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
            translate([0,0,0.5]) {
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

    rounded = rounded_diam-wall_thickness*4;
    translate([10,0,20/2-end_cap_height+cavity_height/2+wall_thickness*2]) {
      rotate([90,0,0]) {
        rounded_cube(cavity_width,cavity_height,cavity_depth*2,rounded,resolution);
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
  }

  module holes() {
    duet_port_access_hole_width = 85; // wider to be able to see the activity lights?
    duet_port_access_hole_height = 8;
    duet_port_access_hole_offset_x = 10;
    duet_port_access_hole_offset_z = duet_mounting_hole_offset_z-duet_board_thickness/2-duet_port_access_hole_height/2;

    // hole to access duet wifi ports
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
