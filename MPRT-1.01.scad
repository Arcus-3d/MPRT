// MPRT - Modified planetary robotics transmission OpenSCAD source

// Project home: https://hackaday.io/project/164732
// Author: https://hackaday.io/daren
//
// Creative Commons License exists for this work. You may copy and alter the content
// of this file for private use only, and distribute it only with the associated
// MPRT content. This license must be included with the file and content.
// For a copy of the current license, please visit http://creativecommons.org/licenses/by-sa/3.0/

use <./involute_gears.scad>

// accuracy and such
extra=0.02; // for differencing
$fs=.01; // circle/face accuracy
$fn=120; // circle default facets

//settings you can mess with.

// housing/output/input settings

output_r=74/2;
output_pilot_h=0;
output_pilot_r=16.2/2;

sun_bore_r=6.65/2; // Nema 23 D shaft dia
sun_bore_d_shaft=true; // set true for a D shaft

housing_r=74/2;
housing_pilot_h=2;
housing_pilot_r=38.2/2;
gear_wall=3.2;


// gear settings
pressure_angle=24;
clearance=0.2; // extra space at the base of the gear tooth and top
backlash=0.1; // inter-tooth clearance following the tooth profile.
input_twist=200; // helical gears if < 0
num_planets=3;
// ring_teeth - sun_teeth must be an even number!
sun_teeth=12; // needs to be divisable by both <num_planets> and 2.
ring_teeth=66; // needs to be divisable by both <num_planets> and 2.
ring_gear_h=5; // total height adds pilot heights to this
ring_gear_r=housing_r-gear_wall; // gear radius on pitch line

// calculated stuff you should probably leave alone
input_pitch=ring_teeth/ring_gear_r/2;
planet_teeth=(ring_teeth-sun_teeth)/2;
output_teeth=ring_teeth+num_planets;
output_twist=-input_twist;
idler_teeth=sun_teeth+num_planets;
output_pitch = input_pitch*(planet_teeth+idler_teeth)/(planet_teeth+sun_teeth);
orbit_r=((planet_teeth+sun_teeth)/input_pitch)/2;


// center cutouts for lighter gears
planet_cutout_r=planet_teeth/output_pitch/2-gear_wall;
idler_cutout_r=idler_teeth/output_pitch/2-gear_wall;


// uncomment each of these, render, print.
// sun();
//planet();
// housing_ring();
// translate([0,0,output_pilot_h+ring_gear_h]) rotate([0,180,0]) output_ring();

// assembly view.
view_assembly(explode=0);


module view_assembly(explode=0) {
	translate([0,0,housing_pilot_h+extra+explode]) {
		rotate([0,0,360/sun_teeth/2*(planet_teeth % 2)]) sun();
		translate([0,0,ring_gear_h+clearance+explode*2]) rotate([0,0,360/idler_teeth/2*(planet_teeth % 2 - 1)]) idler();
		for (planetnum=[1:num_planets]) rotate([0,0,(360/num_planets)*(planetnum-1)]) translate([orbit_r,0,explode]) rotate([0,0,0]) planet();
	}
	translate([0,0,housing_pilot_h+ring_gear_h+clearance+explode*4]) {
		rotate([0,0,360/output_teeth/1.01]) output_ring();
	}
	housing_ring();

	first_ratio=(1+ring_teeth/sun_teeth);
	second_ratio=1/(1-ring_teeth/output_teeth);
	final_ratio=first_ratio*second_ratio;
	echo(str("Static Ring Teeth: " , ring_teeth));
	echo(str("Output Ring Teeth: " , output_teeth));
	echo(str("Sun Teeth: " , sun_teeth));
	echo(str("Idler Teeth: " , idler_teeth));
	echo(str("Planet Teeth: " , planet_teeth));
	echo(str("Planet Count: ", num_planets ));	
	echo(str("Input Pitch: " , input_pitch));
	echo(str("Output Pitch: " , output_pitch));
	echo(str("First Stage: ", first_ratio, ":1"));
	echo(str("Second Stage: ", second_ratio, ":1"));
	echo(str("Final Drive: ", final_ratio,":1"));
}

module output_ring() {
	difference() {
		// body
		translate([0,0,ring_gear_h/2+output_pilot_h/2]) cylinder(r=output_r,h=ring_gear_h+output_pilot_h-extra,center=true);
		// gear cutout
		translate([0,0,-extra/2]) gear(number_of_teeth=output_teeth, diametral_pitch=output_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra*4, gear_thickness=ring_gear_h+extra*4,clearance=0, addendum_adjustment=1.15, backlash=-backlash, twist=output_twist/output_teeth,pressure_angle=pressure_angle);
		// pilot cutout
		translate([0,0,ring_gear_h+output_pilot_h/2]) cylinder(r=output_pilot_r,h=output_pilot_h+extra,center=true);
	}
}

module planet() {
	rotate([0,0,input_twist/planet_teeth]) gear(number_of_teeth=planet_teeth, diametral_pitch=input_pitch, hub_diameter=0, bore_diameter=planet_cutout_r*2, rim_thickness=ring_gear_h, gear_thickness=ring_gear_h,clearance=clearance, backlash=backlash, twist=input_twist/planet_teeth,pressure_angle=pressure_angle);
	translate([0,0,ring_gear_h]) gear(number_of_teeth=planet_teeth, diametral_pitch=output_pitch, hub_diameter=0, bore_diameter=planet_cutout_r*2, rim_thickness=ring_gear_h+clearance, gear_thickness=ring_gear_h+clearance,clearance=clearance, backlash=backlash, twist=output_twist/planet_teeth,pressure_angle=pressure_angle);
}

module housing_ring() {
	total_height=ring_gear_h+housing_pilot_h; 
	translate([0,0,total_height/2]) difference() {
		// body
		cylinder(r=housing_r, h=total_height,center=true);
		translate([0,0,-total_height/2-extra/2]) {
			// gear cutout
			rotate([0,0,input_twist/ring_teeth]) translate([0,0,housing_pilot_h]) gear(number_of_teeth=ring_teeth, diametral_pitch=input_pitch, hub_diameter=0, bore_diameter=0, rim_thickness=ring_gear_h+extra*4, gear_thickness=ring_gear_h+extra*4,clearance=0,addendum_adjustment=1.15,twist=input_twist/ring_teeth,backlash=-backlash, pressure_angle=pressure_angle );
			// center pilot cutout
			translate([0,0,housing_pilot_h/2]) cylinder(r=housing_pilot_r,h=housing_pilot_h+extra*4,center=true);
		}
	}
}

module idler() {
	rotate([0,0,360/idler_teeth]) gear(number_of_teeth=idler_teeth, diametral_pitch=output_pitch, hub_diameter=output_pitch*sun_teeth, hub_thickness=ring_gear_h, bore_diameter=idler_cutout_r*2, rim_thickness=ring_gear_h, rim_width=0, gear_thickness=ring_gear_h,clearance=clearance, twist=-output_twist/idler_teeth,backlash=backlash, pressure_angle=pressure_angle);
}
module sun() {
	rotate([0,0,(180-input_twist)/sun_teeth]) gear(number_of_teeth=sun_teeth, diametral_pitch=input_pitch, hub_diameter=input_pitch*sun_teeth, hub_thickness=ring_gear_h, bore_diameter=sun_bore_r*2, rim_thickness=ring_gear_h, rim_width=0, gear_thickness=ring_gear_h,clearance=clearance, twist=-input_twist/sun_teeth,backlash=backlash, pressure_angle=pressure_angle);
		// D shaft flat
	if (sun_bore_d_shaft) translate([sun_bore_r*2/1.9,0,ring_gear_h/2]) cube([sun_bore_r*2/5,sun_bore_r,ring_gear_h],center=true);
}

