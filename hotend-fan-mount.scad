include <./lib/util.scad>;
include <./lib/vitamins.scad>;
include <./lib/cr8-hotend.scad>;

module hotend_fan_mount() {
  translate([0,0,cr8_hotend_hole_spacing_from_top-cr8_hotend_heatsink_height]) {
    color("lightblue") import("./walter/Extruder Fan Mount - Extruder Fan Mount.stl");
  }
}

module hotend_fan_mount_assembly() {
  if (true) {
    translate([-mgn9c_hole_spacing_length/2+cr8_hotend_outer_hole_spacing/2,front*(cr8_hotend_heatsink_thickness/2+4),mgn9c_hole_spacing_width/2]) {
      cr8_hotend();

      hotend_fan_mount();

      translate([0,0,cr8_hotend_hole_spacing_from_top-cr8_hotend_heatsink_height]) {
        translate([0,0,fan_4020_side/2]) {
          translate([-cr8_hotend_heatsink_width/2-fan_4020_side/2-0.2,front*(cr8_hotend_heatsink_thickness/2+fan_4020_thickness/2),0]) {
            rotate([0,-90,0]) {
              rotate([90,0,0]) {
                % fan_4020();
              }
            }
          }
          translate([cr8_hotend_heatsink_width/2+fan_4020_side/2+1.26,rear*(cr8_hotend_heatsink_thickness/2-fan_4020_thickness/2),0]) {
            rotate([0,0,0]) {
              rotate([90,0,0]) {
                % fan_4020();
              }
            }
          }
        }
      }
    }
  } else {
    translate([-mgn9c_hole_spacing_length/2+cr8_hotend_inner_hole_spacing/2,0,mgn9c_hole_spacing_width/2]) {
      translate([0,front*(cr8_hotend_heatsink_thickness/2+4),0]) {
        cr8_hotend();
      }
      /*
      translate([0,front*fan_4010_side/2,-fan_4010_side*0.4-1]) {
        translate([left*(cr8_hotend_heatsink_width/2+fan_4010_thickness/2),0,0]) {
          rotate([0,0,-90]) {
            rotate([90,0,0]) {
              fan_4010();
            }
          }
        }
        translate([right*(cr8_hotend_heatsink_width/2+fan_4010_thickness/2),0,0]) {
          rotate([0,0,90]) {
            rotate([90,0,0]) {
              fan_4010();
            }
          }
        }
      }
      */
      translate([0,0,cr8_hotend_hole_spacing_from_top-cr8_hotend_heatsink_height]) {
        translate([0,0,fan_4020_side/2]) {
          translate([-cr8_hotend_heatsink_width/2-fan_4020_thickness/2-0.2,front*(cr8_hotend_heatsink_thickness/2+fan_4020_thickness/2),0]) {
            rotate([0,0,-90]) {
              rotate([90,0,0]) {
                % fan_4020();
              }
            }
          }
          translate([cr8_hotend_heatsink_width/2+fan_4020_side/2+1.26,rear*(cr8_hotend_heatsink_thickness/2-fan_4020_thickness/2),0]) {
            rotate([0,0,0]) {
              rotate([0,0,0]) {
                % fan_4020();
              }
            }
          }
        }
      }
    }
  }
}

module hotend_fan_mount_to_print() {
  support_gap = 0.125 * 1;
  print_in_plate_support_height = 1.5-support_gap;
  translate([-cr8_hotend_heatsink_width/2-7,-cr8_hotend_heatsink_thickness/2-9.75,print_in_plate_support_height/2]) {
    rounded_cube(4,20,print_in_plate_support_height,5);
  }

  translate([0,0,-cr8_hotend_hole_spacing_from_top+cr8_hotend_heatsink_height]) {
    hotend_fan_mount();
  }
}

hotend_fan_mount_assembly();
