include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

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

module tnut_m2(hole_offset=0) {
  module body() {
    tnut_body();
  }

  module holes() {
    rotate([90,0,0]) {
      hole(1.9,nut_depth+1,resolution);
      translate([0,0,-nut_depth]) {
        hole(m2_threaded_insert_diam,m2_threaded_insert_height*2,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module tnut_zip_tie_anchor() {
  thickness = 4;
  body_diam = 12;
  zip_tie_hole_width = 2 + tolerance;
  zip_tie_hole_height = 2 + tolerance;
  zip_tie_hole_diam = body_diam*2.5;
  zip_tie_pos_y = m3_diam/2 + wall_thickness*2 + tolerance + zip_tie_hole_width/2;

  zip_tie_dongle_length = wall_thickness*4 + zip_tie_hole_width;

  module body() {
    translate([0,0,thickness/2]) {
      linear_extrude(height=thickness,center=true,convexity=3) {
        hull() {
          translate([0,0,thickness/2]) {
            accurate_circle(body_diam,resolution);

            translate([0,zip_tie_pos_y,0]) {
              rounded_square(body_diam,zip_tie_dongle_length,2);
            }
          }
        }
      }
      translate([0,zip_tie_pos_y,thickness/2-zip_tie_hole_height/2]) {
        % cube([20,zip_tie_hole_width,zip_tie_hole_height],center=true);
      }
    }
  }

  module holes() {
    m3_countersink_screw(thickness+1);

    translate([0,zip_tie_pos_y,thickness-zip_tie_hole_height]) {
      // cube([body_diam+2,zip_tie_hole_width,zip_tie_hole_height],center=true);

      translate([0,0,-zip_tie_hole_diam/2]) {
        rotate([90,0,0]) {
          difference() {
            hole(zip_tie_hole_diam+10,zip_tie_hole_width,resolution);
            hole(zip_tie_hole_diam,zip_tie_hole_width+1,resolution);
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

module tnut_cable_anchor(cable_diam) {
  thickness = cable_diam + 1;
  body_diam = 15;
  anchor_pos_y = m3_diam/2 + extrude_width*4 + tolerance + cable_diam/2;

  anchor_length = 2*(extrude_width*4) + cable_diam;

  module body() {
    translate([0,0,thickness/2]) {
      linear_extrude(height=thickness,center=true,convexity=3) {
        hull() {
          translate([0,0,thickness/2]) {
            accurate_circle(body_diam,resolution);

            translate([0,anchor_pos_y,0]) {
              rounded_square(body_diam,anchor_length,2);
            }
          }
        }
      }
    }
  }

  module holes() {
    m3_countersink_screw(thickness+1);

    translate([0,anchor_pos_y,thickness-cable_diam/2]) {
      rotate([0,-90,0]) {
        linear_extrude(height=body_diam+2,center=true,convexity=3) {
          hull() {
            accurate_circle(cable_diam,resolution);
            translate([cable_diam/2,0,0]) {
              square([cable_diam,cable_diam],center=true);
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

module tslot_filler_profile() {
  rim_thickness = 1.9;
  inside_rim_height = 1.5;
  inside_rim_width = 11-tolerance*2;
  opening_depth = 6.1;
  bottom_width = 5;

  module body() {
    hull() {
      translate([0,-rim_thickness-wall_thickness/2-tolerance,0]) {
        square([inside_rim_width,wall_thickness],center=true);
      }
      translate([0,-opening_depth+wall_thickness/2+tolerance,0]) {
        square([bottom_width,wall_thickness],center=true);
      }
    }
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module tslot_filler(length) {
  linear_extrude(height=length,center=true,convexity=1) {
    tslot_filler_profile();
  }
}

translate([30,0,0]) {
  tslot_filler(150);
}

rotate([0,0,45]) {
  // tnut_cable_anchor(4);
  tnut_zip_tie_anchor();
}
translate([0,0,-1]) {
  % cube([20,20,2],center=true);
}
