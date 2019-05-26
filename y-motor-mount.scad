include <./config.scad>;
include <./lib/util.scad>;

//countersink_all_the_things = false;

module y_motor_mount() {
  resolution = 72;
  screw_head_hole_resolution = 36;

  /*
  */
  y_motor_side = nema14_side;
  y_motor_screw_diam = nema14_screw_diam;
  y_motor_shoulder_diam = nema14_shoulder_diam;
  y_motor_shoulder_height = nema14_shoulder_height;
  y_motor_hole_spacing = nema14_hole_spacing;
  y_motor_len = nema14_len;

  /*
  y_motor_side = nema17_side;
  y_motor_screw_diam = nema17_screw_diam;
  y_motor_shoulder_diam = nema17_shoulder_diam;
  y_motor_shoulder_height = nema17_shoulder_height;
  y_motor_hole_spacing = nema17_hole_spacing;
  y_motor_len = nema17_len;
  */

  wall_thickness = extrude_width*2;
  motor_screw_hole_diam = y_motor_screw_diam+tolerance*2;
  height = 21;

  belt_opening_angle = 90;
  motor_offset = nema14_side/2-y_motor_side/2;

  extrusion_mount_hole_spacing = y_motor_side + extrusion_mount_screw_head_diam - 2;
  extrusion_mount_head_hole_diam = extrusion_mount_screw_head_diam + tolerance*3;

  length_to_screw_into_motor = 3;

  open_side_m3_length = 5;
  closed_side_m3_length = 16;
  extrusion_anchor_screw_length = 20;

  meat_above_pulley = open_side_m3_length + m3_socket_head_height - length_to_screw_into_motor;
  echo("meat_above_pulley: ", meat_above_pulley);

  // I'm assuming this little gap is for accessing the motor's set screw while it's mounted, so that the pulley height can be adjusted.
  // Only whosawhatsis knows for sure.
  set_screw_access_width = 8;

  overall_side = y_motor_hole_spacing+rounded_diam;

  translate([0,0,50]) {
    // profile();
  }

  module profile() {
    module body() {
      hull() {
        // main body, defined by motor hole spacing
        translate([0,motor_offset,0]) {
          rounded_square(overall_side,overall_side,rounded_diam,resolution);
        }

        // mount to extrusion
        for(x=[left,right]) {
          translate([x*extrusion_mount_hole_spacing/2,0,0]) {
            rounded_diam = 6;
            rounded_square(extrusion_mount_screw_head_diam,extrusion_mount_head_hole_diam+rounded_diam+wall_thickness*2,rounded_diam,resolution);
          }
        }
      }
    }

    module holes() {
      translate([0,motor_offset,0]) {
        hull() {
          accurate_circle(y_motor_shoulder_diam+1,resolution*2);

          if (set_screw_access_width) {
            translate([0,front*y_motor_shoulder_diam/4,0]) {
              // square off area to access pulley set screw
              // so that it can bridge more cleanly
              rounded_square(set_screw_access_width+5,y_motor_shoulder_diam/2+2,4);
            }
          }
        }

        for(x=[left,right]) {
          for(y=[front,rear]) {
            translate([x*y_motor_hole_spacing/2,y*y_motor_hole_spacing/2]) {
              accurate_circle(motor_screw_hole_diam,16);
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

  translate([0,-50,0]) {
    // profile();
  }

  module body() {
    linear_extrude(height=height,convexity=3,center=true) {
      profile();
    }
  }

  module holes() {
    translate([0,motor_offset,0]) {
      // maybe for accessing the pulley set screw?
      if (set_screw_access_width) {
        set_screw_access_hole_height = height/2 - y_motor_shoulder_height;
        translate([0,-overall_side/2,height/2-y_motor_shoulder_height-set_screw_access_hole_height/2]) {
          cube([set_screw_access_width,y_motor_side,set_screw_access_hole_height],center=true);

          for(x=[left,right]) {
            translate([x*set_screw_access_width/2,0,0]) {
              rotate([0,0,45-x*45]) {
                // round_corner_filler(3,height);
              }
            }
          }
        }
      }

      // recess motor screw heads by opening, should be able to use 5mm m3
      translate([0,0,-meat_above_pulley+m3_socket_head_height]) {
        for(x=[left,right]) {
          for(y=[rear]) {
            translate([x*y_motor_hole_spacing/2,y*y_motor_hole_spacing/2]) {
              hole(m3_nut_diam+tolerance*2,height,screw_head_hole_resolution);
            }
          }
        }
      }

      // motor screw heads on the back, should be able to use 15mm m3
      translate([0,0,-closed_side_m3_length+length_to_screw_into_motor]) {
        for(x=[left,right]) {
          for(y=[front]) {
            translate([x*y_motor_hole_spacing/2,y*y_motor_hole_spacing/2]) {
              hole(m3_nut_diam+tolerance*2,height,screw_head_hole_resolution);
            }
          }
        }
      }

      // belt access
      translate([0,0,-meat_above_pulley]) {
        linear_extrude(height=height,convexity=3,center=true) {
          hull() {
            diam = 16; // both whosawhatsis and walter are using this diam. Not sure why. Maybe it's the pulley diam?
            accurate_circle(diam,resolution);

            for(x=[left,right]) {
              rotate([0,0,x*belt_opening_angle/2]) {
                translate([0,50,0]) {
                  accurate_circle(diam,resolution);
                }
              }
            }
          }
        }
      }
    }

    // extrusion mount screw heads
    for(x=[left,right]) {
      translate([x*extrusion_mount_hole_spacing/2,0,0]) {
        if (countersink_all_the_things) {
          echo("Y MOTOR MOUNT: FCS M5 x ", height+5);
          hole(m5_loose_diam,height*2,resolution);
          translate([0,0,height/2-0.5]) {
            hull() {
              hole(m5_loose_diam,m5_fsc_head_diam-m5_loose_diam,resolution);
              translate([0,0,1]) {
                hole(m5_fsc_head_diam,2,resolution);
              }
            }
          }
        } else {
          translate([0,0,height/2]) {
            translate([extrusion_mount_head_hole_diam/2,0,0]) {
              rounded_cube(extrusion_mount_head_hole_diam*2,extrusion_mount_head_hole_diam,m5_socket_head_height*2,extrusion_mount_head_hole_diam,resolution);
            }
            translate([0,0,-m5_socket_head_height-height/2-0.2]) {
              hole(m5_loose_diam+tolerance,height,resolution);
            }
            translate([0,0,-m5_socket_head_height/2]) {
              % hole(m5_nut_diam,m5_socket_head_height,resolution);
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

  % color("dimgrey") translate([0,motor_offset,height/2]) {
    rotate([180,0,0]) {
      if (y_motor_side == nema14_side) {
        motor_nema14(y_motor_length);
      } else {
        motor_nema17();
      }
    }
  }
}

module to_print() {
  rotate([180,0,0]) {
    y_motor_mount();
  }
}

debug = 0;
if (debug) {
  y_motor_mount();

  translate([0,50,0]) {
    rotate([0,0,-90]) {
      original_y_motor_mount();
    }
  }
} else {
  to_print();
}
