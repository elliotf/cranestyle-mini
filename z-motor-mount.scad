include <./config.scad>;
include <./lib/util.scad>;

adjustment_room_total = 3;
motor_opening_side = nema14_side + adjustment_room_total;
plate_thickness = 4;
motor_screw_hole_diam = nema14_screw_diam+adjustment_room_total; // extra slop to adjust Z motor
motor_screw_mount_width = motor_screw_hole_diam+2*(extrude_width*8);
shoulder_opening_diam = sqrt(2*pow(nema14_hole_spacing,2)) - motor_screw_mount_width;
dist_to_extrusion = abs(leadscrew_pos_y) + mgn12c_surface_above_surface;

z_motor_mount_rear_height = 32; // nema14 motor with leadscrew body is 33.5

side_support_thickness = extrude_width*8;
side_support_length = motor_opening_side + side_support_thickness;

side_support_pos_x = left*(motor_opening_side/2+side_support_thickness/2);
side_support_pos_y = -motor_opening_side/2+side_support_length/2;

extrusion_side_thickness = min(dist_to_extrusion - motor_opening_side/2 - side_support_thickness,extrude_width*8);

extrusion_opening_width = extrusion_width+tolerance;

main_width = max(nema14_hole_spacing+motor_screw_mount_width,motor_opening_side);

between_motor_and_extrusion_width = main_width/2+motor_opening_side/2+side_support_thickness;
extrusion_mount_thickness = (main_width-extrusion_opening_width)/2;
extrusion_mount_overall_depth = dist_to_extrusion+extrusion_width-motor_opening_side/2;

overall_height = z_motor_mount_rear_height + plate_thickness;

bed_side_extrusion_mount_thickness = motor_opening_side/2 - extrusion_width/2;

module z_motor_mount() {
  module plate_profile() {
    module body() {
      coords = [
        [right*nema14_hole_spacing/2,rear*nema14_hole_spacing/2],
        [left*nema14_hole_spacing/2,front*nema14_hole_spacing/2],
      ];

      hull() {
        translate([left*(motor_opening_side/2+side_support_thickness-between_motor_and_extrusion_width/2),motor_opening_side/2+extrusion_side_thickness/2,0]) {
          rounded_square(between_motor_and_extrusion_width,extrusion_side_thickness,side_support_thickness);
        }
        translate([side_support_pos_x,side_support_pos_y,0]) {
          rounded_square(side_support_thickness,side_support_length,side_support_thickness);
        }
        for(coord=coords) {
          translate(coord) {
            accurate_circle(motor_screw_mount_width,resolution);
          }
        }
      }

      for(x=[left,right]) {
        translate([x*(main_width/2-extrusion_mount_thickness/2),motor_opening_side/2+extrusion_mount_overall_depth/2,0]) {
          rounded_square(extrusion_mount_thickness,extrusion_mount_overall_depth,side_support_thickness);
        }

        translate([x*(extrusion_opening_width/2),motor_opening_side/2+extrusion_side_thickness,0]) {
          rotate([0,0,45+x*45]) {
            round_corner_filler_profile(side_support_thickness);
          }
        }
      }

      translate([left*(main_width/2),motor_opening_side/2+extrusion_side_thickness,0]) {
        rotate([0,0,90]) {
          round_corner_filler_profile(side_support_thickness);
        }
      }
    }

    module holes() {
      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([x*nema14_hole_spacing/2,y*nema14_hole_spacing/2,0]) {
            accurate_circle(motor_screw_hole_diam,resolution);
          }
        }
      } 

      accurate_circle(shoulder_opening_diam,resolution*2);

      rotate([0,0,-45]) {
        translate([motor_screw_mount_width/2,0,0]) {
          square([motor_screw_mount_width,shoulder_opening_diam],center=true);

          // round out the area by the mounting holes
          for(y=[front,rear]) {
            translate([0,y*(shoulder_opening_diam)/2,0]) {
              rotate([0,0,135-y*45]) {
                round_corner_filler_profile(motor_screw_mount_width);
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

  module body() {
    // motor hole plate
    translate([0,0,plate_thickness-overall_height/2]) {
      linear_extrude(height=overall_height,center=true,convexity=3) {
        plate_profile();
      }
    }
  }

  module holes() {
    // holes to mount to extrusion
    for(x=[left,right]) {
      for(z=[top,bottom]) {
        translate([x*(main_width/2),dist_to_extrusion+extrusion_width/2,plate_thickness-overall_height/2+z*overall_height/4]) {
          rotate([0,90,0]) {
            if (countersink_all_the_things) {
              m5_countersink_screw(16);
              echo("Z MOTOR MOUNT: FCS M5 x ", extrusion_mount_thickness+5);
            } else {
              echo("m5 screw length for mounting Z motor (socket head): ", extrusion_mount_thickness-m5_socket_head_height+5);
              hole(5+tolerance,60,resolution);
              hole(m5_nut_diam+tolerance,m5_socket_head_height*2,resolution);
            }
          }
        }
      }
    }

    translate([0,-motor_opening_side/2,-overall_height]) {
      cube([motor_opening_side*2,motor_opening_side*2,overall_height*2],center=true);
    }

    translate([right*(main_width/2),motor_opening_side/2,-overall_height/2]) {
      rotate([0,0,90]) {
        round_corner_filler(side_support_thickness,overall_height);
      }
    }
  }

  module bridges() {
    // side support arm
    translate([side_support_pos_x,0,0]) {
      hull() {
        translate([0,side_support_pos_y,plate_thickness/2]) {
          rounded_cube(side_support_thickness,side_support_length,plate_thickness,side_support_thickness);
        }
        translate([0,motor_opening_side/2,-z_motor_mount_rear_height+1]) {
          rounded_cube(side_support_thickness,side_support_thickness,2,side_support_thickness);
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
  rotate([0,180,0]) {
    z_motor_mount();
  }
}

module z_motor_assembly() {
  z_motor_mount();

  % color("dimgrey") motor_nema14(leadscrew_motor_length);
}

z_motor_assembly();
