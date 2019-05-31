include <./config.scad>;
include <./lib/util.scad>;

nut_depth = 5.25;
nut_width = 11;
neck_width = 6;
neck_depth = 1.75;
bevel_face_width = 5;
bevel_tip_thickness = 0.5;

module tnut_body(length=10) {
  module profile() {
    translate([0,neck_depth/2,0]) {
      square([neck_width,neck_depth],center=true);
    }

    hull() {
      translate([0,nut_depth-1,0]) {
        square([bevel_face_width,2],center=true);
      }
      translate([0,neck_depth+bevel_tip_thickness/2,0]) {
        square([nut_width,bevel_tip_thickness],center=true);
      }
    }
  }

  linear_extrude(height=length,center=true,convexity=3) {
    profile();
  }
}

module m2_tnut(hole_offset=0) {
  module body() {
    tnut_body();
  }

  module holes() {
    rotate([90,0,0]) {
      threaded_insert_height = 3;

      hole(1.9,nut_depth+1,resolution);
      translate([0,0,-nut_depth]) {
        hole(m2_threaded_insert_diam,threaded_insert_height*2,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

m2_tnut();
