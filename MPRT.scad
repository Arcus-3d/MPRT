// MPRT - Modified planetary robotics transmission OpenSCAD source

// Project home: https://hackaday.io/project/164732
// Author: https://hackaday.io/daren
//
// Creative Commons License exists for this work. You may copy and alter the content
// of this file for private use only, and distribute it only with the associated
// MPRT content. This license must be included withthe file and content.
// For a copy of the current license, please visit http://creativecommons.org/licenses/by-sa/3.0/

use <./involute_gears.scad>


extra=0.02; // for differencing
$fs=.01; // circle/face accuracy
$fn=120;

//gear settings

pitch=1.05; //diametric pitch = teeth/diam
pressure_angle=24;
clearance=0.2; // extra depth at the base of the gear profile	
backlash=0.10; // inter-tooth clearance following the tooth profile.

num_planets=3;
// (ring_teeth - sun_teeth) must be an even number for planet_teeth to work!
ring_teeth=60; // needs to be divisable by both <num_planets> and 2.
sun_teeth=18; // needs to be divisable by both <num_planets> and 2.
output_teeth=ring_teeth-num_planets;
output_pilot_d=16+clearance/2;
output_pilot_h=0;
output_bolt_offset_1=15;
output_bolt_offset_2=26;
output_bolt_d=3-clearance;

planet_teeth=(ring_teeth-sun_teeth)/2;
planet_cutout_r=0;
orbit_r=((planet_teeth+sun_teeth)/pitch)/2;

wall=5.0+pitch*2+clearance;
ring_gear_h=2;
ring_gear_r=ring_teeth/pitch/2;

// housing/motor settings
sun_bore_r=6.65/2; // Nema 23 D shaft dia
housing_size=60;
housing_bolt_spacing=47.5; // .5 larger than actual
housing_bolt_d=5.0;
housing_pilot_h=1;
housing_pilot_d=38+clearance;


// uncomment each of these, render, print.
// sun();
// planet();
// housing_ring();
// translate([0,0,output_pilot_h+ring_gear_h]) rotate([0,180,0]) output_ring();

// assembly view.
view_assembly();



module view_assembly() {
	translate([0,0,housing_pilot_h+extra]) {
		rotate([0,0,0]) sun();
		for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-1)]) translate([orbit_r,0,0]) rotate([0,0,0]) planet();
	}
	translate([0,0,ring_gear_h+clearance+housing_pilot_h]) {
		#output_ring();
	}
	housing_ring();
	ratio=ring_teeth/sun_teeth*ring_teeth/num_planets;
	echo("Final drive ratio:", ratio);
}
module output_ring() {
	difference() {
		// body
		translate([0,0,ring_gear_h/2+output_pilot_h/2]) hull() {
			cylinder(r=ring_gear_r+wall/2,h=ring_gear_h+output_pilot_h-extra,center=true);
			//translate([60,0,0]) cylinder(r=5,h=ring_gear_h+output_pilot_h-extra,center=true);
		}
		// gear cutout
		translate([0,0,-extra/2]) gear(number_of_teeth=output_teeth, diametral_pitch=pitch*output_teeth/ring_teeth, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra*4, gear_thickness=ring_gear_h+clearance,clearance=-clearance, backlash=-backlash*2, pressure_angle=pressure_angle+2.5);
		// output hole cutout
		//translate([60,0,0]) cylinder(r=3,h=ring_gear_h*4+extra,center=true);
		translate([0,0,ring_gear_h+output_pilot_h/2+1]) cylinder(r=output_pilot_d/2,h=output_pilot_h+extra,center=true);
		translate([0,0,ring_gear_h+1/2]) cylinder(r2=output_pilot_d/2,r1=output_pilot_d/2-1,h=1+extra,center=true);
		for (i=[1:6]) rotate([0,0,(360/6)*(i-1)]) translate([output_bolt_offset_1,0,ring_gear_h+output_pilot_h/2+0.8]) cylinder(r=output_bolt_d/2,h=output_pilot_h,center=true);
		for (i=[1:6]) rotate([0,0,(360/6)*(i-1)+360/12]) translate([output_bolt_offset_2,0,ring_gear_h+output_pilot_h/2+0.8]) cylinder(r=output_bolt_d/2,h=output_pilot_h,center=true);
	}
}

module planet() {
	gear(number_of_teeth=planet_teeth, diametral_pitch=pitch, hub_diameter=0, bore_diameter=planet_cutout_r*2, rim_thickness=ring_gear_h*2-clearance/2, gear_thickness=ring_gear_h*2-clearance/2,clearance=clearance, backlash=backlash, pressure_angle=pressure_angle);
}

module housing_ring() {
	spool_offset=0.0;
	total_height=ring_gear_h+housing_pilot_h; 
	translate([0,0,total_height/2]) difference() {
		// body
		union() {
			hull() for (xnum=[-1,1]) for (ynum=[-1,1])  translate([xnum*housing_bolt_spacing/2,ynum*housing_bolt_spacing/2,0]) cylinder(r=(housing_bolt_d+wall)/2, h=total_height, center=true);
			cylinder(r=ring_gear_r+wall/2, h=total_height,center=true);
		}
		// bolt holes
		for (xnum=[-1,1]) for (ynum=[-1,1]) {
			translate([xnum*housing_bolt_spacing/2,ynum*housing_bolt_spacing/2,0]) {
				cylinder(r=housing_bolt_d/2+extra, h=total_height+extra, center=true);
				translate([0,0,total_height/2-housing_bolt_d/4+extra]) cylinder(r2=housing_bolt_d*.75,r1=housing_bolt_d*.75/2, h=housing_bolt_d/2, center=true);
			}
			
		}
		translate([0,0,-total_height/2]) {
			// stepper center pilot
			translate([0,0,housing_pilot_h/2]) cylinder(r=housing_pilot_d/2,h=housing_pilot_h+extra*4,center=true);
			// gear cutout
			translate([0,0,housing_pilot_h]) gear(number_of_teeth=ring_teeth, diametral_pitch=pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra, gear_thickness=ring_gear_h+extra,clearance=0, backlash=-backlash, pressure_angle=pressure_angle );
		}
	}
}

module sun() {
	union() {
		gear(number_of_teeth=sun_teeth, diametral_pitch=pitch, hub_diameter=pitch*sun_teeth, hub_thickness=ring_gear_h*2, bore_diameter=sun_bore_r*2, rim_thickness=ring_gear_h*2, rim_width=0, gear_thickness=ring_gear_h*2,clearance=clearance, backlash=backlash, pressure_angle=pressure_angle);
		// D shaft flat
		translate([sun_bore_r*2/1.9,0,ring_gear_h]) cube([sun_bore_r*2/5,sun_bore_r,ring_gear_h*2],center=true);
	}
}

