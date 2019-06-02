// A cutting of:

// Parametric Pulley with multiple belt profiles
// by droftarts January 2012

// Based on pulleys by:
// http://www.thingiverse.com/thing:11256 by me!
// https://github.com/prusajr/PrusaMendel by Josef Prusa
// http://www.thingiverse.com/thing:3104 by GilesBathgate
// http://www.thingiverse.com/thing:2079 by nophead

// dxf tooth data from http://oem.cadregister.com/asp/PPOW_Entry.asp?company=915217&elementID=07807803/METRIC/URETH/WV0025/F
// pulley diameter checked and modelled from data at http://www.sdp-si.com/D265/HTML/D265T016.html

/**
 * @name Pulley
 * @category Printed
 * @using 1 x m3 nut, normal or nyloc
 * @using 1 x m3x10 set screw or 1 x m3x8 grub screw
 */


// tuneable constants

teeth = 16;      // Number of teeth, standard Mendel T5 belt = 8, gives Outside Diameter of 11.88mm

pulley_t_ht = 12;  // length of toothed part of pulley, standard = 12

//  ********************************
//  ** Scaling tooth for good fit **
//  ********************************
/*  To improve fit of belt to pulley, set the following constant. Decrease or increase by 0.1mm at a time. We are modelling the *BELT* tooth here, not the tooth on the pulley. Increasing the number will *decrease* the pulley tooth size. Increasing the tooth width will also scale proportionately the tooth depth, to maintain the shape of the tooth, and increase how far into the pulley the tooth is indented. Can be negative */

additional_tooth_width = 0.2; //mm

//  If you need more tooth depth than this provides, adjust the following constant. However, this will cause the shape of the tooth to change.

additional_tooth_depth = 0; //mm

// calculated constants

// The following set the pulley diameter for a given number of teeth

GT2_2mm_pulley_dia = tooth_spacing (2,0.254);

// The following calls the pulley creation part, and passes the pulley diameter and tooth width to that module

pulley(GT2_2mm_pulley_dia , 0.764 , 1.494 );

// Functions

function tooth_spacing(tooth_pitch,pitch_line_offset)
  = (2*((teeth*tooth_pitch)/(3.14159265*2)-pitch_line_offset)) ;

tooth_width = 1.494;
tooth_depth = 0.764;

tooth_pitch = 2;
pitch_line_offset = 0.254;

// Main Module
function tooth_spacing_for_teeth(n_teeth)
  = (2*((n_teeth*tooth_pitch)/(3.14159265*2)-pitch_line_offset)) ;

module gt2_pulley_with_teeth(teeth) {
  teeth_diam = tooth_spacing_for_teeth(teeth);
  tooth_distance_from_centre = sqrt( pow(teeth_diam/2,2) - pow((tooth_width+additional_tooth_width)/2,2));

  difference() {
    union() {
      difference() {
        // main body
        rotate ([0,0,360/(teeth*4)]) {
          circle(r=teeth_diam/2,$fn=teeth*4);
        }

        //teeth - cut out of shaft
        for(i=[1:teeth]) {
          rotate([0,0,i*(360/teeth)]) {
            translate([0,-tooth_distance_from_centre,0]) {
              gt2_tooth();
            }
          }
        }
      }
    }
  }
}

module gt2_teeth_in_circle(teeth) {
  teeth_diam = tooth_spacing_for_teeth(teeth);
  tooth_distance_from_centre = sqrt( pow(teeth_diam/2,2) - pow((tooth_width+additional_tooth_width)/2,2));

  //teeth - cut out of shaft
  for(i=[1:teeth]) {
    rotate([0,0,i*(360/teeth)]) {
      translate([0,-tooth_distance_from_centre,0]) {
        gt2_tooth();
      }
    }
  }
}

module gt2_tooth() {
  tooth_width_scale = (tooth_width + additional_tooth_width ) / tooth_width;
  tooth_depth_scale = ((tooth_depth + additional_tooth_depth ) / tooth_depth) ;

  scale([tooth_width_scale,tooth_depth_scale,1]) {
    polygon([
      [0.747183,-0.5],
      [0.747183,0],
      [0.647876,0.037218],
      [0.598311,0.130528],
      [0.578556,0.238423],
      [0.547158,0.343077],
      [0.504649,0.443762],
      [0.451556,0.53975],
      [0.358229,0.636924],
      [0.2484,0.707276],
      [0.127259,0.750044],
      [0,0.76447],
      [-0.127259,0.750044],
      [-0.2484,0.707276],
      [-0.358229,0.636924],
      [-0.451556,0.53975],
      [-0.504797,0.443762],
      [-0.547291,0.343077],
      [-0.578605,0.238423],
      [-0.598311,0.130528],
      [-0.648009,0.037218],
      [-0.747183,0],
      [-0.747183,-0.5]
    ]);
  }
}
