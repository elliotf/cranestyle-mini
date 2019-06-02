include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module walter_x_carriage() {
  rotate([90,0,0]) {
    color("lightblue") import("./walter/X-Carriage.stl");
  }
  translate([-27,-13+mech_endstop_tiny_width/2,mech_endstop_mounting_hole_spacing_y/2+0.5]) {
    rotate([0,0,-90]) {
      rotate([90,0,0]) {
        % mech_endstop_tiny();
      }
    }
  }
}

module x_carriage() {
}

module to_print() {
  rotate([0,180,0]) {
    walter_x_carriage();
  }
}

if (true) {
  walter_x_carriage();
} else {
  to_print();
}
