include <./config.scad>;
include <./lib/util.scad>;

module bmg_spacer() {
  thickness = 3; // the mount that Bondtech sells is 3mm, so...
  screw_hole_diam = nema17_screw_diam+1;
  rounded_diam = screw_hole_diam + wall_thickness*4;

  module profile() {
    module body() {
      hull() {
        for(x=[left,right]) {
          for(y=[front,rear]) {
            translate([x*nema17_hole_spacing/2,y*nema17_hole_spacing/2]) {
              accurate_circle(rounded_diam,resolution);
            }
          }
        }
      }
    }

    module holes() {
      accurate_circle(nema17_shoulder_diam+1,36);

      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([x*nema17_hole_spacing/2,y*nema17_hole_spacing/2]) {
            accurate_circle(nema17_screw_diam+1,resolution);
          }
        }
      }
    }

    difference() {
      body();
      holes();
    }
  }

  linear_extrude(height=thickness,center=true,convexity=3) {
    profile();
  }
}

bmg_spacer();
