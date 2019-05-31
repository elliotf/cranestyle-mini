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
