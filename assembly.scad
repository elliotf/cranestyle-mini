include <./config.scad>;
use <./extruder-mount.scad>;
use <./hotend-fan-mount.scad>;
use <./x-carriage.scad>;
use <./x-idler.scad>;
use <./y-carriage.scad>;
use <./y-motor-mount.scad>;
use <./y-endstop-mount.scad>;
use <./z-motor-mount.scad>;
use <./z-nut-mount.scad>;
use <./end-caps.scad>;
use <./handle.scad>;
use <./tslot-stuff.scad>;
include <./lib/cr8-hotend.scad>;

translate([0,20+mgn12c_surface_above_surface,0]) {
  rotate([0,0,90]) {
    % color("lightgrey") extrusion(20,40,220);
  }

  translate([-20/2,40/2,220/2]) {
    translate([20,0,0]) {
      rotate([0,0,-90]) {
        rotate([-30+90,0,0]) {
          color("firebrick", 0.8) handle();
        }
      }
    }
  }
}

x_motor_orientation = "b";
//x_motor_orientation = "v";
//x_motor_orientation = "h";

// z nut and leadscrew
translate([0,0,-45]) {

  if (x_motor_orientation == "h") {
    // horizontally positioned X motor at the end of X
    translate([x_idler_on_z_pos_x-6.5-nema14_side/2,0,mgn12c_length/2+7]) {
      rotate([90,0,0]) {
        translate([0,0,nema14_shoulder_height+4.1]) {
          % color("silver") gt2_16t_pulley();

          for(y=[front,rear]) {
            translate([40,y*(10/2+0.5),0]) {
              % color("dimgrey") cube([80,1,6],center=true);
            }
          }
        }
        % color("dimgrey") motor_nema14(x_motor_length);
      }
    }
  }

  if (x_motor_orientation == "v") {
    // vertically positioned X motor at the end of X
    dist_between_rail_and_leadscrew = mgn12c_dist_above_surface - mgn12_rail_height + abs(leadscrew_pos_y) - leadscrew_diam/2;
    nema17 = 0;

    motor_side = (nema17) ? nema17_side : nema14_side;
    translate([x_idler_on_z_pos_x-6.5-motor_side/2,-mgn12c_surface_above_surface+mgn12_rail_height+dist_between_rail_and_leadscrew/2,mgn12c_hole_spacing_length/2+mgn9_rail_width/2]) {
      translate([0,0,-mgn9_rail_width/2+mgn9c_width/2+4]) {
        % color("silver") gt2_16t_pulley();

        for(y=[front,rear]) {
          translate([40,y*(10/2+0.5),0]) {
            # color("dimgrey") cube([80,1,6],center=true);
          }
        }
      }
      % color("dimgrey") {
        if (nema17) {
          motor_nema17();
        } else {
          motor_nema14(x_motor_length);
        }
      }
    }
  }

  if (x_motor_orientation == "b") {
    // vertically positioned X motor at the end of X
    translate([20/2+12+nema14_side/2,nema14_side/2+7,mgn12c_hole_spacing_length/2+mgn9_rail_width/2+2]) {
      translate([0,0,-mgn9_rail_width/2+mgn9c_width/2+1]) {
        % color("silver") gt2_16t_pulley();

        /*
        for(y=[front,rear]) {
          translate([40,y*(10/2+0.5),0]) {
            % color("dimgrey") cube([80,1,6],center=true);
          }
        }
        */
      }
      % color("dimgrey") motor_nema14(x_motor_length);
      translate([-nema14_hole_spacing/2,nema14_hole_spacing/2,6.1]) {
        rotate([0,0,-90]) {
          % color("lightblue") import("./walter/Stabilizer Wheel Mount.stl");
        }
      }
    }
    translate([x_idler_on_z_pos_x,x_idler_on_z_pos_y,x_idler_on_z_pos_z+gt2_toothed_idler_height/2]) {
      % color("lightgrey") gt2_toothed_idler();
    }
  }

  translate([75,-mgn9c_surface_above_surface,mgn12c_hole_spacing_length/2]) {
    translate([0,0,0]) {
      rotate([90,0,0]) {
        rotate([0,0,90]) {
          % mgn9c();
        }
      }
      hotend_fan_mount_assembly();

      % x_carriage();
    }
  }

  // X idler
  translate([-mgn12c_width/2+150-1.5,0,0]) { // no idea where the -1.5 comes from, but probably has to do with the mgn9 hole spacing excess
    x_idler();
  }

  translate([-mgn12c_hole_spacing_width/2+mgn9_rail_hole_spacing*5,0,mgn12c_hole_spacing_length/2]) {
    extruder_assembly();
  }

  z_nut_assembly();

  rotate([90,0,0]) {
    % mgn12c();
  }

  x_rail_len = 150;

  translate([-mgn12c_hole_spacing_width/2-5+x_rail_len/2,0,mgn12c_hole_spacing_length/2]) {
    rotate([0,0,90]) {
      rotate([0,-90,0]) {
        % mgn9_rail(x_rail_len);
      }
    }
  }
}

translate([0,mgn12c_surface_above_surface,220/2-170/2-10.5]) {
  rotate([90,0,0]) {
    % mgn12_rail(170);
  }
}

translate([0,leadscrew_pos_y,-220/2+nema14_len]) {
  z_motor_assembly();
}
translate([left*(20/2),rear*(mgn12c_surface_above_surface+20/2),-220/2+44]) {
  translate([left*(mech_endstop_tiny_width/2),front*(mech_endstop_mounting_hole_spacing_y/2),mech_endstop_tiny_mounting_hole_from_top]) {
    mech_endstop_tiny();
  }
  rotate([0,0,-90]) {
    tnut_m2();
  }
}

translate([0,-nema14_side*2-1,-220/2+10.5]) {
  rotate([0,0,-90]) {
    y_motor_mount();
  }
}

translate([0,mgn12c_surface_above_surface+40-150/2,-220/2]) {
  translate([-10+y_extrusion_width/2,0,0]) {
    // base extrusion plate
    translate([0,0,-10]) {
      rotate([90,0,0]) {
        % color("lightgrey") extrusion(20,y_extrusion_width,150);
      }
    }

    translate([y_extrusion_width/2,150/2-0.1,0]) {
      y_endstop_mount();
    }


    // Y MGN carriage and rail
    translate([y_extrusion_width/2-3.3-mgn12_rail_width/2,0,0]) {
      % mgn12_rail(150);

      translate([0,54,0]) {
        y_belt_clamp_assembly();
        y_carriage_assembly();
      }
    }
  }

  // Y idlers
  for(y=[front,rear]) {
    translate([y_idler_pos_x,y*(150/2-y_idler_dist_y_from_extrusion),gt2_toothed_idler_height/2+y_idler_dist_z_from_extrusion+0.1]) {
      % color("lightgrey") gt2_toothed_idler();
    }
  }

  // end caps + duet wifi
  translate([end_cap_pos_x,0,0]) {
    end_cap_assembly();
  }
}
