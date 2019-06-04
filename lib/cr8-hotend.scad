include <../lib/util.scad>;

cr8_hotend_heatsink_width = 32;
cr8_hotend_heatsink_thickness = 15;
cr8_hotend_heatsink_height = 30;
cr8_hotend_heatsink_fin_thickness = 1;
cr8_hotend_heatsink_fin_space_between = 2.2;
cr8_hotend_heatsink_fin_spacing = cr8_hotend_heatsink_fin_space_between + cr8_hotend_heatsink_fin_thickness;
cr8_hotend_hole_spacing_from_top = 3;
cr8_hotend_inner_hole_spacing = 14;
cr8_hotend_outer_hole_spacing = 24;
cr8_hotend_shoulder_to_tip_length = 50;

// zero is center of heatsink at mounting holes
module cr8_hotend() {
  module heatsink_profile() {

    difference() {
      hull() {
        rounded_diam = 32;
        for(x=[left,right]) {
          translate([x*(cr8_hotend_heatsink_width/2-rounded_diam/2),0,0]) {
            accurate_circle(rounded_diam,resolution);
          }
        }
      }
      for(y=[front,rear]) {
        translate([0,y*(cr8_hotend_heatsink_thickness),0]) {
          square([cr8_hotend_heatsink_width,cr8_hotend_heatsink_thickness],center=true);
        }
      }
    }
  }

  module body() {
    top_heatsink_chunk_height = 10;
    translate([0,0,cr8_hotend_hole_spacing_from_top]) {
      translate([0,0,-top_heatsink_chunk_height/2]) {
        linear_extrude(height=top_heatsink_chunk_height,center=true,convexity=3) {
          heatsink_profile();
        }

        space_between_top_chunk_and_first_fin = 3;

        translate([0,0,-top_heatsink_chunk_height/2-space_between_top_chunk_and_first_fin-cr8_hotend_heatsink_fin_thickness/2]) {
          for(i=[0:5]) {
            translate([0,0,-i*cr8_hotend_heatsink_fin_spacing]) {
              linear_extrude(height=cr8_hotend_heatsink_fin_thickness,center=true,convexity=3) {
                heatsink_profile();
              }
            }
          }
        }
      }

      translate([0,0,-cr8_hotend_heatsink_height]) {
        hull() {
          translate([0,0,0.1]) {
            hole(cr8_hotend_heatsink_thickness-0.2,0.2,resolution);
          }
          translate([0,0,20]) {
            hole(cr8_hotend_heatsink_thickness-4.5,0.2,resolution);
          }
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      for(dist=[cr8_hotend_inner_hole_spacing,cr8_hotend_outer_hole_spacing]) {
        translate([x*(dist/2),0,0]) {
          rotate([90,0,0]) {
            hole(3.2,cr8_hotend_heatsink_thickness+1,resolution);
          }
        }
      }
    }
  }

  color("#eee") {
    difference() {
      body();
      holes();
    }
  }
}

// cr8_hotend();
