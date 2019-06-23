include <./config.scad>;
include <./lib/util.scad>;
use <./y-carriage.scad>;
use <./lib/gt2-pulley-profile.scad>;

top_of_belt_below_mgn = 3.5;
bottom_of_belt_below_mgn = 11.5;
belt_opening_height = abs(bottom_of_belt_below_mgn - top_of_belt_below_mgn);

belt_pos_z = y_idler_dist_z_from_extrusion;

belt_thickness = 0.9;
printed_carriage_thickness = 7;

mgn_clamp_mount_width = 12;
mgn_clamp_mount_height = top_of_belt_below_mgn+extra_clearance_for_leveling_screws_and_y_idlers;

y_belt_clamp_base_thickness = 1;
y_belt_clamp_width = mgn_clamp_mount_width-belt_thickness; // walter has 8
y_belt_clamp_length = mgn12c_hole_spacing_length+10+wall_thickness*2; // walter has 22
y_belt_clamp_height = belt_opening_height+y_belt_clamp_base_thickness;

y_carriage_side = 102;

hbp_thickness = 1.6;

module belt_clamp() {
  // on the X carriage, walter is making room for a 0.8mm tall tooth that is 0.5 at its peak, with 60deg sides, and belt of 0.8mm
  // on the Y carriage, walter is making room for a 1.0mm tall tooth that is 0.422 at its peak, with 60deg sides, and belt of 0.8mm

  echo("y_belt_clamp_height: ", y_belt_clamp_height);

  tooth_height = 1;
  tooth_width = 0.422;
  overall_belt_thickness = belt_thickness+tooth_height;
  belt_rounding_diam = 5;
  overall_belt_rounding_diam = belt_rounding_diam + overall_belt_thickness;

  num_teeth = 12;
  rounding_teeth_od = tooth_spacing_for_teeth(num_teeth);

  module belt_profile() {
    for(y=[front,rear]) {
      mirror([0,1-y,0]) {
        translate([0,wall_thickness,0]) {
          translate([-rounding_teeth_od/2,belt_thickness/2,0]) {
            square([y_belt_clamp_width+0.1,belt_thickness],center=true);
          }
          translate([y_belt_clamp_width/2,belt_thickness,0]) {
            // clear out material between
            intersection() {
              translate([0,0,0]) {
                square([rounding_teeth_od,rounding_teeth_od],center=true);
              }
              translate([-rounding_teeth_od/2,rounding_teeth_od/2,0]) {
                difference() {
                  accurate_circle(rounding_teeth_od+belt_thickness*2,resolution);
                  accurate_circle(rounding_teeth_od,resolution);
                }
              }
            }
            rotate([0,0,90]) {
              // round_corner_filler_profile(rounding_teeth_od,resolution);
            }
            translate([-rounding_teeth_od/2,rounding_teeth_od/2,0]) {
              intersection() {
                translate([20,-20,0]) {
                  square([40,40],center=true);
                }
                rotate([0,0,180/num_teeth]) {
                  gt2_teeth_in_circle(num_teeth);
                }
              }
            }
            // teeth against MGN
            translate([0,rounding_teeth_od/2,0]) {
              for(y=[0:6]) {
                translate([0,1+y*2,0]) {
                  rotate([0,0,90]) {
                    gt2_tooth();
                  }
                }
              }
            }
            // teeth between
            translate([-rounding_teeth_od/2,0,0]) {
              for(x=[0:6]) {
                translate([-1-x*2,0,0]) {
                  gt2_tooth();
                }
              }
            }
          }
        }
      }
    }
  }

  module body() {
    rounded_cube(y_belt_clamp_width,y_belt_clamp_length,y_belt_clamp_height,2);
  }

  module holes() {
    for(y=[front,rear]) {
      translate([y_belt_clamp_width/2+belt_thickness-y_belt_clamp_hole_dist_from_mgn,y*mgn12c_hole_spacing_length/2,0]) {
        translate([0,0,m3_threaded_insert_len+1+0.2]) {
          hole(m3_loose_diam,y_belt_clamp_height,resolution);
        }
        translate([0,0,-y_belt_clamp_height/2]) {
          hole(m3_threaded_insert_diam,(m3_threaded_insert_len+1.5)*2,resolution);
        }
      }
    }

    translate([0,0,y_belt_clamp_height/2]) {
      linear_extrude(height=belt_opening_height*2,convexity=3,center=true) {
        # belt_profile();
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module printed_y_carriage() {
  top_pos_z = mgn_clamp_mount_height/2 + printed_carriage_thickness;

  bed_pos_x = mgn12c_width/2+y_belt_clamp_width/2+belt_thickness+bed_carriage_offset;
  cable_strain_relief_length = 15;
  cable_strain_relief_width = 10;
  cable_strain_relief_pos_x = bed_pos_x+left*(y_carriage_side/2-cable_strain_relief_width/2-20);

  module body() {
    translate([-y_belt_clamp_width/2+mgn_clamp_mount_width/2,0,0]) {
      rounded_cube(mgn_clamp_mount_width-0.4,y_belt_clamp_length,mgn_clamp_mount_height,2);

      translate([0,0,mgn_clamp_mount_height/2-extra_clearance_for_leveling_screws_and_y_idlers/2]) {
        linear_extrude(height=extra_clearance_for_leveling_screws_and_y_idlers,center=true,convexity=3) {
          hull() {
            rounded_square(mgn_clamp_mount_width-0.4,y_belt_clamp_length,2);

            translate([mgn_clamp_mount_width/2+mgn12c_width/2,0]) {
              rounded_square(mgn12c_width,mgn12c_length,2);
            }
          }
        }
      }
    }
    translate([0,0,top_pos_z-printed_carriage_thickness/2]) {
      linear_extrude(height=printed_carriage_thickness,center=true,convexity=2) {
        translate([mgn12c_width/2+y_belt_clamp_width/2+belt_thickness+bed_carriage_offset,0,0]) {
          y_carriage_profile();
        }

        translate([cable_strain_relief_pos_x,y_carriage_side/2,0]) {
          rounded_square(cable_strain_relief_width,cable_strain_relief_length*2,3);

          for(x=[left,right]) {
            translate([x*cable_strain_relief_width/2,0,0]) {
              rotate([0,0,45-x*45]) {
                round_corner_filler_profile(3);
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    for(y=[front,rear]) {
      m3_fsc_head_rim = 0.5;
      translate([y_belt_clamp_width/2+belt_thickness-y_belt_clamp_hole_dist_from_mgn,y*mgn12c_hole_spacing_length/2,top_pos_z]) {
        m3_countersink_screw(mgn_clamp_mount_height+10);

        for(x=[10.5,30.5]) { // TODO: need to put this somewhere?
          translate([x,0,0]) {
            m3_countersink_screw(mgn_clamp_mount_height*2+1);
          }
        }
      }
    }

    translate([cable_strain_relief_pos_x,y_carriage_side/2,top_pos_z-printed_carriage_thickness]) {
      for(y=[4,10]) {
        translate([0,y,0]) {
          cube([cable_strain_relief_width+1,3,3],center=true);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module mgn_clamp_mount() {
  module body() {
    translate([-y_belt_clamp_width/2+mgn_clamp_mount_width/2,0,0]) {
      rounded_cube(mgn_clamp_mount_width-0.4,y_belt_clamp_length,mgn_clamp_mount_height,2);

      translate([0,0,mgn_clamp_mount_height/2-extra_clearance_for_leveling_screws_and_y_idlers/2]) {
        linear_extrude(height=extra_clearance_for_leveling_screws_and_y_idlers,center=true,convexity=3) {
          hull() {
            rounded_square(mgn_clamp_mount_width-0.4,y_belt_clamp_length,2);

            translate([mgn_clamp_mount_width/2+mgn12c_width/2,0]) {
              rounded_square(mgn12c_width,mgn12c_length,2);
            }
          }
        }
      }
    }
  }

  module holes() {
    for(y=[front,rear]) {
      m3_fsc_head_rim = 0.5;
      translate([y_belt_clamp_width/2+belt_thickness-y_belt_clamp_hole_dist_from_mgn,y*mgn12c_hole_spacing_length/2,mgn_clamp_mount_height/2-m3_fsc_head_rim]) {
        hole(m3_loose_diam,mgn_clamp_mount_height*2+1,resolution);
        // room for screw head
        hull() {
          hole(m3_loose_diam,m3_fsc_head_diam-m3_loose_diam,resolution);
          translate([0,0,1]) {
            hole(m3_fsc_head_diam,2,resolution);
          }
        }

        for(x=[10.5,30.5]) { // TODO: need to put this somewhere?
          translate([x,0,0]) {
            hole(m3_loose_diam,mgn_clamp_mount_height*2+1,resolution);
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module accurate_2d_marked_hole(diam) {
  difference() {
    accurate_circle(diam,resolution);
    // accurate_circle(0.5,resolution); // if we're going to use a plotter, otherwise we don't need this
  }
}

module y_carriage_profile() {
  module body() {
    rounded_square(y_carriage_side,y_carriage_side,y_carriage_side-heated_bed_hole_spacing);
  }

  module holes() {
    // leveling screw holes
    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,0]) {
          accurate_2d_marked_hole(m3_diam+0.4);
        }
      }
    }

    translate([-bed_carriage_offset,0,0]) {
      // MGN carriage mounting holes
      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([x*(mgn12c_hole_spacing_width/2),y*(mgn12c_hole_spacing_length/2),0]) {
            accurate_2d_marked_hole(m3_diam);
          }
        }
      }

      // belt clamp screw holes, just in case
      translate([left*(mgn12c_width/2+y_belt_clamp_hole_dist_from_mgn),0,0]) {
        for(y=[front,rear]) {
          translate([0,y*(mgn12c_hole_spacing_length/2),0]) {
            accurate_2d_marked_hole(m3_diam);
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module build_plate() {
  extra_length_on_each_end = 15; // FIXME: base on something?  Like the width or depth of a binder clip?
  extra_length_on_each_side = 2; // FIXME: base on something?  Like the width or depth of a binder clip?
  module body() {
    rounded_square(100+extra_length_on_each_side*2,100+extra_length_on_each_end*2,4);
  }

  module holes() {
    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,0]) {
          accurate_2d_marked_hole(m3_diam);
        }
      }
    }

    // thermistor recess hole
    accurate_2d_marked_hole(3);
  }

  difference() {
    body();
    holes();
  }
}

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

module y_axis_assembly() {
  y_carriage_thickness = 3;
  build_plate_thickness = 2;
  m3_plain_nut_thickness = 2.5;

  leveling_screw_length = 18;
  if (false) {
    measure_height = 17.34;
    translate([20,0,mgn12c_surface_above_surface+measure_height/2]) {
      color("red") cube([10,10,measure_height],center=true);
    }
  }

  translate([bed_carriage_offset,0,mgn12c_surface_above_surface+extra_clearance_for_leveling_screws_and_y_idlers + printed_carriage_thickness/2]) {
    color("silver") {
      linear_extrude(height=y_carriage_thickness,center=true,convexity=2) {
        // y_carriage_profile();
      }
    }

    for(z=[top,bottom]) {
      for (x=[left,right]) {
        for (y=[front,rear]) {
          translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,(printed_carriage_thickness/2+0.5+mini_thumb_screw_thickness/2)*z]) {
            rotate([0,90+z*90,0]) {
              color("dimgrey") mini_thumb_screw();
            }
          }
        }
      }
    }

    translate([0,0,printed_carriage_thickness/2 + mini_thumb_screw_thickness + m3_plain_nut_thickness + 1 + hbp_thickness/2]) {
      heated_build_plate();

      for (x=[left,right]) {
        for (y=[front,rear]) {
          translate([-bed_carriage_offset+bed_carriage_offset+x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,-hbp_thickness/2-m3_plain_nut_thickness/2]) {
            color("silver") {
              hole(m3_nut_diam,m3_plain_nut_thickness,6);
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

  translate([-mgn12c_width/2-y_belt_clamp_width/2-belt_thickness,0,mgn12c_surface_above_surface-top_of_belt_below_mgn-y_belt_clamp_height/2]) {
    belt_clamp();

    translate([0,0,y_belt_clamp_height/2+mgn_clamp_mount_height/2+0.1]) {
      // mgn_clamp_mount();
      printed_y_carriage();
    }
  }
  translate([0,0,mgn12c_surface_above_surface]) {
    % mgn12c();
  }
}

y_axis_assembly();

% mgn12_rail(150);
translate([0,0,-0.5]) {
  % cube([100,100,1],center=true);
}
