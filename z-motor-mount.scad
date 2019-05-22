include <./config.scad>;
include <./lib/util.scad>;

gap_beneath_z_motor = 1;
motor_opening_side = nema14_side + 1;
plate_thickness = 4;
motor_screw_hole_diam = nema14_screw_diam+2; // extra slop to adjust Z motor
motor_screw_mount_width = motor_screw_hole_diam+2*(extrude_width*8);
dist_to_extrusion = abs(leadscrew_pos_y) + mgn12c_surface_above_surface;
extrusion_width = 20;

z_motor_mount_rear_height = 33;

side_support_thickness = extrude_width*8;
between_motor_and_extrusion_width = motor_opening_side/2+extrusion_width/2+side_support_thickness;
extrusion_mount_thickness = between_motor_and_extrusion_width-extrusion_width;

overall_height = z_motor_mount_rear_height + plate_thickness;

module z_motor_mount() {
  extrusion_side_thickness = dist_to_extrusion - motor_opening_side/2;

  module body_profile() {
    translate([left*(between_motor_and_extrusion_width/2-extrusion_width/2),motor_opening_side/2+extrusion_side_thickness/2,0]) {
      rounded_square(between_motor_and_extrusion_width,extrusion_side_thickness,side_support_thickness);
    }
    side_support_length = motor_opening_side + extrusion_side_thickness;
    translate([left*(motor_opening_side/2+side_support_thickness/2),front*(motor_opening_side/2-side_support_length/2),0]) {
      rounded_square(side_support_thickness,side_support_length,side_support_thickness);
    }
  }

  module plate_profile() {
    module body() {
      coords = [
        [right*nema14_hole_spacing/2,rear*nema14_hole_spacing/2],
        [left*nema14_hole_spacing/2,front*nema14_hole_spacing/2],
      ];

      hull() {
        for(coord=coords) {
          translate(coord) {
            accurate_circle(motor_screw_mount_width,resolution);
          }
        }
        body_profile();
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

      accurate_circle(nema14_shoulder_diam+2,resolution*2);

      rotate([0,0,-45]) {
        translate([motor_screw_mount_width/2,0,0]) {
          square([motor_screw_mount_width,nema14_shoulder_diam+2],center=true);

          // round out the area by the mounting holes
          for(y=[front,rear]) {
            translate([0,y*(nema14_shoulder_diam+2)/2,0]) {
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
    // between motor and extrusion
    translate([0,0,-z_motor_mount_rear_height/2]) {
      linear_extrude(height=z_motor_mount_rear_height,center=true,convexity=3) {
        body_profile();
      }
    }

    // motor hole plate
    translate([0,0,plate_thickness/2]) {
      linear_extrude(height=plate_thickness,center=true,convexity=3) {
        plate_profile();
      }
    }

    // mount to screw to extrusion
    overall_depth = extrusion_side_thickness+extrusion_width;
    translate([left*(extrusion_width/2+extrusion_mount_thickness/2),motor_opening_side/2+overall_depth/2,-z_motor_mount_rear_height/2+plate_thickness/2]) {
      rounded_cube(extrusion_mount_thickness,overall_depth,z_motor_mount_rear_height+plate_thickness,side_support_thickness);
    }

  }

  module holes() {
    // holes to mount to extrusion
    for(z=[top,bottom]) {
      translate([left*(extrusion_width/2+extrusion_mount_thickness),dist_to_extrusion+extrusion_width/2,plate_thickness-overall_height/2+z*overall_height/4]) {
        m5_screw_length = extrusion_mount_thickness-m5_socket_head_height+5;
        echo("m5_screw_length for mounting Z motor: ", m5_screw_length);
        rotate([0,90,0]) {
          hole(5+tolerance,60,resolution);
          // FIXME: use countersunk screws because they're so pretty!
          hole(m5_nut_diam+tolerance,m5_socket_head_height*2,resolution);
        }
      }
    }

    // angled opening
    hull() {
      translate([0,front*motor_opening_side,-nema14_len/2]) {
        cube([motor_opening_side*2,motor_opening_side,nema14_len],center=true);
      }
      translate([0,0,-z_motor_mount_rear_height-1]) {
        cube([motor_opening_side*2,motor_opening_side,2],center=true);
      }
    }
  }

  color("salmon") {
    difference() {
      body();
      holes();
    }
  }
}

module to_print() {
  rotate([0,180,0]) {
    z_motor_mount();
  }
}

module z_motor_assembly() {
  z_motor_mount();

  % color("dimgrey") motor_nema14();
}

z_motor_assembly();
