include <./lib/util.scad>;
include <./lib/cr8-hotend.scad>;

module hotend_fan_mount() {
  translate([0,0,cr8_hotend_hole_spacing_from_top-cr8_hotend_heatsink_height]) {
    color("lightblue") import("./walter/Extruder Fan Mount - Extruder Fan Mount.stl");
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

hotend_fan_mount();
