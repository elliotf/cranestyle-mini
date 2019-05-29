include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module original_x_carriage() {
  $fs = .2;
  $fa = 2;

  rotate([90,0,0]) {
    difference() {
      linear_extrude(8.5, convexity = 5) difference() {
        offset(1) offset(-2) offset(1) difference() {
          union() {
            square([16, 20], center = true);
            translate([-8, 0, 0]) square([32 + 8, 10 + 10]);
          }
          translate([18, 10, 0]) square(100);
        }
        for(x = [1, -1], y = [1, -1]) translate([x * 5, y * 7.5, 0]) circle(3/2 + .1);
        for(x = [1, -1]) translate([5 + 12 + x * 12, 7.5, 0]) circle(3/2 + .1);
      }
      translate([5 + 12, 5 + 6, 15 / 2 + 3]) rotate([90, 0, 0]) {
        linear_extrude(100, center = false) intersection() {
          circle(16);
          square([32, 15], center = true);
        }
        linear_extrude(100, center = true) intersection() {
          circle(16);
          hull() for(i = [0, 1]) translate([i * 50, 0, 0]) circle(15/2);
        }
      }
      for(i = [0, 1]) translate([4 + i * 8, 20, -3.2]) rotate([90, -90 - 33, 0]) linear_extrude(16, center = true, convexity = 5) offset(-.4) offset(.8) offset(-.4) {
        for(i = [0:20]) translate([i * 2, 0, 0]) square([1, 2]);
        square([40, 1]);
      }
    }
  }
}

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

  translate([-50,0,0]) {
    rotate([0,0,0]) {
      original_x_carriage();
    }
  }
} else {
  to_print();
}
