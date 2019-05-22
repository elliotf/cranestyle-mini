include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;
use <./duet-wifi-mount.scad>;

module original_end_caps() {
  rows = 4;

  $fs = .2;
  $fa = 2;

  for(end = [0, 1]) mirror([0, end, 0]) translate([0, 14, 0]) difference() {
    union() {
      linear_extrude(6, convexity = 5) offset(1) offset(-1) union() {
        square([20 * rows, 20], center = true);
        for(i = [-1, 1]) translate([end ? 0 : i * 10 * rows, -10]) difference() {
          circle(5);
          circle(3);
        }
        translate([10 * rows - 15, 0, 0]) square([15, 15]);
        if(!end) translate([-10 * rows, 0, 0]) square([20, 10 + 15 * 2]);
      }
      translate([10, 0, 3]) rotate([-90, 0, 0]) intersection() {
        cylinder(r = 3 * sqrt(2), h = 100);
        cube([20, 6, 22], center = true);
      }
    }
    translate([10, 0, 3]) rotate([90, 0, 0]) {
      cylinder(r = 3 / 2 / cos(180 / 6), h = 100, center = true, $fn = 6);
      cube([6, 10, 3.5], center = true);
    }
    for(i = [.5:rows]) if(i != 2.5) translate([-rows * 10 + i * 20, 0, 0]) difference() {
      union() {
        cylinder(r = 5/2, h = 20, center = true);
        cylinder(r = 5, h = 6, center = true);
      }
      cylinder(r = 5/2 + .5, h = 5.6, center = true);
    }
    for(i = [.5:2]) translate([-rows * 10 + 10, 10 + 15 * i, 0]) difference() {
      union() {
        cylinder(r = 5/2, h = 20, center = true);
        cylinder(r = 5, h = 6, center = true);
      }
      cylinder(r = 5/2 + .5, h = 5.6, center = true);
    }
  }
}

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
      translate([-40+x,-end_cap_thickness+0.5,0]) {
        rotate([-90,0,0]) {
          hole(m5_loose_diam,end_cap_thickness*2+1,resolution);

          // countersink heads
          hull() {
            hole(m5_loose_diam,m5_fsc_head_diam-m5_loose_diam,resolution);
            translate([0,0,-1]) {
              hole(m5_fsc_head_diam,2,resolution);
            }
          }
        }
      }
    }

    // hollow out part of part.  Does not improve/reduce print time.  :(
    /*
    for (x=[left,right]) {
      width = (end_cap_width-m5_thread_into_hole_diam)/2 - wall_thickness*4;
      height = end_cap_height-20 - wall_thickness*2;
      depth = end_cap_thickness - 0.6*2;
      rounded = rounded_diam-wall_thickness*4;
      translate([10+x*(end_cap_width/2-width/2-wall_thickness*2),0,20/2-end_cap_height+height/2+wall_thickness*2]) {
        rotate([90,0,0]) {
          rounded_cube(width,height,depth*2,rounded,resolution);
        }
      }
    }
    */
    union() {
      rounded = rounded_diam-wall_thickness*4;
      translate([10,0,20/2-end_cap_height+cavity_height/2+wall_thickness*2]) {
        rotate([90,0,0]) {
          rounded_cube(cavity_width,cavity_height,cavity_depth*2,rounded,resolution);
        }
      }
    }

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
