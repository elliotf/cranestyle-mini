include <./config.scad>;
include <./lib/util.scad>;

module x_idler() {
  mounting_hole_from_end_pos_x = [-5,-25];

  idler_bevel_above_rail = x_idler_on_z_pos_z - mgn12c_hole_spacing_length/2;
  body_width = gt2_toothed_idler_flange_od;
  body_height = 2*(idler_bevel_above_rail-x_idler_bevel_height);
  body_thickness = m5_thread_into_hole_diam+1.2*4; // walter is using 12.5, but we should still be compatible
  portion_behind_rail = 3;
  rail_lip_height = 1.5; // how far to go up the rail -- limited to clear carriage
  rail_portion_length = 30;
  rail_portion_thickness = portion_behind_rail + rail_lip_height;
  overall_width = body_width + rail_portion_length + tolerance;

  x_idler_pos_x = body_width/2;
  x_idler_pos_y = -3.25;

  thickness_behind_rail = 3;

  rail_guide_height = (body_height - mgn9_rail_width_allowance) / 2;

  rounded_diam = rail_guide_height;

  module body() {
    translate([0,0,mgn12c_hole_spacing_length/2]) {
      // behind the rail
      translate([body_width+tolerance-overall_width/2,0,0]) {
        translate([0,portion_behind_rail/2,0]) {
          rotate([90,0,0]) {
            rounded_cube(overall_width,body_height,portion_behind_rail,rounded_diam,resolution);
          }
        }

        // above/below the rail (to hole it in place
        for (z=[top,bottom]) {
          translate([0,0,z*(body_height/2-rail_guide_height/2)]) {
            rotate([90,0,0]) {
              rounded_cube(overall_width,rail_guide_height,rail_lip_height*2,rounded_diam,resolution);
            }
          }
        }
      }

      // idler mount
      translate([x_idler_pos_x+tolerance,x_idler_pos_y,0]) {
        rotate([90,0,0]) {
          rounded_cube(x_idler_pos_x*2,body_height,body_thickness,rounded_diam,resolution);
        }
      }
    }

    // bevel
    translate([x_idler_pos_x,x_idler_pos_y,0]) {
      hull() {
        translate([0,0,x_idler_on_z_pos_z-x_idler_bevel_height]) {
          hole(m5_thread_into_hole_diam+2*(extrude_width),x_idler_bevel_height*2,resolution);
          translate([0,0,-1]) {
            hole(m5_thread_into_hole_diam+2*(extrude_width+x_idler_bevel_height),2,resolution);
          }
        }
      }
    }
  }

  module holes() {
    translate([x_idler_pos_x,x_idler_pos_y,0]) {
      hole(m5_thread_into_hole_diam,50,resolution);
    }

    for (x=mounting_hole_from_end_pos_x) {
      translate([x,0,mgn12c_hole_spacing_length/2]) {
        rotate([-90,0,0]) {
          translate([0,0,portion_behind_rail]) {
            hole(m3_nut_diam,1.5*2,6);

            translate([0,0,-1.5-10-0.2]) {
              hole(m3_diam,20,resolution);
            }
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }

  translate([x_idler_pos_x,x_idler_pos_y,x_idler_on_z_pos_z+gt2_toothed_idler_height/2]) {
    % color("silver") gt2_toothed_idler();
  }
}

x_idler();

module to_print() {
  rotate([-90,0,0]) {
    x_idler();
  }
}
