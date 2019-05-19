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

module long_clamp() {
  module body() {
    for(x=[left,right]) {
      translate([x*duet_hole_spacing_x/2,0,0]) {
        hole(3,4,resolution);
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

translate([0,duet_hole_spacing_y/2,0]) {
  long_clamp();
}
translate([-duet_width/2+80/2,0,2+10]) {
  rotate([90,0,0]) {
    % extrusion_2080(150);
  }
}
rotate([0,180,0]) {
  % duet_board();
}
