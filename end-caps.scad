include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;
use <./duet-wifi-mount.scad>;

end_cap_thickness_to_leave_from_cavity = 0.2*6; // 6 extrusion layers 0.2 thick, or 4 extrusion layers 0.3 thick -- enough?

y_idler_screw_hole_length = 28;
duet_mounting_hole_offset_y = end_cap_thickness-duet_hole_from_end-(duet_overall_length-duet_length)-end_cap_thickness_to_leave_from_cavity-1; // mounting hole relative to extrusion edge
duet_mounting_hole_offset_z = -20/2-duet_mount_thickness-duet_mount_bevel_height-tolerance/2;

end_cap_rim_width = wall_thickness*2;

cavity_width = end_cap_width - end_cap_rim_width*2;
cavity_height = abs(end_cap_height - extrusion_width/2 - end_cap_rim_width) - abs(duet_mounting_hole_offset_z);
default_cavity_depth = end_cap_thickness - end_cap_thickness_to_leave_from_cavity;
cavity_rounded = end_cap_rounded_diam-(end_cap_width-cavity_width);
cavity_pos_z = 20/2-end_cap_height+cavity_height/2+wall_thickness*2;

module end_cap(cavity_depth=default_cavity_depth) {
  y_idler_screw_shoulder_pos_z = 20/2+y_idler_dist_z_from_extrusion+gt2_toothed_idler_height;

  module body() {
    translate([end_cap_offset_x,front*end_cap_thickness/2,-end_cap_height/2+20/2]) {
      rotate([90,0,0]) {
        rounded_cube(end_cap_width,end_cap_height,end_cap_thickness,end_cap_overhang*2);
      }
    }

    if (y_idler_in_endcap) {
      translate([-end_cap_pos_x+y_idler_pos_x,y_idler_dist_y_from_extrusion,20/2]) {
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
    if (y_idler_in_endcap) {
      translate([-end_cap_pos_x+y_idler_pos_x,-end_cap_thickness/2,y_idler_screw_shoulder_pos_z-y_idler_screw_hole_length/2]) {
        hole(m5_thread_into_hole_diam,y_idler_screw_hole_length+1,resolution);
      }
    }
    
    // end cap extrusion mounting holes
    intersection() {
      for(x=[-60,-40,-20,20,40,60]) {
        translate([-end_cap_pos_x+y_idler_pos_x+x,-end_cap_thickness,0]) {
          rotate([-90,0,0]) {
            echo("EXTRUSION END CAP MOUNT: FCS M6 x ", end_cap_thickness+5);
            if (y_extrusion_width == 80) {
              m5_countersink_screw(end_cap_thickness+1);
            } else {
              m6_countersink_screw(end_cap_thickness+1);
            }
          }
        }
      }
    }

    translate([end_cap_offset_x,0,cavity_pos_z]) {
      rotate([90,0,0]) {
        rounded_cube(cavity_width,cavity_height,cavity_depth*2,cavity_rounded,resolution);
      }
    }

    // trim the bottom to be able to see better
    translate([end_cap_offset_x,0,-10-end_cap_height/2]) {
      // cube([end_cap_width*2,end_cap_thickness*4,25],center=true);
    }
  }

  difference() {
    body();
    holes();
  }
}

module end_cap_front() {
  module body() {
    end_cap(default_cavity_depth/2);
  }

  module holes() {
    // vent holes
    num_holes = 6;
    hole_width = 4;
    hole_height = cavity_height-4;
    spacing = (cavity_width) / (num_holes);

    start = (num_holes % 2) ? 0 : 1;
    initial = (num_holes % 2) ? 0 : spacing/2;
    echo("start: ", start);

    rotate([90,0,0]) {
      linear_extrude(height=end_cap_thickness*3,convexity=3,center=true) {
        for(x=[left,right]) {
          for(i=[start:floor(num_holes/2)]) {
            translate([end_cap_offset_x+x*(i*spacing-initial),cavity_pos_z]) {
              rounded_square(hole_width,hole_height,hole_width);
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

module end_cap_rear() {
  duet_port_access_hole_width = 40;
  duet_port_access_hole_height = 11;
  duet_port_access_hole_offset_x = -duet_width/2+duet_port_access_hole_width/2+33;

  power_plug_hole_diam = 11;
  power_plug_bevel_height = 2;
  power_plug_bevel_id = 13.5;
  power_plug_bevel_od = power_plug_bevel_id;
  power_plug_body_diameter = power_plug_hole_diam+extrude_width*4*2 + 6; // make it easier to screw hex nut on // FIXME: make this based on the max OD of the hex nut?
  power_plug_area_thickness = 4;

  power_plug_pos_x = left*(end_cap_width/2-end_cap_rim_width-power_plug_body_diameter/2)+end_cap_offset_x;
  power_plug_pos_y = end_cap_thickness;
  power_plug_pos_z = 10-end_cap_height+end_cap_rim_width+power_plug_body_diameter/2;

  wire_hole_wall_depth = 3;
  wire_hole_wall_thickness = wall_thickness*2;
  wire_hole_width = duet_port_access_hole_width;
  wire_hole_height = 6; // silicone rectangular tubing is 14mm wide by ~4.5mm thick
  wire_hole_pos_x = duet_port_access_hole_offset_x;
  wire_hole_pos_y = end_cap_thickness-wire_hole_wall_depth/2;
  wire_hole_pos_z = power_plug_pos_z;
  wire_hole_strain_relief_post_height = end_cap_thickness*1.5;

  module body() {
    mirror([0,1,0]) {
      end_cap();
    }

    mount_body_diam = m3_thread_into_hole_diam+wall_thickness*4;
    mount_height = duet_mount_thickness + duet_mount_bevel_height;

    translate([0,0,duet_mounting_hole_offset_z+mount_height/2]) {
      rounded_cube(duet_hole_spacing_x+mount_body_diam,abs(duet_mounting_hole_offset_y*2)+mount_body_diam,mount_height,mount_body_diam);
    }

    // power plug area
    translate([power_plug_pos_x,power_plug_pos_y,power_plug_pos_z]) {
      translate([0,-power_plug_bevel_height/2-power_plug_area_thickness/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=power_plug_area_thickness+power_plug_bevel_height,center=true,convexity=3) {
            difference() {
              square([power_plug_body_diameter,power_plug_body_diameter],center=true);
              translate([power_plug_body_diameter/2,power_plug_body_diameter/2]) {
                rotate([0,0,180]) {
                  round_corner_filler_profile(power_plug_body_diameter,resolution);
                }
              }
            }
            translate([-power_plug_body_diameter/2,power_plug_body_diameter/2]) {
              round_corner_filler_profile(cavity_rounded,resolution);
            }
            translate([power_plug_body_diameter/2,-power_plug_body_diameter/2]) {
              round_corner_filler_profile(cavity_rounded,resolution);
            }
          }
        }
      }
    }

    // wire holes for X stepper, extruder stepper, maybe Y endstop
    translate([wire_hole_pos_x,0,wire_hole_pos_z]) {
      translate([0,wire_hole_pos_y,0]) {
        rotate([90,0,0]) {
          rounded_cube(wire_hole_width+wire_hole_wall_thickness*2,wire_hole_height+wire_hole_wall_thickness*2,wire_hole_wall_depth,wire_hole_wall_thickness);
        }
      }
      // brace to zip tie things against for strain relief
      num_posts = 5;
      space_between_posts = 2;
      post_width = (wire_hole_width+wire_hole_wall_thickness*2-space_between_posts*(num_posts-1)) / num_posts;
      translate([0,rear*(end_cap_thickness-wire_hole_strain_relief_post_height),wire_hole_height/2+wire_hole_wall_thickness/2]) {
        translate([0,1,0]) {
          rotate([90,0,0]) {
            rounded_cube(wire_hole_width+wire_hole_wall_thickness*2,wire_hole_wall_thickness,2,wire_hole_wall_thickness);
          }
        }
        translate([left*(wire_hole_width/2+wire_hole_wall_thickness),rear*(wire_hole_strain_relief_post_height/2),0]) {
          for(x=[0:num_posts-1]) {
            translate([post_width/2+x*(post_width+space_between_posts),0,0]) {
              rotate([90,0,0]) {
                rounded_cube(post_width,wire_hole_wall_thickness,wire_hole_strain_relief_post_height,wire_hole_wall_thickness);
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    // hole to access duet wifi ports, maybe too small for a usb cable, but useful for microSD card access in a bind
    hull() {
      rounded_diam = 4;
      bottom_of_board_to_center_of_usb = 3.1;
      height_difference = duet_port_access_hole_height/2-bottom_of_board_to_center_of_usb; // try to center on usb connector
      translate([duet_port_access_hole_offset_x,duet_mounting_hole_offset_y+duet_hole_from_end,duet_mounting_hole_offset_z-bottom_of_board_to_center_of_usb]) {
        rotate([90,0,0]) {
          rounded_cube(duet_port_access_hole_width-bottom_of_board_to_center_of_usb*2,bottom_of_board_to_center_of_usb*2,height_difference*2,1,resolution);
        }

        translate([0,end_cap_thickness/2,0]) {
          rotate([90,0,0]) {
            rounded_cube(duet_port_access_hole_width,duet_port_access_hole_height,end_cap_thickness,duet_port_access_hole_height,resolution);
          }
        }
      }
    }

    for(x=[left,right]) {
      translate([x*duet_hole_spacing_x/2,duet_mounting_hole_offset_y,duet_mounting_hole_offset_z]) {
        hole(m3_thread_into_hole_diam,2*(duet_mount_bevel_height+duet_mount_thickness)-extrude_width*4,resolution);
      }
    }

    translate([power_plug_pos_x,power_plug_pos_y,power_plug_pos_z]) {
      rotate([-90,0,0]) {
        translate([0,0,-end_cap_thickness/2-power_plug_bevel_height-0.2]) {
          hole(power_plug_hole_diam,end_cap_thickness,resolution);
        }

        hull() {
          hole(power_plug_bevel_id,power_plug_bevel_height*2,resolution);
          translate([0,0,1]) {
            hole(power_plug_bevel_od,2,resolution);
          }
        }
      }
    }

    // cut off half to see cross section
    translate([-y_extrusion_width/2+10+y_idler_pos_x+end_cap_width/2,0,0]) {
      // color("red") cube([end_cap_width,end_cap_width,end_cap_width],center=true);
    }

    translate([wire_hole_pos_x,end_cap_thickness-wire_hole_strain_relief_post_height/2,wire_hole_pos_z]) {
      cube([wire_hole_width,end_cap_thickness*3,wire_hole_height],center=true);
    }
  }

  difference() {
    body();
    holes();
  }
}

// TODO/FIXME: add some sort of peg/brace on the end caps for this cover to brace/index against?
//   pins in the two bottom corners, or some sort of brace along the bottom along the entire width?
cover_wall_thickness = end_cap_overhang;
cover_inset_from_end_cap_dimensions = 0;
cover_rounded_diam = end_cap_rounded_diam-cover_inset_from_end_cap_dimensions*2;
cover_width = end_cap_width-cover_inset_from_end_cap_dimensions*2;
cover_top_height = extrusion_width;
cover_top_pos = cover_top_height/2;
cover_bottom_pos = bottom*(end_cap_height-extrusion_width/2-cover_inset_from_end_cap_dimensions);
cover_height = cover_top_pos-cover_bottom_pos;
cover_length = 150-tolerance*3;

module electronics_cover() {
  t_slot_depth = 6;
  t_slot_flange_thickness = 2; // FIXME: measure IRL

  center_pos_x = -50+y_extrusion_width/2;

  y_endstop_clearance_y = extrusion_width;
  y_endstop_clearance_z = extrusion_width-1.5;

  extrusion_opening_width = y_extrusion_width+tolerance*2;

  screw_mount_width = m3_fsc_head_diam*3;
  wire_allowance = 4;

  inner_width = cover_width - cover_wall_thickness*2;
  inner_height = abs(cover_bottom_pos)-cover_wall_thickness-cover_top_height/2;
  inner_diam = cover_rounded_diam-cover_wall_thickness*2;

  cover_left_width = cover_width/2-end_cap_offset_x - extrusion_opening_width/2;

  module wire_allowance_gap(length=wire_allowance,width=wire_allowance) {
    hull() {
      cube([width*2,length,extrusion_width*2],center=true);
      translate([20,width/2+5,0]) {
        cube([20,length+width+10,extrusion_width*2],center=true);
      }
    }
  }

  module electronics_cover_profile() {
    module body() {
      translate([end_cap_offset_x,cover_top_pos-cover_height/2]) {
        rounded_square(cover_width,cover_height,cover_rounded_diam,resolution);
      }
    }

    module holes() {
      translate([center_pos_x,0,0]) {
        square([extrusion_opening_width,extrusion_width+5],center=true);
      }

      translate([end_cap_offset_x,cover_bottom_pos+cover_wall_thickness+inner_height/2]) {
        rounded_square(inner_width,inner_height,cover_wall_thickness/2,resolution);
      }

      translate([center_pos_x-extrusion_opening_width/2,cover_top_pos-cover_top_height/2,0]) {
        for(z=[top,bottom]) {
          translate([0,z*cover_top_height/2]) {
            rotate([0,0,135+z*45]) {
              round_corner_filler_profile(cover_wall_thickness/2);
            }
          }
        }
      }
    }

    module bridges() {
      for(x=[left,right]) {
        rounded_diam = 3;
        tab_depth = 4.25; // don't want to make it too long, because I don't know how much flex there is in the cover
        tab_width = 5.6;
        translate([center_pos_x+x*(extrusion_opening_width/2),0,0]) {
          translate([x*(-tab_depth/2+rounded_diam/2),0,0]) {
            rounded_square(tab_depth+rounded_diam,tab_width,rounded_diam,resolution);
          }

          for(z=[top,bottom]) {
            translate([0,z*tab_width/2]) {
              mirror([1-x,0,0]) {
                rotate([0,0,135-z*45]) {
                  round_corner_filler_profile(cover_wall_thickness/2);
                }
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
    bridges();
  }

  module body() {
    rotate([90,0,0]) {
      linear_extrude(height=cover_length,center=true,convexity=5) {
        electronics_cover_profile();
      }
    }
  }

  module holes() {
    // y endstop clearance
    translate([center_pos_x+extrusion_opening_width/2,150/2,extrusion_width/2]) {
      cube([extrusion_opening_width,y_endstop_clearance_y*2,y_endstop_clearance_z*2],center=true);
    }

    // X- side wire passthroughs
    translate([center_pos_x-extrusion_opening_width/2,0,0]) {
      // Z endstop, maybe X and E0 motors
      translate([0,150/2,0]) {
        wire_allowance_gap(2*25);
      }

      // Z motor and X carriage bundle
      dist_between_y_and_z_motors = 22;
      translate([0,rear*(150/2-40-mgn12c_surface_above_surface+leadscrew_pos_y-nema14_side/2-dist_between_y_and_z_motors/2),0]) {
        wire_allowance_gap(dist_between_y_and_z_motors);
      }

      // Y motor cable
      translate([0,front*(150/2),0]) {
        wire_allowance_gap(wire_allowance*2.25);
      }
    }

    // X+ side mounting screws
    num_screws = 3;

    space_width = (cover_length - y_endstop_clearance_y - screw_mount_width*3) / (num_screws-1);
    max_side_hole_positions = [
      -150/2+screw_mount_width/2,
      -150/2+screw_mount_width/2+1*(space_width+screw_mount_width),
      -150/2+screw_mount_width/2+2*(space_width+screw_mount_width),
    ];
    for(y=max_side_hole_positions) {
      translate([0,y,0]) {
        translate([0,0,0]) {
          translate([center_pos_x+extrusion_opening_width/2-wire_allowance,0,0]) {
            mirror([1,0,0]) {
              wire_allowance_gap(12);
            }
          }
        }
        translate([end_cap_offset_x+cover_width/2,0,0]) {
          rotate([0,90,0]) {
            m3_countersink_screw(10);
          }
        }
      }
    }

    // X- side mounting screws
    min_side_hole_positions = [
      150/2-(extrusion_width*1.75),
      10,
      front*(150/2-nema14_side*0.75),
    ];
    for(y=min_side_hole_positions) {
      translate([0,y,0]) {
        translate([center_pos_x-extrusion_opening_width/2+wire_allowance,0,0]) {
          wire_allowance_gap(12);
        }
        translate([end_cap_offset_x-cover_width/2,0,0]) {
          rotate([0,90,0]) {
            m3_countersink_screw(cover_left_width+5);
          }
        }
      }
    }
  }

  color("green") difference() {
    body();
    holes();
  }
}

module end_cap_assembly() {
  translate([0,0,-20/2]) {
    translate([0,150/2,0]) {
      end_cap_rear();
    }
    translate([0,-150/2,0]) {
      end_cap_front();
    }

    // duet wifi
    translate([0,150/2-duet_hole_spacing_y/2+duet_mounting_hole_offset_y,duet_mounting_hole_offset_z-0.1]) {
      rotate([180,0,0]) {
        rotate([90,0,90]) {
          % color("#3d526d") import("./lib/duet-pcb-binary-format.stl");
        }
      }

      translate([0,-duet_hole_spacing_y/2,duet_mount_thickness/2+duet_mount_bevel_height+0.2]) {
        mirror([0,1,0]) {
          long_clamp();
        }
      }
    }

    electronics_cover();
  }
}

translate([0,0,-10]) {
  rotate([90,0,0]) {
    % color("lightgrey") extrusion(20,y_extrusion_width,150);
  }
}

end_cap_assembly();
