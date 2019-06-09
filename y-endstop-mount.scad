include <./config.scad>;

module y_endstop_mount() {
  endstop_mount_thickness = mgn12_rail_height-mech_endstop_tiny_width-tolerance;
  endstop_mount_pos_z = endstop_mount_thickness/2+tolerance;

  endstop_pos_x = 4;
  endstop_pos_y = -mech_endstop_tiny_height/4;
  endstop_pos_z = endstop_mount_pos_z + endstop_mount_thickness/2 + mech_endstop_tiny_width/2 + 0.05;

  extrusion_mount_width = m3_fsc_head_diam+wall_thickness*6;
  extrusion_mount_height = endstop_mount_pos_z+endstop_mount_thickness/2+extrusion_width/2+extrusion_mount_width/2+endstop_mount_thickness/2;
  extrusion_mount_thickness = 4;

  adjustment_room = 3;
  endstop_mount_length = extrusion_mount_width+mech_endstop_tiny_height+1;

  /*
  translate([mgn12c_width/2-mech_endstop_tiny_width/2,150/2,mgn12_rail_height-mech_endstop_tiny_width/2]) {
    rotate([0,0,0]) {
      debug_axes();
      translate([0,-2,0]) {
        % mech_endstop_tiny();
      }
    }
  }
  */

  echo("y endstop screw length: ", mech_endstop_tiny_width + endstop_mount_thickness);

  module profile() {
    translate([endstop_pos_x,endstop_mount_pos_z,0]) {
      rounded_square(mech_endstop_tiny_length+1,endstop_mount_thickness,endstop_mount_thickness);
    }
    translate([extrusion_mount_thickness/2,endstop_mount_pos_z+endstop_mount_thickness/2-extrusion_mount_height/2,0]) {
      rounded_square(extrusion_mount_thickness,extrusion_mount_height,endstop_mount_thickness);
    }
    translate([extrusion_mount_thickness,tolerance,0]) {
      rotate([0,0,-90]) {
        round_corner_filler_profile(mech_endstop_tiny_length);
      }
    }
  }

  module body() {
    translate([endstop_pos_x,endstop_pos_y,endstop_pos_z]) {
      rotate([90,-90,0]) {
        % mech_endstop_tiny();
      }
    }

    difference() {
      translate([0,endstop_mount_length/2-extrusion_mount_width,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=endstop_mount_length,center=true,convexity=3) {
            profile();
          }
        }
      }
      translate([0,endstop_mount_length/2-extrusion_mount_width,0]) {
        // provide clearance for end cap
        translate([-extrusion_width/2,endstop_mount_length/2,-extrusion_width/2]) {
          clearance_x = extrusion_width+end_cap_overhang*2+tolerance*2;
          clearance_y = endstop_mount_length-extrusion_mount_width;
          clearance_z = extrusion_width+tolerance*2;
          rotate([90,0,0]) {
            rounded_cube(clearance_x,clearance_z,clearance_y*2,end_cap_overhang*2,resolution/2);
          }
        }
      }

      // endstop mounting holes
      for(x=[left,right]) {
        translate([endstop_pos_x+x*mech_endstop_mounting_hole_spacing_y/2,endstop_pos_y+mech_endstop_tiny_mounting_hole_from_top,0]) {
          hole(m2_thread_into_hole_diam,40,resolution);
        }
      }
    }
  }

  module holes() {
    translate([extrusion_mount_thickness,-extrusion_mount_width/2,-extrusion_width/2]) {
      rotate([0,90,0]) {
        m3_countersink_screw(extrusion_mount_thickness+5.5);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module to_print() {
  rotate([90,0,0]) {
    y_endstop_mount();
  }
}
