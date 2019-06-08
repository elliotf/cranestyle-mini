include <./config.scad>;
include <./lib/util.scad>;

module accurate_2d_marked_hole(diam) {
  difference() {
    accurate_circle(diam,resolution);
    // accurate_circle(0.5,resolution); // if we're going to use a plotter, otherwise we don't need this
  }
}

module y_carriage_profile() {
  module body() {
    rounded_square(100,100,100-heated_bed_hole_spacing);
  }

  module holes() {
    // leveling screw holes
    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,0]) {
          accurate_2d_marked_hole(m3_diam);
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

module y_carriage_assembly() {
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

  translate([bed_carriage_offset,0,mgn12c_surface_above_surface+extra_clearance_for_leveling_screws_and_y_idlers + y_carriage_thickness/2 + 0.2]) {
    color("silver") {
      linear_extrude(height=y_carriage_thickness,center=true,convexity=2) {
        y_carriage_profile();
      }
    }

    for(z=[top,bottom]) {
      for (x=[left,right]) {
        for (y=[front,rear]) {
          translate([x*heated_bed_hole_spacing/2,y*heated_bed_hole_spacing/2,(y_carriage_thickness/2+mini_thumb_screw_thickness/2)*z]) {
            rotate([0,90+z*90,0]) {
              color("dimgrey") mini_thumb_screw();
            }
          }
        }
      }
    }

    translate([0,0,y_carriage_thickness/2 + mini_thumb_screw_thickness + m3_plain_nut_thickness + 1 + hbp_thickness/2]) {
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
}
