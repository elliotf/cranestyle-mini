include <./lib/util.scad>;
include <./lib/vitamins.scad>;

tolerance = 0.2;
extrude_width = 0.4;
wall_thickness = extrude_width*3;

room_below_extrusion_for_electronics = 34;

extrusion_mount_screw_diam = m5_diam;
extrusion_mount_screw_head_diam = m5_nut_diam;

m3_loose_diam = m3_diam + tolerance;

m5_thread_into_hole_diam = 4.9;
m5_loose_diam = 5+tolerance;
m5_fsc_head_diam = 10;

leadscrew_diam = 5;
leadscrew_hole_diam = 6.5;
leadscrew_nut_shaft_diam = 8.5;
leadscrew_nut_shaft_length = 6.5;
leadscrew_nut_hole_dist = 6.611;
leadscrew_nut_flange_diam = 20;
leadscrew_nut_flange_thickness = 3.25;
leadscrew_nut_mounting_hole_dist = 6.35;
leadscrew_nut_mounting_hole_diam = 2.8; // from walter's -- threading m3 into plastic?

end_cap_extrusion_width_to_cover = 100;
end_cap_thickness = m5_thread_into_hole_diam + 2*(1.2*2);
end_cap_overhang = 5;
end_cap_width = end_cap_extrusion_width_to_cover + end_cap_overhang*2;
end_cap_height = 20+room_below_extrusion_for_electronics+1;

y_idler_pos_x = -40 + 50;
y_idler_dist_y_from_extrusion = -end_cap_thickness/2;
y_idler_dist_z_from_extrusion = 2;

//leadscrew_pos_y = -leadscrew_nut_flange_diam/2-1;
//leadscrew_pos_y = -11; // we could move it closer with a printed bracket, but it would interfere with the X idler without redefining the X idler Y pos
leadscrew_pos_y = -13; // what walter is using

m3_socket_head_diam = 5.6;
m3_socket_head_height = 3;

rounded_diam = 4;

z_nut_base_height = mgn12c_length/2 - mgn12c_hole_spacing_length/2 + m3_socket_head_diam/2 + extrude_width*2;

gt2_toothed_idler_id_hole = gt2_toothed_idler_id-0.15; // thread the idler pulley shaft into plastic

leadscrew_nut_mounting_hole_depth = z_nut_base_height - leadscrew_nut_flange_thickness - extrude_width*2;

leadscrew_nut_shoulder_below_carriage_holes = 4.5;

idler_bevel_height = 1;
idler_shoulder_above_rail = 9.2/2+4.8;

z_nut_mount_depth = abs(leadscrew_pos_y)+7; // copying from walter
echo("z_nut_mount_depth: ", z_nut_mount_depth);
z_nut_mount_height = idler_shoulder_above_rail - idler_bevel_height + mgn12c_hole_spacing_length/2 + mgn12c_length/2;

echo("z_nut_mount_height: ", z_nut_mount_height);
z_nut_body_pos_z = mgn12c_hole_spacing_length/2+idler_shoulder_above_rail-idler_bevel_height-z_nut_mount_height/2;

// x_idler_on_z_pos_x = -11; // walter
x_idler_on_z_pos_x = left*(leadscrew_diam/2+gt2_toothed_idler_flange_od/2+1);
x_idler_on_z_pos_y = leadscrew_pos_y-3;
x_idler_on_z_pos_z = z_nut_body_pos_z + z_nut_mount_height/2 + idler_bevel_height;

meat_on_far_side_of_idler = gt2_toothed_idler_id_hole/2 + wall_thickness*3;
idler_shaft_body_width = meat_on_far_side_of_idler + abs(x_idler_on_z_pos_x) - leadscrew_hole_diam/2 - 1.75; // fatter to be same as walter's
z_nut_mount_width = meat_on_far_side_of_idler + abs(x_idler_on_z_pos_x) + mgn12c_hole_spacing_width/2 + m3_socket_head_diam/2 + extrude_width*2;
z_nut_body_pos_x = x_idler_on_z_pos_x-meat_on_far_side_of_idler+z_nut_mount_width/2;

mgn9_rail_width_allowance = mgn9_rail_width+tolerance;
mgn9_rail_height_allowance = mgn9_rail_height+tolerance;
