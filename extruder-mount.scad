include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

module extruder_motor_plate() {
  color("lightblue") import("./walter/Dual Axis Extruder Mount - Motor Plate.stl");

  module body() {
    
  }
  
  module holes() {
    
  }

  difference() {
    body();
    holes();
  }
}

module extruder_swivel() {
  color("lightblue") import("./walter/Dual Axis Extruder Mount - Swivel.stl");

  module body() {
    
  }
  
  module holes() {
    
  }

  difference() {
    body();
    holes();
  }
}

module extruder_bracket() {
  color("#56e") import("./walter/Dual Axis Extruder Mount - Bracket.stl");

  module body() {
    
  }
  
  module holes() {
    
  }

  difference() {
    body();
    holes();
  }
}

module extruder_assembly() {
  compensation_angle = 115-90;
  translate([0,37.5,-23.25-mgn9_rail_width/2]) {
    rotate([0,0,180]) {
      rotate([compensation_angle,0,0]) {
        extruder_bracket();

        rotate([-compensation_angle,0,0]) {
          extruder_swivel();

          translate([0,0,-19]) {
            extruder_motor_plate();

            translate([0,0,nema17_len+40]) {
              color("dimgrey") motor_nema17();
            }
          }
        }
      }
    }
  }
}

module extruder_motor_plate_to_print() {
  rotate([180,0,0]) {
    extruder_motor_plate();
  }
}
module extruder_swivel_to_print() {
  extruder_swivel();
}

module extruder_bracket_to_print() {
  extruder_bracket();
}

extruder_assembly();
