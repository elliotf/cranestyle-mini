include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module walter_x_carriage() {
  rotate([90,0,0]) {
    color("lightblue") import("./walter/X-Carriage - Carriage.stl");
  }
  translate([-27,-13+mech_endstop_tiny_width/2,mech_endstop_mounting_hole_spacing_y/2+0.5]) {
    rotate([0,0,-90]) {
      rotate([90,0,0]) {
        % mech_endstop_tiny();
      }
    }
  }
}

module walter_x_carriage_belt_tensioner() {
  rotate([90,0,0]) {
    color("lightblue") import("./walter/X-Carriage - Belt Tensioner.stl");
  }
}

module x_carriage() {
  walter_x_carriage();
  walter_x_carriage_belt_tensioner();
}

module carriage_to_print() {
  rotate([0,180,0]) {
    walter_x_carriage();
  }
}

module carriage_belt_tensioner_to_print() {
  rotate([0,180,0]) {
    walter_x_carriage_belt_tensioner();
  }
}

carriage_to_print();
