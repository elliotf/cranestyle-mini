include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;

idler = false;

module end_cap() {
  module body() {
    translate([-40+end_cap_extrusion_width_to_cover/2,front*end_cap_thickness/2,-end_cap_height/2+20/2]) {
      rotate([90,0,0]) {
        rounded_cube(end_cap_width,end_cap_height,end_cap_thickness,end_cap_overhang*2);
      }
    }

    if (idler) {
      translate([y_idler_pos_x,y_idler_dist_y_from_extrusion,20/2]) {
        hull() {
          hole(m5_thread_into_hole_diam+extrude_width*2,y_idler_dist_z_from_extrusion*2,resolution);
          translate([0,0,-1]) {
            hole(end_cap_thickness,2,resolution);
          }
        }
      }
    }
  }

  module holes() {
    // idler hole
    if (idler) {
      translate([-40+50,-end_cap_thickness/2,0]) {
        hole(m5_thread_into_hole_diam,60,resolution);
      }
    }
    
    // end_cap_extrusion mounting holes
    for(x=[10,30,70,90]) {
      translate([-40+x,-end_cap_thickness+0.5,0]) {
        rotate([-90,0,0]) {
          hole(m5_loose_diam,end_cap_thickness*2+1,resolution);

          // countersink heads
          hull() {
            hole(m5_loose_diam,m5_fsc_head_diam-m5_loose_diam,resolution);
            translate([0,0,-1]) {
              hole(m5_fsc_head_diam,2,resolution);
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
}

module end_cap_front() {
  end_cap();
}

module end_cap_rear() {
  mirror([0,1,0]) {
    end_cap();
  }
}
