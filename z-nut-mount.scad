include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

/*

TODO:
* Z endstop solution (if not using piezo or IR probe)
* X endstop solution (if not using walter's solution)

*/

module original_z_nut() {
  h = 13.5;

  $fs = .2;
  $fa = 2;

  difference() {
    union() {
      linear_extrude(25, convexity = 5) difference() {
        offset(-3) offset(5) offset(-2) {
          square([28, 10], center = true);
          translate([15, 0, 0]) square([10, 10], center = true);
          translate([15, 10, 0]) square([10, 30], center = true);
        }
        for(i = [1, -1]) translate([i * 10, 0, 0]) circle(3/2 + .1);
      }
      translate([0, 0, h]) rotate([-90, 0, 0]) translate([-15, 0, 0]) #*linear_extrude(25, convexity = 5) {
        circle(5);
        intersection() {
          rotate(90) translate([0, -5, 0]) square([20, 10]);
          rotate(135) translate([0, -5, 0]) square([20, 10]);
        }
        translate([-5, 0, 0]) square([10, 13.5]);
      }
    }
    translate([0, 3, 25 - h]) rotate([-90, 0, 0]) {
      // leadscrew nut shaft
      cylinder(r = 8/2 + .1, h = 20, center = true);

      // idler shaft
      translate([15, 0, 0]) {
        cylinder(r = 3/2 + .1, h = 100, center = true);
        translate([0, 0, -16]) cylinder(r = 3.25 + .1, h = 10, $fn = 6);
      }
      // leadscrew nut mounting holes
      for(i = [0:2]) rotate(i * 120 - 45) translate([0, -6.35, 2]) {
        cylinder(r = 3/2 + .2, h = 100, center = true);
        cylinder(r = 3.5, h = 20);
      }
    }
    *translate([28, 0, 22]) cube(40, center = true);
    for(i = [1, -1]) translate([i * 10, 0, -1]) cylinder(r = 3 / 2 + .1, h = 100);
    //for(i = [1, -1]) translate([i * 10, 0, 25 - 4]) cylinder(r = 3.5, h = 10);
    //for(i = [1]) translate([i * 10, 0, 2]) cylinder(r = 3.5, h = 100);
    # translate([0, 15, 25]) cube([32, 9, 14], center = true);
  }
}

module z_nut() {
  rounded_diam = 4;
  module profile() {
    translate([z_nut_body_pos_x,z_nut_body_pos_z,0]) {
      translate([0,-z_nut_mount_height/2+z_nut_base_height/2]) {
        //rounded_square(z_nut_mount_width,z_nut_base_height,m3_socket_head_diam+extrude_width*4,resolution);
        square([z_nut_mount_width,z_nut_base_height],center=true);

        translate([-z_nut_mount_width/2+idler_shaft_body_width,z_nut_base_height/2,0]) {
          round_corner_filler_profile(rounded_diam,resolution);
        }
      }

      translate([-z_nut_mount_width/2+idler_shaft_body_width/2,0,0]) {
        //rounded_square(idler_shaft_body_width,z_nut_mount_height,rounded_diam,resolution);
        square([idler_shaft_body_width,z_nut_mount_height],center=true);
      }
    }
  }

  carriage_opening = mgn12c_height + tolerance;
  z_endstop_adjustment_screw_pos_x = -20 + tolerance;
  z_endstop_adjustment_screw_pos_y = 0;

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
    hull() {
      translate([z_nut_body_pos_x-z_nut_mount_width/4,0,z_nut_body_pos_z-z_nut_mount_height/4]) {
        translate([0,carriage_opening/2+5,0]) {
          cube([z_nut_mount_width/2,carriage_opening+10,z_nut_mount_height/2],center=true);
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      // mount nut to Z carriage
      translate([x*mgn12c_hole_spacing_width/2,-z_nut_mount_depth,-mgn12c_hole_spacing_length/2]) {
        rotate([90,0,0]) {
          hole(m3_loose_diam,z_nut_mount_depth*2+1,resolution);
          hole(m3_socket_head_diam,m3_socket_head_height*2,resolution);
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
    translate([left*12.5,rear*17.45,0]) {
      # hole(1.9,50,16);
    }

    // carriage room
    translate([0,carriage_opening/2,0]) {
      cube([mgn12c_width+tolerance*2,carriage_opening,100],center=true);
    }

    // extrusion_room
    translate([0,carriage_opening+20,0]) {
      cube([20+tolerance*2,40,100],center=true);
    }
  }

  module bridges() {
    for(x=[left,right]) {
      translate([x*mgn12c_hole_spacing_width/2,-z_nut_mount_depth+m3_socket_head_height+0.1,-mgn12c_hole_spacing_length/2]) {
        rotate([90,0,0]) {
          // print on back of part for now; don't need this bridges
          hole(m3_socket_head_diam,0.2,resolution);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
  bridges();

  x_rail_len = 150;
  translate([-mgn12c_hole_spacing_width/2-5+x_rail_len/2,-mgn9_rail_height/2,mgn12c_hole_spacing_length/2]) {
    % difference() {
      color("lightgrey") cube([x_rail_len,mgn9_rail_height,mgn9_rail_width],center=true);
      for (x=[0:30]) {
        color("#444") translate([-150/2+5+20*x,-mgn9_rail_height/2,0]) {
          rotate([-90,0,0]) {
            hole(3.5,40,resolution);

            hole(m3_socket_head_diam,3.5*2,resolution);
          }
        }
      }
    }
  }

  translate([0,0,0]) {
    translate([0,mgn12c_surface_above_surface-mgn12_rail_height/2,+220/2-170/2-10.5]) {
      % color("silver") cube([mgn12_rail_width,mgn12_rail_height,170],center=true);
    }
  }
  rotate([90,0,0]) {
    % color("darkgrey") mgn12c();
  }

  translate([0,leadscrew_pos_y,220/2-170/2-1]) {
    % color("lightgrey") hole(leadscrew_diam,170,resolution);
  }

  translate([x_idler_on_z_pos_x,x_idler_on_z_pos_y,x_idler_on_z_pos_z+gt2_toothed_idler_height/2]) {
    //% color("lightgrey") gt2_toothed_idler();
  }
}

module to_print() {
  rotate([-90,0,0]) {
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

  translate([-50,-25,-mgn12c_hole_spacing_length/2]) {
    rotate([90,0,180]) {
      // original_z_nut();
    }
  }
} else {
  to_print();
}
