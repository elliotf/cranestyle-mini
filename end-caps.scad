include <./config.scad>;
include <./lib/util.scad>;
include <./lib/vitamins.scad>;
use <./duet-wifi-mount.scad>;

end_cap_thickness_to_leave_from_cavity = 0.2*6; // 6 extrusion layers 0.2 thick, or 4 extrusion layers 0.3 thick -- enough?

y_idler_screw_hole_length = 28;
duet_mounting_hole_offset_y = end_cap_thickness-duet_hole_from_end-(duet_overall_length-duet_length)-end_cap_thickness_to_leave_from_cavity-1; // mounting hole relative to extrusion edge
duet_mounting_hole_offset_z = -20/2-duet_mount_thickness-duet_mount_bevel_height-tolerance/2;

end_cap_rim_width = wall_thickness*2;

cover_wall_thickness = extrude_width*4;
cover_wall_brances_num = 3;
cover_wall_dist = (150+2*(end_cap_thickness-cover_wall_thickness))/(cover_wall_brances_num+1);
cover_wall_braces_pos_y = [cover_wall_dist,0,-cover_wall_dist];

cavity_width = end_cap_width - end_cap_rim_width*2;
cavity_height = abs(end_cap_height - extrusion_width/2 - end_cap_rim_width) - abs(duet_mounting_hole_offset_z);
default_cavity_depth = end_cap_thickness - end_cap_thickness_to_leave_from_cavity;
cavity_rounded = end_cap_rounded_diam-(end_cap_width-cavity_width);
cavity_pos_z = 20/2-end_cap_height+cavity_height/2+wall_thickness*2;

hbp_cabling_position_x = 10; // TODO?  pull from the same place as the Y carriage tab
hbp_cabling_position_z = -extrusion_width/2-15;
hbp_cabling_hole_width = 14;
hbp_cabling_hole_height = 8;

attachment_screw_positions_x = [
  -y_extrusion_width/2+0,
  -y_extrusion_width/2+40,
  -y_extrusion_width/2+80+2.5,
];

module end_cap(cavity_depth=default_cavity_depth) {
  y_idler_screw_shoulder_pos_z = 20/2+y_idler_dist_z_from_extrusion+gt2_toothed_idler_height;

  module body() {
    translate([end_cap_offset_x,front*end_cap_thickness/2,-end_cap_height/2+20/2]) {
      rotate([90,0,0]) {
        linear_extrude(height=end_cap_thickness,center=true,convexity=1) {
          rounded_square(end_cap_width,end_cap_height,end_cap_overhang*2);
        }
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

    // cut endcap in half to show all the vertical holes
    translate([0,front*end_cap_thickness,0]) {
      //cube([200,end_cap_thickness,200],center=true);
    }

    // holes for threaded inserts to bolt the bottom to the ends
    for(x=attachment_screw_positions_x) {
      translate([x,front*end_cap_thickness/2,extrusion_width/2]) {
        m3_countersink_screw(end_cap_height+1);
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
  power_plug_hole_diam = 11;
  power_plug_bevel_height = 2;
  power_plug_bevel_id = 13.5;
  power_plug_bevel_od = power_plug_bevel_id;
  power_plug_body_diameter = power_plug_hole_diam+extrude_width*4*2; // make it easier to screw hex nut on // FIXME: make this based on the max OD of the hex nut?
  power_plug_area_thickness = 4;

  power_plug_pos_x = left*(end_cap_width/2-end_cap_height/2)+end_cap_offset_x;
  power_plug_pos_y = end_cap_thickness;
  power_plug_pos_z = 0;

  module body() {
    mirror([0,1,0]) {
      end_cap();
    }

    rounded_diam = 3;
    tab_width = hbp_cabling_hole_width-3;
    translate([hbp_cabling_position_x,end_cap_thickness/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(height=end_cap_thickness,center=true,convexity=2) {
          for(x=[left,right]) {
            translate([x*tab_width/2,-extrusion_width/2,0]) {
              rotate([0,0,225+x*45]) {
                # round_corner_filler_profile(rounded_diam,resolution);
              }
            }
          }
          hull() {
            translate([0,-extrusion_width/2,0]) {
              square([tab_width,1],center=true);
            }
            translate([0,hbp_cabling_position_z+hbp_cabling_hole_height/2+rounded_diam/2,0]) {
              rounded_square(tab_width,rounded_diam,rounded_diam);
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([power_plug_pos_x,power_plug_pos_y,power_plug_pos_z]) {
      rotate([-90,0,0]) {
        hole(power_plug_bevel_id,power_plug_bevel_height*2,resolution);

        translate([0,0,-end_cap_thickness/2-power_plug_bevel_height-0.2]) {
          hole(power_plug_hole_diam,end_cap_thickness,resolution);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

cover_wall_slot_width = cover_wall_thickness + tolerance*2;
cover_wall_slot_height = 2+tolerance;

module cover_wall_brace_profile(side) {
  anchor_side = end_cap_overhang;

  module body() {
    hull() {
      translate([left*(anchor_side/2),-end_cap_height/2+anchor_side/2,0]) {
        square([anchor_side,anchor_side],center=true);
      }
      translate([left*(cover_wall_thickness/2),-end_cap_height/2,0]) {
        rounded_square(cover_wall_slot_width+extrude_width*4,cover_wall_slot_height*2,1);
      }
    }
  }

  module holes() {
    translate([left*(cover_wall_thickness/2),bottom*(end_cap_height/2+cover_wall_slot_height),0]) {
      // % square([cover_wall_thickness,2*2],center=true);
      rounded_square(cover_wall_slot_width,(cover_wall_slot_height)*2,extrude_width*2);
      for(x=[left,right]) {
        translate([x*(cover_wall_slot_width/2),0,0]) {
          rotate([0,0,45-x*45]) {
            round_corner_filler_profile(extrude_width*2,resolution);
          }
        }
      }
    }
  }

  mirror([1-side,0,0]) {
    difference() {
      body();
      holes();
    }
  }
}

module cover_wall_brace_holes(side) {
  height = 20;
  width = 20;
  mirror([side-1,0,0]) {
    // room for wall braces
    for(y=cover_wall_braces_pos_y) {
      translate([left*(width/2+cover_wall_thickness/2),y,-height/2-10]) {
        hull() {
          cube([width,cover_wall_thickness+2*tolerance,height],center=true);

          translate([0,cover_wall_slot_height,-cover_wall_slot_height-tolerance]) {
            cube([width,cover_wall_thickness+2*tolerance+2*(cover_wall_slot_height),height],center=true);
          }
        }
      }
    }
  }
}

t_slot_tab_height = 5;
t_slot_tab_depth = 5;

module x_max_cover() {
  space_to_leave_for_y_endstop = 18;
  length = 150 - space_to_leave_for_y_endstop - 0.5;
  rounded_diam = 2;

  t_slot_nut_cavity_room = 12;

  screw_hole_y_positions = [
    front*(length/2-15),
    0,
    rear*(length/2-15),
  ];

  module profile() {
    difference() {
      union() {
        hull() {
          translate([0,extrusion_width/2-end_cap_rounded_diam/2,0]) {
            accurate_circle(end_cap_rounded_diam,resolution);
          }
          translate([0,-extrusion_width/2+1,0]) {
            square([end_cap_rounded_diam,2],center=true);
          }
        }

        translate([end_cap_overhang,0,0]) {
          cover_wall_brace_profile(right);
        }
      }

      translate([-10,0,0]) {
        square([20,40],center=true);
      }
    }

    hull() {
      square([1,t_slot_tab_height],center=true);

      translate([left*(t_slot_tab_depth-rounded_diam/2),0,0]) {
        rounded_square(rounded_diam,t_slot_tab_height,rounded_diam);
      }
    }
  }

  module body() {
    rotate([90,0,0]) {
      linear_extrude(height=length,center=true,convexity=3) {
        profile();
      }
    }
  }

  module holes() {
    translate([end_cap_overhang,0,0]) {
      cover_wall_brace_holes(right);
    }
    for(y=screw_hole_y_positions) {
      translate([0,y,0]) {
        translate([end_cap_overhang,0,0]) {
          rotate([0,90,0]) {
            m3_countersink_screw(20);
          }
        }
        translate([left*10,0,0]) {
          hull() {
            cube([20,t_slot_nut_cavity_room,t_slot_tab_height+1],center=true);

            translate([left*t_slot_tab_depth,t_slot_tab_depth,0]) {
              cube([20,t_slot_nut_cavity_room,t_slot_tab_height+1],center=true);
            }
          }
        }
      }
    }
  }

  translate([0,front*space_to_leave_for_y_endstop/2,0]) {
    difference() {
      body();
      holes();
    }
  }
}

module x_min_cover() {
  rounded_diam = end_cap_rounded_diam;

  wire_allowance = 4;

  width = 20;
  height = 20;

  module wire_allowance_gap(length=wire_allowance,width=wire_allowance) {
    hull() {
      cube([width*2,length,extrusion_width*2],center=true);
      translate([20,width/2+5,0]) {
        cube([20,length+width+10,extrusion_width*2],center=true);
      }
    }
  }

  module profile() {
    module body() {
      hull() {
        translate([left*1,0,0]) {
          square([2,height],center=true);
        }
        translate([left*width/2,-height/2+1,0]) {
          square([width,2],center=true);
        }
        translate([left*(width-end_cap_rounded_diam/2),height/2-end_cap_rounded_diam/2,0]) {
          accurate_circle(end_cap_rounded_diam,resolution);
        }
      }
      translate([left*width/2,0,0]) {
        // rounded_square(width,height,rounded_diam);

        // FIXME: something to hold onto/brace the bottom cover
        //
        translate([left*(width/2),0,0]) {
          cover_wall_brace_profile(left);
        }
      }
      rounded_square(t_slot_tab_depth*2,t_slot_tab_height,2);
      /*
      hull() {
        translate([left*(width-rounded_diam/2),-height/2+rounded_diam/2,0]) {
          accurate_circle(rounded_diam,resolution);
        }
        translate([left*(width-cover_wall_thickness/2),-height/2,0]) {
          rounded_square(cover_wall_slot_width+extrude_width*4,cover_wall_slot_height*2,1);
        }
      }
      */
    }

    module holes() {
      /*
      translate([0,0,0]) {
        translate([left*(width-cover_wall_thickness/2),bottom*(height/2+cover_wall_slot_height),0]) {
          // % square([cover_wall_thickness,2*2],center=true);
          rounded_square(cover_wall_slot_width,(cover_wall_slot_height)*2,extrude_width*2);
          for(x=[left,right]) {
            translate([x*(cover_wall_slot_width/2),0,0]) {
              rotate([0,0,45-x*45]) {
                round_corner_filler_profile(extrude_width*2,resolution);
              }
            }
          }
        }
      }
      */
    }

    difference() {
      body();
      holes();
    }
  }

  module body() {
    rotate([90,0,0]) {
      linear_extrude(height=150-0.5,center=true,convexity=3) {
        profile();
      }
    }
  }

  module holes() {
    // Z endstop, maybe X and E0 motors
    translate([0,150/2,0]) {
      wire_allowance_gap(2*25);
    }

    // Z motor and X carriage bundle
    dist_between_y_and_z_motors = 22;
    translate([0,rear*(150/2-40-mgn12c_surface_above_surface+leadscrew_pos_y-nema14_side/2-dist_between_y_and_z_motors/2),0]) {
      wire_allowance_gap(dist_between_y_and_z_motors);
    }

    translate([0,front*(150/2-55),0]) {
      // room for X carriage wire bundle
      translate([left*(width/2+2),0,height/2]) {
        room_for_silicone_tubing = 15;
        cut_depth = 4;
        rotate([0,-90,0]) {
          wire_allowance_gap(room_for_silicone_tubing,cut_depth);
        }
        // % cube([width,room_for_silicone_tubing,cut_depth*2],center=true);

        // anchors for the X carriage wire bundle clamp
        y_offset = 2;
        for(y=[front,rear]) {
          translate([0,y*(room_for_silicone_tubing/2+m3_threaded_insert_diam/2+extrude_width*4+cut_depth/2)+y_offset,0]) {
            hole(m3_threaded_insert_diam,2*(m3_threaded_insert_len+1),resolution);
            hole(m3_loose_diam+0.25,2*(height*0.8),resolution);
          }
        }
      }
    }

    // Y motor cable
    translate([0,front*(150/2),0]) {
      wire_allowance_gap(wire_allowance*2.25);
    }

    // room for power supply cabling
    translate([0,150/2,0]) {
      wall_thickness = extrude_width*4;
      remaining_width = width - wall_thickness;

      translate([0,0,-width/2]) {
        rotate([90,0,0]) {
          rounded_cube(remaining_width*2,remaining_width*2,2*25,end_cap_rounded_diam-wall_thickness*2);
        }
      }
    }

    min_side_hole_positions = [
      150/2-(extrusion_width*1.75),
      10,
      front*(150/2-nema14_side*0.75),
    ];

    for(y=min_side_hole_positions) {
      translate([0,y,0]) {
        translate([wire_allowance,0,0]) {
          wire_allowance_gap(12);
        }
        translate([-width,0,0]) {
          rotate([0,90,0]) {
            m3_countersink_screw(25);
          }
        }
      }
    }

    // room for wall braces
    translate([left*(width),0,0]) {
      cover_wall_brace_holes(left);
    }
    /*
    for(y=cover_wall_braces_pos_y) {
      translate([left*(width/2-cover_wall_thickness/2),y,-height/2-10]) {
        hull() {
          cube([width,cover_wall_thickness+2*tolerance,20],center=true);

          translate([0,cover_wall_slot_height,-cover_wall_slot_height-tolerance]) {
            cube([width,cover_wall_thickness+2*tolerance+2*(cover_wall_slot_height),20],center=true);
          }
        }
      }
    }
    */
  }

  difference() {
    body();
    holes();
  }
}

module bottom_cover() {
  bottom_thickness = 1;

  overall_width = end_cap_width;
  overall_length = 150 + end_cap_thickness*2;
  overall_height = room_below_extrusion_for_electronics + bottom_thickness;

  damping_material_diam = 4; // theraband latex exercise tubes
  //damping_material_diam = 1.8; // TPU/TPE filament
  damping_material_pct_to_expose = 0.22;
  damping_material_pos_z = -overall_height+damping_material_diam/2-damping_material_diam*damping_material_pct_to_expose;
  damping_material_offset_from_edge = cover_wall_thickness*2+damping_material_diam/2;
  damping_material_pos_x = overall_width/2 - damping_material_offset_from_edge;
  damping_material_pos_y = overall_length/2 - damping_material_offset_from_edge;
  damping_material_rounded_diam = 13;

  cavity_width = overall_width-cover_wall_thickness*2;
  cavity_length = overall_length-cover_wall_thickness*2;
  cavity_depth = overall_height - bottom_thickness;
  cavity_angle_height = 4;

  m3_very_loose_diam = 3 + 0.6;

  attachment_mount_body_diam = m3_threaded_insert_diam+2*(extrude_width*4);
  attachment_mount_body_len = m3_threaded_insert_len+5+attachment_mount_body_diam;

  module outer_body_profile() {
    rounded_square(overall_width,overall_length,end_cap_overhang*2);
  }

  module body() {
    translate([end_cap_offset_x,0,0]) {
      difference() {
        translate([0,0,-overall_height/2]) {
          rounded_cube(overall_width,overall_length,overall_height,end_cap_overhang*2);
        }
        tolerance_for_damping_materal_holder = damping_material_offset_from_edge+damping_material_diam/2+cover_wall_thickness;
        translate([0,0,-cavity_depth/2+0.1]) {
          rounded_cube(overall_width-2*tolerance_for_damping_materal_holder,overall_length-2*tolerance_for_damping_materal_holder,cavity_depth+0.2,5);
        }
        straight_wall_depth = cavity_depth - cavity_angle_height;
        translate([0,0,-straight_wall_depth/2+0.1]) {
          rounded_cube(cavity_width,cavity_length,straight_wall_depth+0.2,end_cap_overhang*2-(cover_wall_thickness*2));
        }
      }
    }

    difference() {
      union() {
        for(x=attachment_screw_positions_x,y=[front,rear]) {
          mirror([0,y-1,0]) {
            translate([x,overall_length/2-end_cap_thickness/2,-attachment_mount_body_len/2]) {
              linear_extrude(height=attachment_mount_body_len,center=true,convexity=3) {
                accurate_circle(attachment_mount_body_diam,resolution);

                translate([0,end_cap_thickness/4,0]) {
                  square([attachment_mount_body_diam,end_cap_thickness/2],center=true);
                }

                for(x=[left,right]) {
                  translate([x*attachment_mount_body_diam/2,end_cap_thickness/2-cover_wall_thickness,0]) {
                    rotate([0,0,-135+x*45]) {
                      round_corner_filler_profile(5);
                    }
                  }
                }
              }
            }
          }
        }
      }
      hull() {
        translate([end_cap_offset_x,0,-overall_height/2-m3_threaded_insert_len-5-attachment_mount_body_diam]) {
          cube([overall_width,cavity_length+0.5,overall_height],center=true);
          translate([0,0,attachment_mount_body_diam]) {
            cube([overall_width,cavity_length-end_cap_thickness-attachment_mount_body_diam,overall_height+1],center=true);
          }
        }
      }
    }

    translate([end_cap_offset_x,0,-overall_height/2]) {
      linear_extrude(height=overall_height,center=true,convexity=3) {
        for(x=[left,right],y=cover_wall_braces_pos_y) {
          mirror([x-1,0,0]) {
            wall_brace_length = end_cap_overhang-cover_wall_thickness;
            translate([overall_width/2-cover_wall_thickness,y,0]) {
              hull() {
                square([1,cover_wall_thickness],center=true);
                translate([left*(wall_brace_length-cover_wall_thickness/2),0,0]) {
                  accurate_circle(cover_wall_thickness,resolution);
                }
              }
              for(y=[front,rear]) {
                translate([0,y*cover_wall_thickness/2,0]) {
                  rotate([0,0,135-y*45]) {
                    round_corner_filler_profile(cover_wall_thickness,resolution);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    // holes for cables, including strain relief
    hole_height = abs(hbp_cabling_position_z)+hbp_cabling_hole_height/2-extrusion_width/2;
    translate([hbp_cabling_position_x,overall_length/2-cover_wall_thickness/2,-hole_height/2+0.1]) {
      // % cube([hbp_cabling_hole_width,cover_wall_thickness,hole_height],center=true);
      linear_extrude(height=hole_height+0.2,center=true,convexity=3) {
        difference() {
          square([hbp_cabling_hole_width+cover_wall_thickness,10],center=true);
          for(x=[left,right]) {
            translate([x*(hbp_cabling_hole_width/2+cover_wall_thickness/2),0,0]) {
              accurate_circle(cover_wall_thickness,resolution);
            }
          }
        }
      }
    }

    // attachment screws
    for(x=attachment_screw_positions_x,y=[front,rear]) {
      translate([x,y*(150/2+end_cap_thickness/2),0]) {
        hole(m3_threaded_insert_diam,2*(m3_threaded_insert_len+1),resolution);
        hole(m3_very_loose_diam,10*2,resolution);
      }
    }

    // damping material holders
    translate([end_cap_offset_x,0,damping_material_pos_z]) {
      for(x=[left,right],y=[front,rear]) {
        translate([0,y*damping_material_pos_y,0]) {
          rotate([0,90,0]) {
            hole(damping_material_diam*1,damping_material_pos_x*2-damping_material_rounded_diam,resolution);
          }
        }
        translate([x*damping_material_pos_x,0,0]) {
          rotate([90,0,0]) {
            hole(damping_material_diam*1,damping_material_pos_y*2-damping_material_rounded_diam,resolution);
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
    translate([0,0,duet_mounting_hole_offset_z-0.1]) {
      rotate([180,0,0]) {
        rotate([90,0,90]) {
          color("#3d526d") import("./lib/duet-pcb-binary-format.stl");
        }
      }

      translate([0,-duet_hole_spacing_y/2,duet_mount_thickness/2+duet_mount_bevel_height+0.2]) {
        mirror([0,1,0]) {
          long_clamp();
        }
      }
    }
  }

  translate([-100/2,0,-extrusion_width/2]) {
    x_min_cover();
  }

  translate([100/2,0,-extrusion_width/2]) {
    x_max_cover();
  }

  translate([0,0,-43-20.5]) {
  // translate([0,0,-20.5]) {
    bottom_cover();
  }
}

/*
module wave(length,depth,num_units) {
  thick = 8;
  spacing = length / num_units;

  for(i = [0:.2:length]) {
    hull() {
      for(i = [i, i + .2]) {
        translate([i, 0, 0]) {
          square([.2, pow(1 + cos(i * 360 / length * num_units), 2)]);
        }
      }
    }
  }
  translate([length/2,depth/2,0]) {
    % square([length,depth],center=true);
  }
  //translate([45, - thick, 0]) square([80, h]);
  //translate([80, 0, 0]) square([80, h + thick]);
}

translate([0,front*150,0]) {
  wave(100,10,5);
}
*/

translate([0,0,-10]) {
  rotate([90,0,0]) {
    % color("lightgrey") extrusion(20,y_extrusion_width,150);
  }
}

end_cap_assembly();
