include <./config.scad>;
include <./lib/util.scad>;

gap_beneath_z_motor = 1;
motor_opening_side = nema14_side + 1;
motor_opening_height = nema14_len + gap_beneath_z_motor;
plate_thickness = 3;
motor_screw_hole_diam = nema14_screw_diam+2; // extra slop to adjust Z motor
motor_screw_mount_width = motor_screw_hole_diam+2*(extrude_width*6);
mount_width = nema14_hole_spacing+motor_screw_mount_width;
dist_to_extrusion = abs(leadscrew_pos_y) + mgn12c_surface_above_surface;
extrusion_width = 20;

module motor_negative() {
  translate([0,0,motor_opening_height/2]) {
    // cube([motor_opening_side,motor_opening_side,motor_opening_height],center=true);
  }

  translate([0,0,motor_opening_height]) {
    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*nema14_hole_spacing/2,y*nema14_hole_spacing/2,0]) {
          hole(motor_screw_hole_diam,40,resolution);
        }
      }
    } 

    hole(nema14_shoulder_diam+2,40,resolution*2);
  }
}

module z_motor_mount_rear() {
  extrusion_side_thickness = dist_to_extrusion - motor_opening_side/2;
  extrusion_mount_thickness = extrude_width*8;

  module body() {
    // between motor and extrusion
    translate([extrusion_mount_thickness/2,motor_opening_side/2+extrusion_side_thickness/2,motor_opening_height/2]) {
      rounded_cube(extrusion_width+extrusion_mount_thickness,extrusion_side_thickness,motor_opening_height,extrusion_mount_thickness);
    }

    // mount to screw to extrusion
    extrusion_mount_height = motor_opening_height + plate_thickness;
    overall_depth = extrusion_side_thickness+extrusion_width;
    translate([extrusion_width/2+extrusion_mount_thickness/2,motor_opening_side/2+overall_depth/2,extrusion_mount_height/2]) {
      rounded_cube(extrusion_mount_thickness,overall_depth,extrusion_mount_height,extrusion_mount_thickness);
    }

    // motor mount plate
    translate([0,0,motor_opening_height+plate_thickness/2]) {
      hull() {
        translate([extrusion_mount_thickness/2,motor_opening_side/2+extrusion_side_thickness/2,0]) {
          rounded_cube(extrusion_width+extrusion_mount_thickness,extrusion_side_thickness,plate_thickness,extrusion_mount_thickness);
        }
        for(x=[left,right]) {
          translate([x*nema14_hole_spacing/2,nema14_hole_spacing/2,0]) {
            hole(motor_screw_mount_width,plate_thickness,resolution);
          }
        }
      }
    }
  }

  module holes() {
    motor_negative();

    translate([0,dist_to_extrusion+extrusion_width/2,0]) {
      for(z=[top,bottom]) {
        translate([0,0,motor_opening_height/2+z*motor_opening_height/4]) {
          rotate([0,90,0]) {
            hole(5+tolerance,60,resolution);
          }
        }
      }
    }
  }

  color("salmon") {
    difference() {
      body();
      holes();
    }
  }

  translate([0,0,gap_beneath_z_motor+nema14_len]) {
    % color("dimgrey") motor_nema14();
  }
}

module z_motor_mount_front() {
  wall_thickness = extrude_width*2;
  rounded_diam = 6;
  extrusion_mount_screw_hole_diam = extrusion_mount_screw_diam + tolerance*2;
  extrusion_mount_head_hole_diam = extrusion_mount_screw_head_diam + tolerance*3;
  extrusion_mount_depth = extrusion_mount_head_hole_diam+wall_thickness*2;
  extrusion_mount_width = extrusion_mount_head_hole_diam+rounded_diam+wall_thickness*2;

  extrusion_anchor_shoulder_pos_z = 15;

  module body() {
    // screw meat
    translate([0,0,0]) {
      translate([0,front*(motor_opening_side/2+extrusion_mount_depth/2),motor_opening_height/2]) {
        rounded_cube(extrusion_mount_width,extrusion_mount_depth,motor_opening_height,rounded_diam,resolution);
      }
    }

    // motor mount plate
    translate([0,0,motor_opening_height+plate_thickness/2]) {
      hull() {
        translate([0,front*(motor_opening_side/2+extrusion_mount_depth/2),0]) {
          rounded_cube(extrusion_mount_width,extrusion_mount_depth,plate_thickness,rounded_diam,resolution);
        }
        for(x=[left,right]) {
          translate([x*nema14_hole_spacing/2,front*nema14_hole_spacing/2,0]) {
            hole(motor_screw_mount_width,plate_thickness,resolution);
          }
        }
      }
    }
  }

  module holes() {
    motor_negative();

    translate([0,front*(motor_opening_side/2+extrusion_mount_depth-extrusion_mount_head_hole_diam/2),extrusion_anchor_shoulder_pos_z + 40]) {
      hole(extrusion_mount_head_hole_diam,80,resolution);
      hole(extrusion_mount_screw_hole_diam,2*80,resolution);

      translate([0,front*(extrusion_mount_head_hole_diam/2),0]) {
        cube([extrusion_mount_head_hole_diam,extrusion_mount_head_hole_diam,80],center=true);
      }
    }
  }

  module bridges() {
    translate([0,front*(motor_opening_side/2+extrusion_mount_depth-extrusion_mount_head_hole_diam/2),extrusion_anchor_shoulder_pos_z-0.1]) {
      hole(extrusion_mount_screw_hole_diam+1,0.2,8);
    }
  }

  color("salmon") {
    difference() {
      body();
      holes();
    }

    bridges();
  }

  translate([0,0,gap_beneath_z_motor+nema14_len]) {
    % color("dimgrey") motor_nema14();
  }
}

module z_motor_mount_rear_to_print() {
  rotate([0,180,0]) {
    z_motor_mount_rear();
  }
}

module z_motor_mount_front_to_print() {
  rotate([180,0,0]) {
    z_motor_mount_front();
  }
}

z_motor_mount_rear();

z_motor_mount_front();
