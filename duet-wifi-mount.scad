include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module clamp_adapter() {
  // use thermal transfer pad strips (and maybe kapton?) behind the duet wifi
  // and clamp the it to an aluminum extrusion channel
  // in an attempt to use the aluminum extrusion as a heatsink
  // maybe use this thermal pad, but not sure about thickness to use: https://www.amazon.com/dp/B07BKX3YCV
  //   want it thick enough to avoid shorting pins, but not sure how well the thicker pad will transfer heat
  //
  // walter is using aluminum block spacers
}

cross_brace_width = m3_loose_diam+wall_thickness*4;
thickness = 2;
duet_hole_dist_from_end = (duet_length - duet_hole_spacing_y)/2;
hole_body_diam = 3+wall_thickness*4;
bevel_height = 2;

module long_clamp() {
  module body() {
    translate([0,duet_hole_dist_from_end+cross_brace_width/2,0]) {
      rounded_cube(duet_hole_spacing_x+hole_body_diam,cross_brace_width,thickness,cross_brace_width);
    }
    for(x=[left,right]) {
      translate([x*duet_hole_spacing_x/2,0,0]) {
        hull() {
          hole(hole_body_diam,thickness,resolution);
          translate([0,0,-thickness/2-bevel_height/2]) {
            hole(3+extrude_width*2,bevel_height,resolution);
          }
        }
        translate([0,cross_brace_width/2,0]) {
          cube([hole_body_diam,cross_brace_width,thickness],center=true);
          translate([-x*hole_body_diam/2,0,0]) {
            rotate([0,0,225+x*-45]) {
              round_corner_filler(cross_brace_width,thickness);
            }
          }
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      translate([x*duet_hole_spacing_x/2,0,0]) {
        hole(3,(thickness+bevel_height)*4,resolution);
      }
    }

    for(x=[10,30,70,90]) {
      translate([-50+x,duet_hole_dist_from_end+cross_brace_width/2,0]) {
        hole(m3_loose_diam,thickness+1,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module duet_assembly() {
  for (y=[front,rear]) {
    mirror([0,1-y,0]) {
      translate([0,duet_hole_spacing_y/2,-thickness/2]) {
        long_clamp();
      }
    }
  }
  translate([0,0,-thickness-bevel_height-duet_board_thickness/2]) {
    rotate([180,0,0]) {
      % color("lightblue") duet_wifi();
    }
  }
}

translate([-duet_width/2+80/2,0,thickness/2+10]) {
  rotate([90,0,0]) {
    % extrusion_2080(150);
  }
}

duet_assembly();

module to_print() {
  rotate([180,0,0]) {
    long_clamp();
  }
}
