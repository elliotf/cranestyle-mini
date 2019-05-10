include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

m3_loose_diam = m3_diam + tolerance;

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

//gt2_toothed_idler_id = 3; // walter and whosawhatsis
gt2_toothed_idler_id = 5; // use a toothed idler with more meat
gt2_toothed_idler_od = 12; // rough, on the GT2 teeth
gt2_toothed_idler_height = 9;
gt2_toothed_idler_flange_od = 18.2;
gt2_toothed_idler_flange_thickness = 1;

module gt2_toothed_idler() {
  difference() {
    union() {
      hole(gt2_toothed_idler_od, gt2_toothed_idler_height-0.05,resolution);

      for(z=[top,bottom]) {
        translate([0,0,z*(gt2_toothed_idler_height/2-gt2_toothed_idler_flange_thickness/2)]) {
          hole(gt2_toothed_idler_flange_od, gt2_toothed_idler_flange_thickness,resolution);
        }
      }
    }

    hole(gt2_toothed_idler_id,gt2_toothed_idler_height+1,resolution);
  }
}

module z_nut() {
  m3_socket_head_diam = 5.6;
  m3_socket_head_height = 3;

  rounded_diam = 4; //m3_socket_head_diam; // + wall_thickness*2;

  leadscrew_pos_y = -13;
  leadscrew_diam = 5;
  leadscrew_hole_diam = 6.5;
  leadscrew_nut_shaft_diam = 8.5;
  leadscrew_nut_shaft_length = 6.5;
  leadscrew_nut_hole_dist = 6.611;
  leadscrew_nut_flange_diam = 20;
  leadscrew_nut_flange_thickness = 3.25;
  leadscrew_nut_mounting_hole_dist = 6.35;
  leadscrew_nut_mounting_hole_diam = 2.8; // from walter's -- threading m3 into plastic?
  leadscrew_nut_mounting_hole_depth = 12.75;

  leadscrew_nut_shoulder_below_carriage_holes = 4.5;

  idler_bevel_height = 1;
  idler_shoulder_above_rail = 9.2/2+4.8;

  depth = abs(leadscrew_pos_y)+7; // copying from walter
  height = idler_shoulder_above_rail - idler_bevel_height + mgn12c_hole_spacing_length/2 + mgn12c_length/2;

  echo("height: ", height);
  body_pos_z = mgn12c_hole_spacing_length/2+idler_shoulder_above_rail-idler_bevel_height-height/2;

  // idler_pos_x = -11; // walter
  //idler_pos_x = left*(mgn12c_hole_spacing_width/2+m3_loose_diam/2+gt2_toothed_idler_id/2+wall_thickness*2);
  idler_pos_x = left*(leadscrew_diam/2+gt2_toothed_idler_flange_od/2+1);
  idler_pos_y = leadscrew_pos_y-3;
  idler_pos_z = body_pos_z + height/2 + idler_bevel_height;

  meat_on_far_side_of_idler = gt2_toothed_idler_id/2 + wall_thickness*3;
  idler_shaft_body_width = meat_on_far_side_of_idler + abs(idler_pos_x) - leadscrew_hole_diam/2 - 1.75; // fatter to be same as walter's
  width = meat_on_far_side_of_idler + abs(idler_pos_x) + mgn12c_width/2;
  //body_pos_x = mgn12c_hole_spacing_width/2 + wall_thickness + rounded_diam/2 - width/2;
  body_pos_x = mgn12c_width/2-width/2;

  mgn9_rail_width_allowance = mgn9_rail_width+tolerance;
  mgn9_rail_height_allowance = mgn9_rail_height+tolerance;

  //base_height = mgn12c_hole_spacing_length-mgn9_rail_width_allowance/2+rounded_diam/2 + leadscrew_nut_flange_thickness;
  base_height = mgn12c_hole_spacing_length/2-mgn9_rail_width_allowance/2+mgn12c_length/2;

  module profile() {
    translate([body_pos_x,body_pos_z,0]) {
      translate([0,-height/2+base_height/2]) {
        rounded_square(width,base_height,rounded_diam,resolution);

        translate([-width/2+idler_shaft_body_width,base_height/2,0]) {
          round_corner_filler_profile(rounded_diam,resolution);
        }
      }

      translate([-width/2+idler_shaft_body_width/2,0,0]) {
        rounded_square(idler_shaft_body_width,height,rounded_diam,resolution);
      }
    }
  }

  module body() {
    translate([0,-depth/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(convexity=3,height=depth,center=true) {
          profile();
        }
      }
    }

    translate([idler_pos_x,idler_pos_y,idler_pos_z-idler_bevel_height]) {
      idler_shaft_dist_to_front = depth - abs(idler_pos_y);
      hull() {
        hole(gt2_toothed_idler_id+extrude_width*2,idler_bevel_height*2,resolution*2);
        translate([0,0,-5]) {
          //resize([meat_on_far_side_of_idler*2,idler_shaft_dist_to_front*2,10]) {
            hole(idler_shaft_dist_to_front*2,10,resolution*2);
          //}
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      // mount nut to Z carriage
      translate([x*mgn12c_hole_spacing_width/2,-depth,-mgn12c_hole_spacing_length/2]) {
        rotate([90,0,0]) {
          hole(m3_loose_diam,depth*2+1,resolution);
          hole(m3_socket_head_diam,m3_socket_head_height*2,resolution);
        }
      }
    }

    // X rail
    translate([0,front*mgn9_rail_height_allowance/2+0.05,mgn12c_hole_spacing_length/2]) {
      cube([32,mgn9_rail_height_allowance+0.1,mgn9_rail_width_allowance],center=true);
    }

    translate([0,leadscrew_pos_y,body_pos_z-height/2]) {
      // leadscrew
      hole(leadscrew_hole_diam,height*2+1,resolution);
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

    // avoid thin bits of plastic..  oh who am I kidding, this is gratuitous!
    leadscrew_dist_to_front = depth - abs(leadscrew_pos_y);
    translate([0,-depth,body_pos_z-height/2]) {
      nut_opening_width = 2*sqrt(pow(leadscrew_nut_flange_diam/2,2) - pow(leadscrew_dist_to_front,2)); // thank you, pythagoras!
      hull() {
        translate([0,-1,0]) {
          cube([nut_opening_width,2,leadscrew_nut_flange_thickness*2],center=true);
        }
        translate([0,0,-1]) {
          cube([leadscrew_nut_flange_diam,leadscrew_dist_to_front*2,2],center=true);
        }
      }
    }

    // idler pulley shaft
    idler_shaft_hole_len = idler_bevel_height + idler_pos_z + mgn12c_hole_spacing_length/2 - m3_loose_diam - wall_thickness*2;
    echo("idler_shaft_hole_len: ", idler_shaft_hole_len);
    translate([idler_pos_x,idler_pos_y,idler_pos_z]) {
      hole(gt2_toothed_idler_id,idler_shaft_hole_len*2,resolution);
    }
  }

  difference() {
    body();
    holes();
  }

  translate([16,-mgn9_rail_height/2,mgn12c_hole_spacing_length/2]) {
    % color("lightgrey") cube([64,mgn9_rail_height,mgn9_rail_width],center=true);
  }

  translate([0,mgn12c_surface_above_surface-mgn12_rail_height/2,0]) {
    % color("silver") cube([mgn12_rail_width,mgn12_rail_height,100],center=true);
  }
  rotate([90,0,0]) {
    % color("darkgrey") mgn12c();
  }

  translate([0,leadscrew_pos_y,0]) {
    % color("lightgrey") hole(leadscrew_diam,100,resolution);
  }

  translate([idler_pos_x,idler_pos_y,idler_pos_z+gt2_toothed_idler_height/2]) {
    % color("lightgrey") gt2_toothed_idler();
  }
}

module to_print() {
  rotate([0,0,0]) {
    z_nut();
  }
}

debug = 0;
if (debug) {
  translate([0,20+mgn12c_surface_above_surface,0]) {
    rotate([0,0,90]) {
      % extrusion_2040(220);
    }
  }
  z_nut();

  translate([-50,-25,-mgn12c_hole_spacing_length/2]) {
    rotate([90,0,180]) {
      original_z_nut();
    }
  }
} else {
  to_print();
}
