include <./config.scad>;
include <./lib/util.scad>;

module original_y_motor_mount() {
  $fs = .2;
  $fa = 2;

  difference() {
    linear_extrude(20, convexity = 5) {
      difference() {
        hull() {
          offset(5) offset(-5) square([35, 35], center = true);
          for(y = [1, -1]) translate([0, y * 20, 0]) circle(5);
        }
        for(x = [1, -1], y = [1, -1]) translate([x * 13, y * 13, 0]) circle(3/2);
        for(y = [1, -1]) translate([0, y * 20, 0]) circle(5/2);
        circle(11.1);
      }
    }
    linear_extrude((20 - 5) * 2, center = true, convexity = 5) for(y = [1, -1]) hull() for(i = [0, 1]) translate([0, y * (20 + i * 20), 0]) circle(5);
      
    linear_extrude(8 * 2, center = true, convexity = 5) hull() for(i = [0, 1]) translate([i * 50, 0, 0]) circle(5);


    translate([0, 0, 8]) linear_extrude(20, convexity = 5) {
      for(x = [1, -1], y = [1, -1]) translate([x * 13, y * 13, 0]) circle(3/2);
      hull() for(i = [-1:1]) translate([-abs(i) * 50, i * 50, 0]) circle(7);
      translate([-20, 0, 0]) square([20, 100], center = true);
    }

    translate([0, 0, 5]) linear_extrude(20, convexity = 5) {
      for(x = [1, -1], y = [1, -1]) translate([x * 13, y * 13, 0]) circle(3);
    }
  }

  //linear_extrude(20 - 5 - .2, convexity = 5) for(y = [1, -1]) hull() for(i = [0, 1]) translate([0, y * (20 + i * 10), 0]) circle(5/2 + .5);
    
  //linear_extrude(8 - .2, convexity = 5) hull() for(i = [0, 1]) translate([10 + i * 10, 0, 0]) circle(3);
}


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

  extrusion_mount_screw_hole_diam = extrusion_mount_screw_diam + tolerance*2;
  extrusion_mount_hole_spacing = y_motor_side + extrusion_mount_screw_head_diam - 2;
  extrusion_mount_head_hole_diam = extrusion_mount_screw_head_diam + tolerance*3;

  rounded_diam = m3_nut_diam + tolerance*2 + wall_thickness*4;

  length_to_screw_into_motor = 3;
  length_to_screw_into_t_slot_nut = 5;

  open_side_m3_length = 5;
  closed_side_m3_length = 16;
  extrusion_anchor_screw_length = 20;

  extrusion_anchor_shoulder_pos_z = -height/2-length_to_screw_into_t_slot_nut+extrusion_anchor_screw_length;

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
            rounded_square(extrusion_mount_screw_hole_diam+wall_thickness*4,extrusion_mount_head_hole_diam+rounded_diam+wall_thickness*2,rounded_diam,resolution);
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

      for(x=[left,right]) {
        translate([x*extrusion_mount_hole_spacing/2,0,0]) {
          accurate_circle(extrusion_mount_screw_hole_diam,screw_head_hole_resolution);
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
        translate([0,0,height/2+y_motor_len/2]) {
          % cube([y_motor_side,y_motor_side,y_motor_len],center=true);
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
    translate([0,0,extrusion_anchor_shoulder_pos_z]) {
      for(x=[left,right]) {
        translate([x*(extrusion_mount_hole_spacing/2+extrusion_mount_head_hole_diam/2),0,0]) {
          translate([0,0,height/2]) {
            rounded_cube(extrusion_mount_head_hole_diam*2,extrusion_mount_head_hole_diam,height,extrusion_mount_head_hole_diam,resolution);
          }
          translate([-x*(extrusion_mount_head_hole_diam/2),0,m5_socket_head_height/2]) {
            % hole(m5_nut_diam,m5_socket_head_height,resolution);
          }
        }
      }
    }
  }

  module bridges() {
    translate([0,0,extrusion_anchor_shoulder_pos_z-0.1]) {
      for(x=[left,right]) {
        translate([x*(extrusion_mount_hole_spacing/2),0,0]) {
          hole(extrusion_mount_screw_hole_diam+1,0.2,8);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }

  bridges();
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
