include <../lib/util.scad>;

m3_diam = 3;
m3_socket_head_height = 3.25;
m3_socket_head_diam = 5.6;
m3_nut_diam = 5.5;
m3_fsc_head_diam = 6;

m5_diam = 5;
m5_socket_head_height = 6;
m5_socket_head_diam = 9;
m5_nut_diam = 8;
m5_fsc_head_diam = 10;

m6_diam = 6;
m6_socket_head_height = 7;
m6_nut_diam = 0;
m6_fsc_head_diam = 12;

m2_threaded_insert_diam = 3.4;
m2_threaded_insert_height = 3;
m2_5_threaded_insert_diam = 3.6;
m3_threaded_insert_diam = 5.4;
m3_threaded_insert_len = 4;

byj_body_diam = 28;
byj_height = 19.5; // body is 19, but flanges stick up

byj_shaft_diam = 5.2;
byj_flange_width = 42;
byj_flange_diam = 7;
byj_flange_thickness = 0.8;
byj_flange_hole_diam = 4.2;
byj_hole_spacing = 35;

byj_shaft_from_center = 8;
byj_shaft_len = 7.9; // varies between 7.9 and 8.5, due to slop in the shaft
byj_shaft_flat_len = 6.1;
byj_shaft_flat_thickness = 3;
byj_shaft_flat_offset = 0;
byj_shaft_flat_cut_depth = (byj_shaft_diam-byj_shaft_flat_thickness)/2;
byj_shoulder_diam = 9.25;
byj_shoulder_height = 1.7; // what drawings say.  Actual measurement is 1.6

byj_hump_height = 16.8;
byj_hump_width = 15;
byj_hump_depth = 17-byj_body_diam/2;

module countersink_screw(actual_shaft_diam,head_diam,head_depth,length) {
  loose_tolerance = 0.4;
  shaft_hole_diam = actual_shaft_diam + loose_tolerance;

  hole(shaft_hole_diam,length*2,resolution);
  diff = head_diam-shaft_hole_diam;
  hull() {
    hole(shaft_hole_diam,diff+head_depth*2,resolution);
    hole(head_diam,head_depth*2,resolution);
  }
}

module m3_countersink_screw(length) {
  countersink_screw(3,m3_fsc_head_diam,0.5,length);
}

module m5_countersink_screw(length) {
  countersink_screw(5,m5_fsc_head_diam,0.5,length);
}

module m6_countersink_screw(length) {
  countersink_screw(6,m6_fsc_head_diam,0.5,length);
}

module line_bearing(resolution=16) {
  module profile() {
    difference() {
      translate([line_bearing_diam/4,0]) {
        square([line_bearing_diam/2,line_bearing_thickness], center=true);
      }
      translate([line_bearing_inner/4,0]) {
        square([line_bearing_inner/2,line_bearing_thickness+1], center=true);
      }

      // groove
      translate([line_bearing_diam/2,0,0]) {
        rotate([0,0,0]) {
          accurate_circle(1,6);
        }
      }
    }
  }

  rotate_extrude(convexity=3,$fn=resolution) {
    profile();
  }

  // hole(line_bearing_diam,line_bearing_thickness,resolution);
  // hole(line_bearing_inner,line_bearing_thickness+1,resolution);
}

module stepper28BYJ(shaft_angle) {
  cable_distance_from_face = 1.75;
  cable_diam    = 1;
  num_cables    = 5;
  cable_pos_x   = [-2.4,-1.2,0,1.2,2.4];
  cable_colors  = ["yellow","orange","red","pink","royalblue"];
  cable_spacing = 1.2;
  cable_sample_len = 5;
  cable_opening_width = 7.3;

  module position_at_flange_centers() {
    for(side=[left,right]) {
      translate([side*(byj_hole_spacing/2),0,0]) {
        children();
      }
    }
  }

  color("lightgrey") {
    // main body
    translate([0,0,-byj_height/2]) {
      hole(byj_body_diam,byj_height,resolution*1.25);
    }

    // flanges
    translate([0,0,-byj_flange_thickness/2]) {
      linear_extrude(height=byj_flange_thickness,center=true,convexity=3) {
        difference() {
          hull() {
            position_at_flange_centers() {
              accurate_circle(byj_flange_diam,resolution/2);
            }
          }
          position_at_flange_centers() {
            accurate_circle(byj_flange_hole_diam,resolution/2);
          }
        }
      }
    }

    // shaft base
    translate([0,-byj_shaft_from_center,0]) {
      hole(byj_shoulder_diam,byj_shoulder_height*2,resolution);
    }
  }

  // shaft
  color("gold") {
    translate([0,-byj_shaft_from_center,0]) {
      rotate([0,0,shaft_angle]) {
        difference() {
          hole(byj_shaft_diam,(byj_shaft_len+byj_shoulder_height)*2,resolution);

          translate([0,0,byj_shoulder_height+byj_shaft_len]) {
            for(y=[left,right]) {
              translate([0,y*byj_shaft_diam/2,0]) {
                cube([byj_shaft_diam,byj_shaft_flat_cut_depth*2,byj_shaft_flat_len*2],center=true);
              }
            }
          }
        }
      }
    }
  }

  // hump
  translate([0,byj_body_diam/2,-byj_hump_height/2-0.05]) {
    color("dodgerblue") {
      difference() {
        cube([byj_hump_width,byj_hump_depth*2,byj_hump_height],center=true);

        translate([0,byj_hump_depth,byj_hump_height/2-cable_distance_from_face-cable_diam/2]) {
          rotate([90,0,0]) {
            hull() {
              for(x=[left,right]) {
                translate([x*(cable_opening_width/2-cable_diam/2),0,0]) {
                  hole(cable_diam+0.1,8,10);
                }
              }
            }
          }
        }
      }
    }
  }

  // hump cables
  translate([0,byj_body_diam/2+byj_hump_depth,-cable_distance_from_face-cable_diam/2]) {
    rotate([90,0,0]) {
      for(c=[0:num_cables-1]) {
        translate([cable_pos_x[c],0,0]) {
          color(cable_colors[c]) {
            hole(cable_diam,cable_sample_len*2,8);
          }
        }
      }
    }
  }
}

tuner_hole_to_shoulder = 22.5;
wire_hole_diam = 2;

tuner_thin_diam = 6;
tuner_thin_len_past_hole = 5;
tuner_thin_len = tuner_hole_to_shoulder + tuner_thin_len_past_hole;
tuner_thin_pos = tuner_hole_to_shoulder/2-tuner_thin_len_past_hole/2;

tuner_thick_diam = 10;
tuner_thick_len = 10;
tuner_thick_pos = tuner_hole_to_shoulder-tuner_thick_len+tuner_thick_len/2;

tuner_body_diam = 15;
tuner_body_thickness = 9;
tuner_body_square_len = 10;
tuner_body_pos = -tuner_hole_to_shoulder-tuner_body_thickness/2;

tuner_anchor_screw_hole_thickness = 2;
tuner_anchor_screw_hole_diam = 2;
tuner_anchor_diam = 6;
tuner_anchor_screw_hole_pos_x = -tuner_hole_to_shoulder-tuner_anchor_screw_hole_thickness/2;
tuner_anchor_screw_hole_pos_y = -tuner_body_diam/2;
tuner_anchor_screw_hole_pos_z = -tuner_body_diam/2;

module tuner_anchor_hole_positioner_relative_to_tuner() {
  translate([tuner_anchor_screw_hole_pos_x,tuner_anchor_screw_hole_pos_y,tuner_anchor_screw_hole_pos_z]) {
    rotate([0,90,0]) {
      children();
    }
  }
}

module tuner() {
  adjuster_narrow_neck_len = 2;
  adjuster_len = 24 - tuner_body_diam + adjuster_narrow_neck_len;
  adjuster_large_diam = 8;
  adjuster_tuner_thin_diam = 6;
  adjuster_x = tuner_body_pos;
  adjuster_y = tuner_body_square_len/2;
  adjuster_shaft_z = tuner_body_diam/2+adjuster_len/2;
  adjuster_paddle_len = 20;
  adjuster_paddle_z = adjuster_shaft_z + adjuster_len/2 + adjuster_paddle_len/2;
  adjuster_paddle_width = 17.8;
  adjuster_paddle_thickness = adjuster_tuner_thin_diam;

  module body() {
    //% translate([-tuner_hole_to_shoulder/2,-tuner_thick_diam,0]) rotate([0,90,0]) cylinder(r=tuner_thin_diam/4,h=tuner_hole_to_shoulder,center=true);

    // thin shaft
    translate([-tuner_thin_pos,0,0]) rotate([0,90,0])
      hole(tuner_thin_diam,tuner_thin_len,resolution);

    // thick shaft (area to clamp)
    translate([-tuner_thick_pos,0,0]) rotate([0,90,0])
      hole(tuner_thick_diam,tuner_thick_len,resolution);

    // body
    translate([tuner_body_pos,0,0]) {
      hull() {
        rotate([0,90,0]) {
          hole(tuner_body_diam,tuner_body_thickness,resolution);
        }
        translate([0,tuner_body_square_len/2,0]) {
          cube([tuner_body_thickness,tuner_body_square_len,tuner_body_diam],center=true);
        }
      }
    }

    // anchor screw hole
    hull() {
      translate([tuner_anchor_screw_hole_pos_x,0,0]) {
        rotate([0,90,0])
          hole(tuner_thick_diam,tuner_anchor_screw_hole_thickness);
      }
      tuner_anchor_hole_positioner_relative_to_tuner() {
        hole(tuner_anchor_diam,tuner_anchor_screw_hole_thickness,resolution);
      }
    }

    // twist adjuster
    translate([adjuster_x,adjuster_y,adjuster_shaft_z]) {
      hull() {
        translate([0,0,-adjuster_len/2-.5]) hole(adjuster_large_diam,1,resolution);
        translate([0,0,+adjuster_len/2-.5]) hole(adjuster_tuner_thin_diam,1,resolution);
      }
      // paddle, representing space taken when rotated
      /*
      hull() {
        //translate([0,0,adjuster_paddle_len/2]) cylinder(r=adjuster_paddle_width/2,h=1,center=true);
        //translate([0,0,1]) cylinder(r=adjuster_paddle_thickness/2,h=1,center=true);
        translate([0,0,adjuster_paddle_len-.5]) cube([adjuster_paddle_width,adjuster_paddle_thickness,1],center=true);
        translate([0,0,adjuster_len/2]) cube([adjuster_paddle_thickness,adjuster_paddle_thickness,1],center=true);
      }
      */
    }
  }

  module holes() {
    cylinder(r=wire_hole_diam/3,h=tuner_thin_diam*2,center=true);

    translate([tuner_anchor_screw_hole_pos_x,tuner_anchor_screw_hole_pos_y,tuner_anchor_screw_hole_pos_z]) rotate([0,90,0])
      hole(tuner_anchor_screw_hole_diam,tuner_anchor_screw_hole_thickness+1,8);
  }

  difference() {
    body();
    holes();
  }
}

v_slot_depth     = 1.80;
//v_slot_gap       = 5.68;
v_slot_width     = 9.5;
v_slot_gap       = v_slot_width-v_slot_depth*2;
v_slot_opening   = 6.2;

module openbuilds_groove_profile() {
  square([v_slot_depth*3,v_slot_opening],center=true);
  hull() {
    square([v_slot_depth*2,v_slot_gap],center=true);
    translate([0,0,0]) {
      square([0.00001,v_slot_width],center=true);
    }
  }

  groove_depth = 12.2/2;
  opening_behind_slot = 1.64;
  opening_behind_slot_width = v_slot_gap+(groove_depth-opening_behind_slot-v_slot_depth)*2;

  for(side=[left,right]) {
    translate([side*v_slot_depth,0,0]) {
      hull() {
        translate([side*(groove_depth-v_slot_depth)/2,0,0]) {
          square([groove_depth-v_slot_depth,v_slot_gap],center=true);
        }
        translate([side*opening_behind_slot/2,0,0]) {
          square([opening_behind_slot,opening_behind_slot_width],center=true);
        }
      }
    }
  }
}

module extrusion_20_profile(width) {
  height = 20;
  base_units = width / 20;

  base_unit = 20;
  open_space_between_sides = base_unit-v_slot_depth*2;
  module body() {
    square([width,height],center=true);
  }

  module holes() {
    for(x=[-width/2,width/2]) {
      translate([x,0,0]) {
        rotate([0,0,0]) {
          openbuilds_groove_profile();
        }
      }
    }

    translate([-width/2,0]) {
      for(x=[0:base_units-1]) {
        translate([10+20*x,0,0]) {
          // screw hole
          accurate_circle(4.2,16);

          for (y=[top,bottom]) {
            // top/bottom slots
            translate([0,y*height/2,0]) {
              rotate([0,0,90]) {
                openbuilds_groove_profile();
              }
            }
          }
        }
      }

      if (base_units > 1) {
        for(x=[0:base_units-2]) {
          // gaps between screw holes
          translate([20+20*x,0,0]) {
            square([5.4,open_space_between_sides],center=true);
            hull() {
              square([5.4,open_space_between_sides-1.96*2],center=true);
              square([12.2,5.68],center=true);
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

if (false) {
  extrusion_widths=[20,40,60,80,100,120,140];
  for(i=[0:len(extrusion_widths)-1]) {
    w = extrusion_widths[i];
    translate([0,25*i,20*i]) {
      color("lightgrey") linear_extrude(height=20,center=true,convexity=3) {
        extrusion_20_profile(w);
      }
    }
  }
}

module extrusion(height,width,len) {
  linear_extrude(height=len,center=true,convexity=2) {
    extrusion_20_profile(width);
  }
}

module ptfe_bushing_profile_for_2040_extrusion() {
  width = 40;
  height = 20;
  bushing_from_extrusion_corner = ptfe_bushing_diam/2+0.5;
  
  // PTFE bushings
  // short side bushings
  for(x=[left,right]) {
    for (z=[top,bottom]) {
      translate([x*(width/2+ptfe_bushing_diam/2-ptfe_bushing_preload_amount),z*(height/2-bushing_from_extrusion_corner)]) {
        accurate_circle(ptfe_bushing_diam,8);
      }
    }
  }

  // long side bushings
  for(x=[left,right]) {
    for (z=[top,bottom]) {
      translate([x*(width/2-bushing_from_extrusion_corner),z*(height/2+ptfe_bushing_diam/2-ptfe_bushing_preload_amount)]) {
        accurate_circle(ptfe_bushing_diam,8);
      }
    }
  }
}

nema17_side = 42;
nema17_len = 47;
nema17_hole_spacing = 31;
nema17_shoulder_diam = 22;
nema17_shoulder_height = 2;
nema17_screw_diam = m3_diam;
nema17_shaft_diam = 5;
nema17_shaft_len = 24;

nema14_side = 35.3;
nema14_len = nema14_side;
nema14_hole_spacing = 26;
nema14_shoulder_diam = 22;
nema14_shoulder_height = 2;
nema14_screw_diam = m3_diam;
nema14_shaft_diam = 5;
nema14_shaft_len = 20;

module motor_nema17(length=nema17_len) {
  difference() {
    translate([0,0,-length/2]) cube([nema17_side,nema17_side,length],center=true);
    for(end=[left,right]) {
      for(side=[front,rear]) {
        translate([nema17_hole_spacing/2*side,nema17_hole_spacing/2*end,0]) {
          hole(nema17_screw_diam,100,resolution/2);
        }
      }
    }
  }
  hole(nema17_shoulder_diam,nema17_shoulder_height*2,resolution);

  translate([0,0,nema17_shaft_len/2]) {
    hole(nema17_shaft_diam,nema17_shaft_len,resolution);
  }
}

module motor_nema14(length=nema14_len) {
  difference() {
    translate([0,0,-length/2]) cube([nema14_side,nema14_side,length],center=true);
    for(end=[left,right]) {
      for(side=[front,rear]) {
        translate([nema14_hole_spacing/2*side,nema14_hole_spacing/2*end,0]) {
          hole(nema14_screw_diam,100,resolution/2);
        }
      }
    }
  }
  hole(nema14_shoulder_diam,nema14_shoulder_height*2,resolution);

  translate([0,0,nema14_shaft_len/2]) {
    hole(nema14_shaft_diam,nema14_shaft_len,resolution);
  }
}

round_nema14_body_diam = 36.5;
round_nema14_body_len = 19.5;
round_nema14_hole_spacing = 43.9;
round_nema14_shoulder_diam = 16;
round_nema14_shoulder_height = 2;
round_nema14_shaft_diam = 5;
round_nema14_shaft_len = 15-2; // -2 is the shoulder height
round_nema14_shaft_from_center = 0;
round_nema14_shaft_flat_depth = 0.5;
round_nema14_shaft_flat_thickness = round_nema14_shaft_diam-round_nema14_shaft_flat_depth;
round_nema14_shaft_flat_offset = -round_nema14_shaft_flat_depth/2;
round_nema14_shaft_flat_len = 10;
round_nema14_flange_thickness = 1.5;
round_nema14_flange_diam = 9;

module round_nema14(shaft_angle) {
  cable_colors  = ["dimgrey","red","blue","green"];
  metal_top_bottom_thickness = 3;
  cable_diam    = 1;
  cable_spacing = cable_diam+0.3;
  cable_pos_x = [ -1.5, -0.5, 0.5, 1.5 ];
  num_cables    = 4;

  module body() {
    translate([0,0,-round_nema14_body_len/2]) {
      color("dimgray") hole(round_nema14_body_diam-1,round_nema14_body_len-1,resolution);
      for(z=[top,bottom]) {
        translate([0,0,z*(round_nema14_body_len/2-metal_top_bottom_thickness/2)]) {
          color("lightgrey") hole(round_nema14_body_diam,metal_top_bottom_thickness,resolution);
        }
      }
    }
    color("lightgrey") {
      hole(round_nema14_shoulder_diam,round_nema14_shoulder_height*2,resolution);
      translate([0,0,round_nema14_shaft_len/2+round_nema14_shoulder_height]) {
        hole(round_nema14_shaft_diam,round_nema14_shaft_len,resolution);
      }

      translate([0,0,-round_nema14_flange_thickness/2]) {
        linear_extrude(height=round_nema14_flange_thickness,center=true,convexity=3) {
          difference() {
            hull() {
              accurate_circle(round_nema14_shoulder_diam+7,resolution);
              for(side=[left,right]) {
                translate([side*round_nema14_hole_spacing/2,0,0]) {
                  accurate_circle(round_nema14_flange_diam,resolution);
                }
              }
            }
            for(side=[left,right]) {
              translate([side*round_nema14_hole_spacing/2,0,0]) {
                accurate_circle(3,12);
              }
            }
          }
        }
      }
    }

    translate([0,round_nema14_body_diam/2,-round_nema14_body_len+metal_top_bottom_thickness]) {
      color("ivory") cube([cable_spacing*5,3,cable_spacing*2],center=true);
      translate([0,0,0]) {
        rotate([90,0,0]) {
          for(c=[0:num_cables-1]) {
            translate([cable_pos_x[c]*cable_spacing,0,0]) {
              color(cable_colors[c]) {
                hole(cable_diam,15,8);
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([0,0,round_nema14_shoulder_height+round_nema14_shaft_len]) {
      rotate([0,0,0]) {
        translate([0,round_nema14_shaft_diam/2,0]) {
          cube([round_nema14_shaft_diam+1,round_nema14_shaft_flat_depth*2,round_nema14_shaft_flat_len*2],center=true);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

mech_endstop_tiny_width = 5.5;
mech_endstop_tiny_length = 13;
mech_endstop_tiny_height = 7;
mech_endstop_tiny_mounting_hole_diam =2;
mech_endstop_mounting_hole_spacing_y = 6.35;
mech_endstop_tiny_mounting_hole_from_top = 5.1;

module position_mech_endstop_tiny_mount_holes() {
  for(y=[front,rear]) {
    translate([0,y*(mech_endstop_mounting_hole_spacing_y/2),-mech_endstop_tiny_mounting_hole_from_top]) {
      rotate([0,90,0]) {
        children();
      }
    }
  }
}

module mech_endstop_tiny(include_spring=false) {
  spring_angle = 20;
  spring_length = mech_endstop_tiny_length+1;
  button_from_spring_hinge_end = 4.5;
  button_length = 1;

  module body() {
    color("dimgrey") {
      translate([0,0,-mech_endstop_tiny_height/2]) {
        cube([mech_endstop_tiny_width,mech_endstop_tiny_length,mech_endstop_tiny_height],center=true);
      }
    }

    // contacts
    pin_width = 0.85;
    for(y=[front,0,rear]) {
      translate([0,y*(mech_endstop_tiny_length/2-0.9-pin_width/2),-mech_endstop_tiny_height]) {
        color("silver") {
          cube([0.85,0.85,4],center=true);
        }
      }
    }

    translate([0,mech_endstop_tiny_length/2,0]) {
      translate([0,-button_from_spring_hinge_end,0]) {
        color("red") {
          cube([mech_endstop_tiny_width-2.5,button_length,1],center=true);
        }
      }

      if (include_spring) {
        translate([0,-1,0]) {
          rotate([-spring_angle,0,0]) {
            translate([0,-spring_length/2,0]) {
              color("silver") {
                difference() {
                  cube([mech_endstop_tiny_width-1,spring_length,0.2],center=true);
                  hole_diam = mech_endstop_tiny_width-1-2.5;
                  hull() {
                    translate([0,spring_length/2-hole_diam/2,0]) {
                      hole(hole_diam,1,12);
                    }
                    translate([0,-2,0]) {
                      hole(hole_diam,1,12);
                    }
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
    for(y=[front,rear]) {
      translate([0,y*(mech_endstop_mounting_hole_spacing_y/2),-mech_endstop_tiny_mounting_hole_from_top]) {
        rotate([0,90,0]) {
          hole(mech_endstop_tiny_mounting_hole_diam,mech_endstop_tiny_width+1,8);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

// via
//   https://www.hiwin.de/en/Products/Linear_Guideways/Series_MG/Block_MGN/21089/148407
mgn9c_width = 20;
mgn9c_length = 28.9;
mgn9c_surface_above_surface = 10;
mgn9c_dist_above_surface = 2;
mgn9c_height = mgn9c_surface_above_surface - mgn9c_dist_above_surface;
mgn9c_hole_spacing_width = 15;
mgn9c_hole_spacing_length = 10;

module mgn9c() {
  difference() {
    translate([0,0,-mgn9c_height/2]) {
      color("#aaa") cube([mgn9c_width,mgn9c_length,mgn9c_height],center=true);
    }

    translate([0,0,-mgn9c_surface_above_surface]) {
      cube([mgn9_rail_width+0.4,mgn9c_length+1,mgn9_rail_height*2+0.4],center=true);
    }

    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*mgn9c_hole_spacing_width/2,y*mgn9c_hole_spacing_length/2,0]) {
          color("#555") hole(3,8,resolution);
        }
      }
    }
  }
}

// via
//   https://www.hiwin.de/en/Products/Linear_Guideways/Series_MG/Block_MGN/21089/148409
mgn12c_width = 27;
mgn12c_length = 34.7;
mgn12c_dist_above_surface = 3;
mgn12c_surface_above_surface = 13;
mgn12c_height = mgn12c_surface_above_surface - mgn12c_dist_above_surface;
mgn12c_dist_to_surface = 3;
mgn12c_hole_spacing_width = 20;
mgn12c_hole_spacing_length = 15;

module mgn12c() {
  difference() {
    translate([0,0,-mgn12c_height/2]) {
      color("#aaa") cube([mgn12c_width,mgn12c_length,mgn12c_height],center=true);
    }

    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*mgn12c_hole_spacing_width/2,y*mgn12c_hole_spacing_length/2,0]) {
          color("#555") hole(3,8,resolution);
        }
      }
    }
  }
}

//   https://www.hiwin.de/en/Products/Linear_Guideways/Series_MG_PM/Series_MG/Rail_MGNR/21097
mgn12_rail_width = 12;
mgn12_rail_height = 8;
mgn12_rail_hole_spacing = 25;
mgn9_rail_width = 9;
mgn9_rail_height = 6.5;
mgn9_rail_hole_spacing = 20;

module mgn_rail(width,length,height,hole_spacing,hole_offset_input) {
  num_holes = floor((length-m3_socket_head_diam)/hole_spacing);
  extra_length = length-((num_holes)*hole_spacing);
  hole_offset = (hole_offset_input > -1) ? hole_offset_input : extra_length/2;

  translate([0,0,height/2]) {
    difference() {
      color("lightgrey") cube([width,length,height],center=true);
      for (y=[0:hole_spacing:length]) {
        color("#444") translate([0,-length/2+hole_offset+y,height/2]) {
          hole(3.5,40,resolution);

          hole(m3_socket_head_diam,3.5*2,resolution);
        }
      }
    }
  }
}

module mgn9_rail(length,hole_offset=-1) {
  mgn_rail(mgn9_rail_width,length,mgn9_rail_height,mgn9_rail_hole_spacing,hole_offset);
}

module mgn12_rail(length,hole_offset=-1) {
  mgn_rail(mgn12_rail_width,length,mgn12_rail_height,mgn12_rail_hole_spacing,hole_offset);
}

if (false) {
  translate([-mgn9_rail_width/2-5,0,0]) {
    mgn9_rail(150);
  }

  translate([mgn12_rail_width/2+5,0,0]) {
    mgn12_rail(150);
  }
}

//gt2_toothed_idler_id = 3; // walter and whosawhatsis
gt2_toothed_idler_id = 5; // use a toothed idler with more meat
gt2_toothed_idler_od = 12.2;
//gt2_toothed_idler_od = 20*2 / pi;
gt2_toothed_idler_height = 9;
gt2_toothed_idler_flange_od = 18.2;
gt2_toothed_idler_flange_thickness = 1;

module gt2_toothed_idler() {
  difference() {
    union() {
      hole(gt2_toothed_idler_od, gt2_toothed_idler_height-0.05,resolution);

      for(z=[top,bottom]) {
        translate([0,0,z*(gt2_toothed_idler_height/2-gt2_toothed_idler_flange_thickness/2)]) {
          hole(gt2_toothed_idler_flange_od, gt2_toothed_idler_flange_thickness,resolution);
        }
      }
    }

    hole(gt2_toothed_idler_id,gt2_toothed_idler_height+1,resolution);
  }
}

module gt2_16t_pulley() {
  flange_diam = 14;
  flange_thickness = 1;
  teeth_diam = 10; // not really, but close enough
  height = 8;
  difference() {
    union() {
      hole(teeth_diam, height-0.05, resolution);

      for(z=[top,bottom]) {
        translate([0,0,z*(height/2-flange_thickness/2)]) {
          hole(flange_diam, flange_thickness,resolution);
        }
      }
    }

    hole(5,height+1,resolution);
  }
}

duet_width = 100;
duet_length = 123;
duet_board_thickness = 3;
duet_overall_length = duet_length + 6; // wifi antenna sticks out

duet_hole_spacing_x = 92;
duet_hole_spacing_y = 115;

duet_hole_from_end = duet_length/2-duet_hole_spacing_y/2;

module duet_wifi() {
  linear_extrude(height=duet_board_thickness,convexity=3,center=true) {
    difference() {
      union() {
        square([duet_width,duet_length],center=true);
      }
      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([x*duet_hole_spacing_x/2,y*duet_hole_spacing_y/2,0]) {
            accurate_circle(4,resolution);
          }
        }
      }
    }
  }

  esp_len = 20;
  translate([duet_width/2 -12 -16/2,front*(duet_length/2-esp_len/2+6),3]) {
    cube([16,esp_len,3],center=true);
  }
}

mini_thumb_screw_od = 12;
mini_thumb_screw_id = 3;
mini_thumb_screw_thickness = 4;
mini_thumb_screw_grip_thickness = 3;

module mini_thumb_screw() {
  bevel_small_od = 7;
  bevel_large_od = 8;
  bevel_height = mini_thumb_screw_thickness - mini_thumb_screw_grip_thickness;

  module body() {
    hole(mini_thumb_screw_od,mini_thumb_screw_grip_thickness,resolution);
    hull() {
      hole(bevel_large_od,mini_thumb_screw_grip_thickness,resolution);
      translate([0,0,bevel_height]) {
        hole(bevel_small_od,mini_thumb_screw_grip_thickness,resolution);
      }
    }
  }

  module holes() {
    hole(mini_thumb_screw_id,mini_thumb_screw_thickness+1,resolution);
  }

  difference() {
    body();
    holes();
  }
}
