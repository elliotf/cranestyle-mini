include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;
use <./Pulley_T-MXL-XL-HTD-GT2_N-tooth.scad>;

//if ( profile == 12 ) { pulley ( "GT2 2mm" , GT2_2mm_pulley_dia , 0.764 , 1.494 ); }

module original_y_belt_clamp() {
  B = 20;
  C = 15;
  L = 35;
  L1 = 22;
  W = 27; // MGN carriage width
  h = 12;

  trigger = 10 + 3;

  $fs = .2;
  $fa = 2;

  difference() {
    linear_extrude(4, convexity = 5) difference() {
      offset(1) offset(-2) offset(1) {
        square([W, L], center = true);
        translate([-5, 0, 0]) square([W + 10, L1], center = true);
        //translate([-W/2 - 10 - 17, -L/2 + trigger, 0]) square([W/2 + 10 + 17, L/2 + L1/2 - trigger]);
      }
      for(x = [1, -1], y = [1, -1]) translate([x * B/2, y * C/2, 0]) circle(3 / 2);
      translate([-20, 0, 0]) circle(3 / 2);
    }
  }

  module profile() {
    difference() {
      offset(1) offset(-2) offset(1) {
        translate([-5, 0, 0]) square([W + 10, L1], center = true);
      }
      translate([-20, 0, 0]) circle(3 / 2);
      offset(-.4) offset(.4) {
        square([W + 2, L + 2], center = true);
        for(i = [.5:10], j = [1, -1]) translate([0, 2 * i * j, 0]) square([W + 5, 1], center = true);
      }
    }
  }

  translate([0,0,30]) {
    profile();
  }

  difference() {
    linear_extrude(2 + h, convexity = 5) profile();
    translate([-20, 0, h]) rotate(90) cylinder(r = 6.5/2, h = 10, $fn = 6);
  }
}

top_of_belt_below_mgn = 3.5;
bottom_of_belt_below_mgn = 10.5;
belt_opening_height = abs(bottom_of_belt_below_mgn - top_of_belt_below_mgn);

module belt_clamp() {
  belt_thickness = 0.9;
  y_belt_clamp_width = 12-belt_thickness; // walter has 8
  y_belt_clamp_length = mgn12c_hole_spacing_length+10+wall_thickness*2; // walter has 22
  y_belt_clamp_height = belt_opening_height+0.6;
  // on the X carriage, walter is making room for a 0.8mm tall tooth that is 0.5 at its peak, with 60deg sides, and belt of 0.8mm
  // on the Y carriage, walter is making room for a 1.0mm tall tooth that is 0.422 at its peak, with 60deg sides, and belt of 0.8mm

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
    translate([y_belt_clamp_width/2+belt_thickness/2,0,y_belt_clamp_height/2-belt_opening_height/2]) {
      % color("dimgrey", 0.7) cube([belt_thickness,30,6],center=true);
    }

    translate([-y_belt_clamp_width/2-1,0,y_belt_clamp_height/2]) {
      translate([0,0,1]) {
        % cube([2,1,2],center=true);
      }

      translate([0,0,-y_belt_clamp_height-1.9]) {
        % cube([2,1,0.1],center=true);
      }
    }
  }

  module holes() {
    for(y=[front,rear]) {
      translate([y_belt_clamp_width/2+belt_thickness-7,y*mgn12c_hole_spacing_length/2,0]) {
        translate([0,0,m3_threaded_insert_len+1+0.2]) {
          hole(m3_loose_diam,y_belt_clamp_height,resolution);
        }
        translate([0,0,-y_belt_clamp_height/2]) {
          hole(m3_threaded_insert_diam,(m3_threaded_insert_len+1)*2,resolution);
        }
        /*
        translate([5,0,y_belt_clamp_height]) {
          % color("red") cube([10,2,1],center=true);

          translate([10,0,0]) {
            % color("green") cube([10,2,1],center=true);
          }
        }
        */
      }
    }

    translate([0,0,y_belt_clamp_height/2]) {
      linear_extrude(height=belt_opening_height*2,convexity=3,center=true) {
        belt_profile();
      }
    }
  }

  translate([y_belt_clamp_width/2+0.8+mgn12c_width/2,0,y_belt_clamp_height/2+top_of_belt_below_mgn]) {
    % color("lightgrey") mgn12c();

    translate([-10,0,-mgn12c_surface_above_surface-10]) {
      rotate([90,0,0]) {
        % color("silver") extrusion_2080();
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

belt_clamp();

translate([mgn12c_width/2+0.8+4,35,0]) {
  // original_y_belt_clamp();
}
