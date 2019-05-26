include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module original_handle() {
  thick = 8;
  a = 30;
  h = 35;

  $fs = .2;
  $fa = 2;

  intersection() {
    rotate([-a, 0, 0]) translate([0, 0, 50 - 20]) linear_extrude(100, center = true, convexity = 5) scale([1, 1 / cos(a), 1]) offset(1) offset(-1) offset(thick) offset(-thick) translate([-thick, -100, 0]) square([thick + 80, h + thick / 2 + 100]);

    difference() {
      intersection() {
        rotate([a, 0, 0]) translate([0, 0, -50 + 20]) linear_extrude(100, center = true, convexity = 5) scale([1, 1 / cos(a), 1]) offset(1) offset(-1) difference() {
          offset(thick) offset(-thick)  {
            square([45, h]);
            translate([-thick, 0, 0]) {
              square([thick + 80, h + thick]);
              translate([0, h - thick * 2, 0]) square([thick / 2 + 80, thick * 3]);
            }
          }
          offset(-thick / 2) offset(thick * 1.5) offset(-thick) {
            for(i = [0:.2:80]) hull() for(i = [i, i + .2]) translate([i, thick, 0]) square([.2, h - thick - pow(1 + cos(i * 360 / 80 * 4 + 60), 2)]);
            translate([45, - thick, 0]) square([80, h]);
            translate([80, 0, 0]) square([80, h + thick]);
          }
        }
        linear_extrude(20 * cos(a) + thick * sin(a), convexity = 5) square(200, center = true);
      }
      translate([0, h / cos(a), 20 * cos(a) + thick * sin(a)]) intersection() {
        rotate([90 + a * 2, 0, 0]) cube([100, 20, 20]);
        rotate([90 + a, 0, 0]) cube([200, 100, 40], center = true);
      }
      rotate([a - 90, 0, 0]) for(i = [10, 30]) translate([i, -10, 4]) {
        cylinder(r = 5.2 / 2, h = 50, center = true);
        cylinder(r = 9.5 / 2, h = 50);
      }
    }
  }
}

module handle() {
  thick = 8;
  a = 30;
  h = 35;

  $fs = 1;
  $fa = 2;

  finger_opening_width = 85;

  carriage_stop_thickness = 5.2;
  carriage_stop_length = 10.0;

  module handle_profile() {
    scale([1, 1 / cos(a), 1]) {
      difference() {
        offset(thick) offset(-thick)  {
        //union() {
          translate([-thick, 0, 0]) {
            square([thick*2 + finger_opening_width, h + thick]);
          }
        }

        offset(-thick / 2) offset(thick * 1.5) offset(-thick) {
          //for(i = [0:.2:80]) {
          intersection() {
            square([finger_opening_width,200]);
            for(i = [0:1:finger_opening_width]) {
              hull() {
                for(i = [i, i + 1]) {
                  translate([i, thick, 0]) {
                    square([.5, h - thick - pow(1 + cos(i * 360 / (finger_opening_width+3) * 4 + finger_opening_width/4), 2)]);
                  }
                }
              }
            }
          }
          // make handle open
          //# translate([80, 0, 0]) square([80, h + thick]);
          // make bottom align with extrusion
          //# translate([45, - thick, 0]) square([80, h]);
        }
      }
    }
    translate([40+carriage_stop_thickness/2,-carriage_stop_length/2,0]) {
      square([carriage_stop_thickness,carriage_stop_length],center=true);
    }
  }

  translate([0,0,30]) {
    // handle_profile();
  }

  intersection() {
    rotate([-a, 0, 0]) {
      translate([0, 0, 50 - 20]) {
        linear_extrude(100, center = true, convexity = 5) {
          scale([1, 1 / cos(a), 1]) {
            offset(1) offset(-1) offset(thick) offset(-thick) translate([-thick, -100, 0]) {
              square([thick*2 + finger_opening_width, h + thick / 2 + 100]);
            }
          }
        }
      }
    }

    difference() {
      intersection() {
        rotate([a, 0, 0]) translate([0, 0, -50 + 20]) {
          linear_extrude(100, center = true, convexity = 5) {
            handle_profile();
          }
        }
        linear_extrude(20 * cos(a) + thick * sin(a), convexity = 5) square(200, center = true);
      }
      translate([0, h / cos(a), 20 * cos(a) + thick * sin(a)]) {
        rotate([90 + a * 2, 0, 0]) {
          cube([finger_opening_width, 20, 20]);
        }
      }
      // screw holes
      rotate([a - 90, 0, 0]) {
        for(i = [10, 30]) {
          translate([i, -10, thick]) {
            translate([0,0,1.2-0.75]) {
              hole(m5_loose_diam,end_cap_thickness*2+1,resolution);

              // countersink heads
              hull() {
                hole(m5_loose_diam,m5_fsc_head_diam-m5_loose_diam,resolution);
                translate([0,0,1]) {
                  hole(m5_fsc_head_diam,2,resolution);
                }
              }
            }
          }
        }
      }
    }
  }
}

handle();
