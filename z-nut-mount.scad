include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module z_nut() {
  rounded_diam = 4;

  module profile() {
    translate([z_nut_body_pos_x,z_nut_body_pos_z,0]) {
      translate([0,-z_nut_mount_height/2+z_nut_base_height/2]) {
        rounded_square(z_nut_mount_width,z_nut_base_height,m3_socket_head_diam+extrude_width*4);

        translate([-z_nut_mount_width/2+idler_shaft_body_width,z_nut_base_height/2,0]) {
          round_corner_filler_profile(rounded_diam,resolution);
        }
      }

      translate([-z_nut_mount_width/2+idler_shaft_body_width/2,0,0]) {
        rounded_square(idler_shaft_body_width,z_nut_mount_height,rounded_diam);
      }
    }
  }

  carriage_opening = mgn12c_height + tolerance;

  endstop_mount_narrow_width = abs(z_nut_body_pos_x-z_nut_mount_width/2) - mgn12c_width/2;
  endstop_mount_wide_width = abs(z_nut_body_pos_x-z_nut_mount_width/2) - extrusion_width/2 - tolerance;
  endstop_mount_height = 12;

  endstop_adjustment_screw_pos_x = left*(extrusion_width/2+mech_endstop_tiny_width/2);
  endstop_adjustment_screw_pos_y = rear*(mgn12c_surface_above_surface+extrusion_width/2)-1.2;
  endstop_adjustment_screw_pos_z = mgn12c_hole_spacing_length/2-mgn9_rail_width_allowance/2-endstop_mount_height/2;

  module body() {
    translate([0,-z_nut_mount_depth/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(convexity=3,height=z_nut_mount_depth,center=true) {
          profile();
        }
      }
    }

    // X idler bevel
    translate([x_idler_on_z_pos_x,x_idler_on_z_pos_y,x_idler_on_z_pos_z-x_idler_bevel_height]) {
      idler_shaft_dist_to_front = z_nut_mount_depth - abs(x_idler_on_z_pos_y);
      hull() {
        hole(gt2_toothed_idler_id_hole+extrude_width*2,x_idler_bevel_height*2,resolution*2);
        translate([0,0,-5]) {
          hole(idler_shaft_dist_to_front*2,10,resolution*2);
        }
      }
    }

    // endstop mount
    endstop_mount_screw_body_area = 6;
    depth = abs(endstop_adjustment_screw_pos_y) + endstop_mount_screw_body_area/2;

    translate([z_nut_body_pos_x-z_nut_mount_width/2+endstop_mount_narrow_width/2,0,endstop_adjustment_screw_pos_z]) {
      translate([0,0,0]) {
        rotate([90,0,0]) {
          rounded_cube(endstop_mount_narrow_width,endstop_mount_height,z_nut_mount_depth*2,rounded_diam);
        }
      }

      hull() {
        translate([-endstop_mount_narrow_width/2,0,0]) {
          translate([endstop_mount_wide_width/2,depth-endstop_mount_screw_body_area/2,0]) {
            rotate([90,0,0]) {
              rounded_cube(endstop_mount_wide_width,endstop_mount_height,endstop_mount_screw_body_area,rounded_diam);
            }
          }
          translate([endstop_mount_narrow_width/2,mgn12c_height+1+tolerance*2,0]) {
            rotate([90,0,0]) {
              rounded_cube(endstop_mount_narrow_width,endstop_mount_height,2,rounded_diam);
            }
          }
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      // mount nut to Z carriage
      translate([x*mgn12c_hole_spacing_width/2,-z_nut_mount_depth,-mgn12c_hole_spacing_length/2]) {
        rotate([-90,0,0]) {
          //if (countersink_all_the_things) {
          if (false) {
            echo("m3 FSC of length x ", z_nut_mount_depth+3);
            hole(m3_loose_diam,z_nut_mount_depth*2+1,resolution);
            translate([0,0,0.5]) {
              hull() {
                hole(m3_loose_diam,m3_fsc_head_diam-m3_loose_diam,resolution);
                translate([0,0,-1]) {
                  hole(m3_fsc_head_diam,2,resolution);
                }
              }
            }
          } else {
            translate([0,0,z_nut_mount_depth/2+m3_socket_head_height+0.2]) {
              hole(m3_loose_diam,z_nut_mount_depth,resolution);
            }
            hole(m3_socket_head_diam,m3_socket_head_height*2,resolution);
          }
        }
      }
    }

    // X rail
    translate([z_nut_body_pos_x-z_nut_mount_width/2+wall_thickness*2+32,front*mgn9_rail_height_allowance/2+0.05,mgn12c_hole_spacing_length/2]) {
      cube([64,mgn9_rail_height_allowance+0.1,mgn9_rail_width_allowance],center=true);
    }

    translate([0,leadscrew_pos_y,z_nut_body_pos_z-z_nut_mount_height/2]) {
      // leadscrew
      hole(leadscrew_hole_diam,z_nut_mount_height*2+1,resolution);
      // leadscrew nut
      hole(leadscrew_nut_shaft_diam,2*(leadscrew_nut_shaft_length+leadscrew_nut_flange_thickness),resolution);
      // leadscrew nut flange
      hull() {
        hole(leadscrew_nut_flange_diam,2*leadscrew_nut_flange_thickness,resolution*2);
        // make it easier to print by making the shallowest angle a bridge
        // in case we end up printing it on its front
        translate([0,leadscrew_nut_flange_diam/2-1,0]) {
          cube([10,2,2*leadscrew_nut_flange_thickness],center=true);
        }
      }

      // leadscrew mounting holes
      for(r=[0,120,240]) {
        rotate([0,0,r]) {
          translate([0,leadscrew_nut_mounting_hole_dist,0]) {
            hole(leadscrew_nut_mounting_hole_diam,2*(leadscrew_nut_mounting_hole_depth+leadscrew_nut_flange_thickness),resolution);
          }
        }
      }
    }

    // avoid in-air printing, depending on print orientation
    leadscrew_dist_to_front = z_nut_mount_depth - abs(leadscrew_pos_y);
    translate([0,-z_nut_mount_depth,z_nut_body_pos_z-z_nut_mount_height/2]) {
      nut_opening_width = 2*sqrt(pow(leadscrew_nut_flange_diam/2,2) - pow(leadscrew_dist_to_front,2)); // thank you, pythagoras!
      hull() {
        translate([0,0,0]) {
          cube([nut_opening_width+0.5,1,leadscrew_nut_flange_thickness*2],center=true);
        }
        translate([0,0,-1]) {
          cube([leadscrew_nut_flange_diam,leadscrew_dist_to_front*2,2],center=true);
        }
      }
    }

    // idler pulley shaft
    idler_shaft_hole_len = x_idler_bevel_height + x_idler_on_z_pos_z + mgn12c_hole_spacing_length/2 - m3_loose_diam - wall_thickness*2;
    echo("idler_shaft_hole_len: ", idler_shaft_hole_len);
    translate([x_idler_on_z_pos_x,x_idler_on_z_pos_y,x_idler_on_z_pos_z]) {
      hole(gt2_toothed_idler_id_hole,idler_shaft_hole_len*2,resolution);
    }

    // endstop trigger
    translate([endstop_adjustment_screw_pos_x,endstop_adjustment_screw_pos_y,endstop_adjustment_screw_pos_z]) {
      hole(1.9,50,8);
      % hole(1.9,30,8);
    }

    // carriage room
    translate([0,carriage_opening/2,0]) {
      hull() {
        cube([mgn12c_width+tolerance*2,carriage_opening,100],center=true);
        translate([0,carriage_opening/2+mgn12c_width/2,0]) {
          cube([1,mgn12c_width/2,100],center=true);
        }
      }
    }

    // extrusion_room
    translate([0,carriage_opening+20,0]) {
      cube([20+tolerance*2,40,100],center=true);
    }
  }

  difference() {
    body();
    holes();
  }

  x_rail_len = 150;

  translate([-mgn12c_hole_spacing_width/2-5+x_rail_len/2,0,mgn12c_hole_spacing_length/2]) {
    rotate([0,0,90]) {
      rotate([0,-90,0]) {
        % mgn9_rail(x_rail_len);
      }
    }
  }

  translate([0,mgn12c_surface_above_surface,+220/2-170/2-10.5]) {
    rotate([90,0,0]) {
      % mgn12_rail(170);
    }
  }
  rotate([90,0,0]) {
    % mgn12c();
  }

  translate([0,leadscrew_pos_y,220/2-170/2-1]) {
    % color("lightgrey") hole(leadscrew_diam,170,resolution);
  }

  translate([x_idler_on_z_pos_x,x_idler_on_z_pos_y,x_idler_on_z_pos_z+gt2_toothed_idler_height/2]) {
    //% color("lightgrey") gt2_toothed_idler();
  }
}

module to_print() {
  rotate([90,0,0]) {
    z_nut();
  }
}

debug = 1;
if (debug) {
  translate([0,20+mgn12c_surface_above_surface,0]) {
    rotate([0,0,90]) {
      % color("lightgrey") extrusion_2040(220);
    }
  }
  z_nut();
} else {
  to_print();
}
