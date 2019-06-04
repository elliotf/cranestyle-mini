include <./lib/cr8-hotend.scad>;

module hotend_fan_mount() {
  translate([0,0,cr8_hotend_hole_spacing_from_top-cr8_hotend_heatsink_height]) {
    color("lightblue") import("./walter/Extruder Fan Mount - Extruder Fan Mount.stl");
  }
}

module hotend_fan_mount_to_print() {
  hotend_fan_mount();
}

hotend_fan_mount();
