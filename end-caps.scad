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
cavity_depth = end_cap_thickness - end_cap_thickness_to_leave_from_cavity;
cavity_rounded = end_cap_rounded_diam-(end_cap_width-cavity_width);

module end_cap(end=front) {
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

    translate([end_cap_offset_x,0,20/2-end_cap_height+cavity_height/2+wall_thickness*2]) {
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
  end_cap(front);
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
t_slot_opening = 6.1; // slightly different from v slot
cover_wall_thickness = 0.5*2; // FIXME: too thin?
cover_inset_from_end_cap_dimensions = extrude_width*4;
cover_rounded_diam = end_cap_rounded_diam-cover_inset_from_end_cap_dimensions*2;
cover_width = end_cap_width-cover_inset_from_end_cap_dimensions*2;
cover_top_pos = t_slot_opening/2; // FIXME: make it the top of the slot gap
cover_bottom_pos = bottom*(end_cap_height-20/2-cover_inset_from_end_cap_dimensions);
cover_height = cover_top_pos-cover_bottom_pos;
cover_hook_height_inside = 2.25;
cover_hook_height = cover_hook_height_inside+cover_wall_thickness;

module electronics_cover() {
  t_slot_depth = 6;
  t_slot_flange_thickness = 2; // FIXME: measure IRL

  center_pos_x = -50+y_extrusion_width/2;

  module electronics_cover_profile() {
    inner_width = cover_width - cover_wall_thickness*2;
    inner_height = cover_height - cover_wall_thickness*2;
    inner_diam = cover_rounded_diam-cover_wall_thickness*2;

    module body() {
      translate([0,cover_top_pos-cover_height/2]) {
        rounded_square(cover_width,cover_height,cover_rounded_diam,resolution);
      }
    }

    module holes() {
      hull() {
        for(x=[left,right]) {
          translate([center_pos_x-x*(y_extrusion_width/2-t_slot_flange_thickness-1-cover_wall_thickness/2),0,0]) {
            square([2,20],center=true);
          }
        }
      }

      translate([0,cover_top_pos-cover_height/2]) {
        rounded_square(inner_width,inner_height,inner_diam,resolution);
      }
    }

    module bridges() {
      // FIXME: make corrugations to improve stiffness
      for (x=[left,right]) {
        translate([center_pos_x+x*y_extrusion_width/2,cover_top_pos-cover_wall_thickness/2,0]) {
          mirror([1-x,0,0]) {
            hull() {
              translate([left*(t_slot_flange_thickness+cover_wall_thickness/2),0,0]) {
                translate([left*((t_slot_depth-t_slot_flange_thickness)/2-cover_wall_thickness/2),0,0]) {
                  rounded_square(t_slot_depth-t_slot_flange_thickness,cover_wall_thickness,cover_wall_thickness);
                }
                translate([0,cover_hook_height/2-cover_wall_thickness/2,0]) {
                  rounded_square(cover_wall_thickness,cover_hook_height,cover_wall_thickness);
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
      linear_extrude(height=150-tolerance*3,center=true,convexity=5) {
        electronics_cover_profile();
      }
    }
  }

  module tapered_hook_hole(width) {
    mult = 2.25;

    trim_hook_tip_width = y_extrusion_width-t_slot_flange_thickness*2;
    trim_hook_tip_depth = width;
    trim_hook_tip_height = cover_hook_height_inside;

    trim_hook_base_width = y_extrusion_width-t_slot_depth*2;
    trim_hook_base_depth = trim_hook_tip_depth-(t_slot_depth-t_slot_flange_thickness)*mult;

    end_cap_and_cover_rounded_difference = end_cap_rounded_diam - cover_rounded_diam;

    trim_hook_entrance_height = t_slot_depth;
    trim_hook_entrance_width = trim_hook_base_width+trim_hook_entrance_height*2;
    trim_hook_entrance_depth = trim_hook_base_depth-trim_hook_entrance_height*mult;

    translate([0,0,cover_top_pos]) {
      // trim hook tops
      hull() {
        translate([0,0,cover_hook_height_inside+1]) {
          cube([trim_hook_tip_width+1,trim_hook_tip_depth,2],center=true);
        }
        translate([0,0,1]) {
          cube([trim_hook_tip_width,trim_hook_base_depth,2],center=true);
        }
      }

      translate([0,0,-cover_wall_thickness]) {
        hull() {
          cube([trim_hook_base_width,trim_hook_base_depth,2],center=true);
          cube([trim_hook_entrance_width,trim_hook_entrance_depth,2],center=true);
        }
      }

      rotated_base_depth = trim_hook_entrance_depth;
      rotated_taper_dist = cover_rounded_diam/2*mult;
      for(x=[right]) {
        mirror([1-x,0,0]) {

          translate([x*cover_width/2-cover_rounded_diam/2,0,-cover_rounded_diam/2]) {
            num_steps = 15;
            step_angle = 90 / num_steps;
            rotate([90,0,0]) {
              for(i=[0:num_steps-1]) {
                hull() {
                  rotate([0,0,-i*step_angle]) {
                    cube([0.1,cover_rounded_diam+1,rotated_base_depth-i*(rotated_taper_dist/num_steps)],center=true);
                  }

                  next = i+1;
                  rotate([0,0,-next*step_angle]) {
                    cube([0.1,cover_rounded_diam+1,rotated_base_depth-next*(rotated_taper_dist/num_steps)],center=true);
                  }
                }
              }
            }
          }
        }
      }

      flat_side_taper_base_depth = rotated_base_depth-rotated_taper_dist+0.1;
      flat_side_access_space = 4;
      flat_side_access_taper_dist = flat_side_access_space*mult;
      translate([0,0,-cover_rounded_diam/2]) {
        hull() {
          translate([0,0,1]) {
            cube([cover_width+1,flat_side_taper_base_depth,2],center=true);
          }
          translate([0,0,-flat_side_access_space+1]) {
            cube([cover_width+1,flat_side_taper_base_depth-flat_side_access_taper_dist,2],center=true);
          }
        }
      }
    }
  }

  module holes() {
    num_hooks = 2;
    hook_tab_depth = 30;

    available_open_depth = 150 - hook_tab_depth*num_hooks;
    per_open_depth = available_open_depth/(num_hooks-1);

    for(x=[left,right]) {
      mirror([1-x,0,0]) {
        for(y=[1:(num_hooks-1)]) {
          translate([center_pos_x,front*(150/2)-per_open_depth/2+y*(hook_tab_depth+per_open_depth),0]) {
            tapered_hook_hole(per_open_depth);
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

    // color("green") electronics_cover();
  }
}

translate([0,0,-10]) {
  rotate([90,0,0]) {
    % color("lightgrey") extrusion(20,y_extrusion_width,150);
  }
}

end_cap_assembly();
