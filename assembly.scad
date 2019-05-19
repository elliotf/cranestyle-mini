include <./config.scad>;
use <./x-carriage.scad>
use <./y-motor-mount.scad>
use <./z-motor-mount.scad>
use <./z-nut-mount.scad>
use <./duet-wifi-mount.scad>
use <./end-caps.scad>
use <./handle.scad>

translate([0,20+mgn12c_surface_above_surface,0]) {
  rotate([0,0,90]) {
    % color("lightgrey") extrusion_2040(220);
  }

  translate([-20/2,40/2,220/2]) {
    translate([0,0,2.75]) {
      rotate([0,0,90]) {
        rotate([-30+180,0,0]) {
          % color("lightblue") import("./walter/Handle-modified.stl");
        }
      }
    }
    /*
    translate([20/2,0,0]) {
      rotate([0,0,-90]) {
        rotate([-30+90,0,0]) {
          original_handle();
        }
      }
    }
    */
  }
}

x_motor_orientation = "b";
//x_motor_orientation = "v";
//x_motor_orientation = "h";

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
      % color("dimgrey") motor_nema14();
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
        motor_nema14();
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
    % color("dimgrey") motor_nema14();
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

// z nut and leadscrew
z_nut();
translate([0,leadscrew_pos_y,-220/2]) {
  z_motor_mount_front();
  z_motor_mount_rear();
}

// base extrusion plate
translate([80/2-20/2,-150/2+mgn12c_surface_above_surface+40,-220/2-20/2]) {
  rotate([90,0,0]) {
    % color("lightgrey") extrusion_2080(150);
  }
}

translate([75-53,-mgn9c_surface_above_surface,mgn12c_hole_spacing_length/2]) {
  rotate([90,0,0]) {
    rotate([0,0,90]) {
      % color("grey") mgn9c();
    }
  }
  walter_x_carriage();
}

// X idler
translate([-16+150,0,0]) {
  translate([7,-mgn9_rail_height/2,x_idler_on_z_pos_z+idler_bevel_height+gt2_toothed_idler_height/2]) {
    % color("silver") gt2_toothed_idler();
  }
  translate([-9,3,7.5]) {
    rotate([90,0,0]) {
      rotate([0,0,-90]) {
        % color("lightblue") import("./walter/X-Idler.stl");
      }
    }
  }
}

// Y idler
translate([0,-nema14_side*2-1,-220/2+10.5]) {
  rotate([0,0,-90]) {
    y_motor_mount();
  }
}




translate([30,mgn12c_surface_above_surface+40-150/2,-220/2]) {
  // Y MGN carriage and rail
  translate([40-3.3-mgn12_rail_width/2,0,0]) {
    translate([0,0,mgn12c_surface_above_surface]) {
      color("darkgrey") mgn12c();
    }
    translate([0,0,mgn12_rail_height/2]) {
      color("lightgrey") cube([mgn12_rail_width,150,mgn12_rail_height],center=true);
    }
  }

  translate([-15+63,0,6+mgn12c_surface_above_surface]) {
    rotate([0,0,0]) {
      rotate([180,0,0]) {
        % color("lightblue", 0.5) import("./walter/Bed Platform.stl");
      }
    }
  }

  // Y idlers
  for(y=[front,rear]) {
    translate([y_idler_pos_x,y*(150/2-y_idler_dist_y_from_extrusion),gt2_toothed_idler_height/2+y_idler_dist_z_from_extrusion+0.1]) {
      % color("lightgrey") gt2_toothed_idler();
    }
  }

  // end caps
  translate([0,0,-20/2]) {
    translate([0,150/2,0]) {
      end_cap_rear();
    }
    translate([0,-150/2,0]) {
      end_cap_front();
    }
  }

  // duet wifi board underneath
  translate([-40+duet_width/2,0,-20-5]) {
    rotate([180,0,0]) {
      duet_board();
    }
  }
}
