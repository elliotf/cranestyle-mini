include <./config.scad>;
use <./x-carriage.scad>;
use <./x-idler.scad>;
use <./y-carriage.scad>;
use <./y-motor-mount.scad>;
use <./y-belt-clamp.scad>;
use <./z-motor-mount.scad>;
use <./z-nut-mount.scad>;
use <./end-caps.scad>;
use <./handle.scad>;

translate([0,20+mgn12c_surface_above_surface,0]) {
  rotate([0,0,90]) {
    % color("lightgrey") extrusion_2040(220);
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

// z nut and leadscrew
z_nut();
translate([0,leadscrew_pos_y,-220/2+nema14_len]) {
  z_motor_assembly();
}
translate([left*(20/2+mech_endstop_tiny_width/2),rear*(mgn12c_surface_above_surface+20/2-mech_endstop_mounting_hole_spacing_y/2),-220/2+50]) {
  rotate([0,0,180]) {
    mech_endstop_tiny();
  }
}

translate([75,-mgn9c_surface_above_surface,mgn12c_hole_spacing_length/2]) {
  rotate([90,0,0]) {
    rotate([0,0,90]) {
      % mgn9c();
    }
  }
  walter_x_carriage();
}

// X idler
translate([-mgn12c_width/2+150-1.5,0,0]) { // no idea where the -1.5 comes from, but probably has to do with the mgn9 hole spacing excess
  x_idler();
}

translate([0,-nema14_side*2-1,-220/2+10.5]) {
  rotate([0,0,-90]) {
    y_motor_mount();
  }
}

hbp_thickness = 1.6;

module heated_build_plate() {
  color("#333") {
    difference() {
      cube([100,100,hbp_thickness],center=true);

      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,0]) {
            hole(m3_diam,hbp_thickness+1,resolution);
          }
        }
      }
    }
  }
}

translate([0,mgn12c_surface_above_surface+40-150/2,-220/2]) {
  translate([-10+y_extrusion_width/2,0,0]) {
    // base extrusion plate
    translate([0,0,-10]) {
      rotate([90,0,0]) {
        % color("lightgrey") {
          linear_extrude(height=150,center=true,convexity=3) {
            extrusion_20_profile(y_extrusion_width);
          }
        }
      }
    }

    // Y MGN carriage and rail
    translate([y_extrusion_width/2-3.3-mgn12_rail_width/2,0,0]) {
      leveling_screw_length = 18;
      if (false) {
        measure_height = 17.34;
        translate([20,0,mgn12c_surface_above_surface+measure_height/2]) {
          color("red") cube([10,10,measure_height],center=true);
        }
      }

      y_belt_clamp_assembly();

      y_carriage_thickness = 3;
      build_plate_thickness = 2;

      translate([0,0,mgn12c_surface_above_surface+extra_clearance_for_leveling_screws_and_y_idlers + y_carriage_thickness/2 + 0.2]) {
        //color("silver") cube([100,100,2],center=true);
        color("silver") {
          linear_extrude(height=y_carriage_thickness,center=true,convexity=2) {
            y_carriage_profile();
          }
        }

        for(z=[top,bottom]) {
          for (x=[left,right]) {
            for (y=[front,rear]) {
              translate([bed_carriage_offset+x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,(y_carriage_thickness/2+mini_thumb_screw_thickness/2)*z]) {
                rotate([0,90+z*90,0]) {
                  color("dimgrey") mini_thumb_screw();
                }
              }
            }
          }
        }

        m3_plain_nut_thickness = 2.5;
        translate([bed_carriage_offset,0,y_carriage_thickness/2 + mini_thumb_screw_thickness + m3_plain_nut_thickness + 1 + hbp_thickness/2]) {
          heated_build_plate();

          for (x=[left,right]) {
            for (y=[front,rear]) {
              translate([-bed_carriage_offset+bed_carriage_offset+x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,-hbp_thickness/2-m3_plain_nut_thickness/2]) {
                color("silver") {
                  difference() {
                    hole(m3_nut_diam,m3_plain_nut_thickness,6);
                  }
                }
              }
            }
          }

          translate([0,0,hbp_thickness/2+build_plate_thickness/2]) {
            color("silver") {
              linear_extrude(height=build_plate_thickness,center=true,convexity=2) {
                build_plate();
              }
            }

            for (x=[left,right]) {
              for (y=[front,rear]) {
                translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,-leveling_screw_length/2]) {
                  color("#ccc") hole(3,leveling_screw_length,resolution);
                }
              }
            }
          }
        }
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
