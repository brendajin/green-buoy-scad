$fn=128;

// Parameters
threaded_insert_diameter = 7.35;
thread_cylinder_diameter = 6.3;
main_shaft_diameter = 10;
bottom_section_radius = 8.5;
section_height =10;
bottom_section_height = 4;

torus_hole_diameter = 3;
torus_diameter = 3;

whistle_short = 3;
whistle_long = bottom_section_radius*2;
whistle_thickness = 2;


// Derived parameters
offset = section_height/2;
ridge_width = 2;


buoy_number_size = 3;

// Helper: optional torus geometry (currently unused)
module torus() {
    torus_total_radius = (torus_hole_diameter + torus_diameter)/2;
    translate([0, torus_total_radius, torus_total_radius - torus_diameter/2]);
    rotate([0, 90, 0])
    rotate_extrude()
    translate([(torus_hole_diameter + torus_diameter)/2, 0, 0])
    circle(r = torus_diameter/3.5);
}


// Component: buoy bottom assembly
module buoy_bottom() {
    translate([0, 0, -2*bottom_section_height])
        cylinder(h = 2*bottom_section_height, r = bottom_section_radius*1.72);
}

// Common subcomponents
module buoy_divider(vertical_offset) {
    translate([0,0,vertical_offset]){
        cube([section_height+ridge_width,section_height+ridge_width,1], true);
    }
}

module buoy_section(vertical_offset, height_pcnt) {
    translate([0,0,vertical_offset]){
       cube([section_height, section_height, section_height*height_pcnt], true);
    }
}

module pillars(vertical_offset, height){
    translate([0, 0, vertical_offset]){
        translate([offset-1,offset-1,0]){
            cube([ridge_width, ridge_width, height]);
        }

        translate([-offset-1,offset-1,0]){
            cube([ridge_width, ridge_width, height]);
        }

        translate([offset-1,-offset-1,0]){
            cube([ridge_width, ridge_width, height]);
        }

        translate([-offset-1,-offset-1,0]){
            cube([ridge_width, ridge_width, height]);
        }
    }

}

module criss_cross(width, height, offset) {
    translate([0,0,offset]){
        rotate(45){
            cube([ridge_width/2, sqrt(2*pow(ridge_width+width,2)), height], true);
        }
        rotate(135){
            cube([ridge_width/2, sqrt(2*pow(ridge_width+width,2)), height], true);
        }
    }
}

// Component: buoy top assembly
module buoy_top() {
    intersection(){
        cylinder(d=section_height*1.4, h=section_height*3.2);
        buoy_top_raw();
    }
    top_cap(section_height*3+1);
}

// Internal: raw geometry for top assembly
module buoy_top_raw(){
    buoy_section(section_height+section_height*.4,.8);
    buoy_divider(section_height);
    buoy_section(section_height/2, 1);
    pillars(0, section_height);
    pillars(section_height, section_height*.8);
    criss_cross(section_height, section_height*1.3, section_height*2.45);
    buoy_divider(section_height*2.3+2);

}

module torus_cap(){
    difference(){
        torus();
        translate([0,0,-torus_diameter*2]){
            cube(torus_diameter*4, true);
        }
    }
}

// Subcomponent: top cap
module top_cap(vertical_offset){
    translate([0,0,vertical_offset+ridge_width]){
        torus_cap();
    }
    translate([0,0,vertical_offset]){
        cylinder(d=1.5*section_height, h=ridge_width);
    }
}



// Assemble
module buoy_whole(){
    buoy_bottom();
    buoy_top();
}

module buoy_number() {
    translate([2, 2, section_height*2.7])
      rotate([90, 0, 45])
      translate([0, 0, 0.2])
      linear_extrude(height = 1.5)
      text("1", size=buoy_number_size, font="Arial:style=Bold");
}
module fill_the_gap(){
    thickness = 0.8;
    translate([0, 0, -2*bottom_section_height]){
        difference(){
            cylinder(h = 2*bottom_section_height, r = bottom_section_radius*1.72);
            cylinder(h = 2*bottom_section_height, r = bottom_section_radius*1.72 - thickness);
            translate([-13, 0,  bottom_section_height*2])
                cube(4, true);
        }
    }
}

module buoy_bottom_raw(){
    thickness = 0.9;
    scale(thickness){
    translate([0, 0, -2*bottom_section_height]){
            cylinder(h = 2*bottom_section_height - offset, r = bottom_section_radius*1.72);
        }
    }
}

whistle_thick = 2;
whistle_height = 50;
whistle_mouth_short = 3;
whistle_mouth_long = 4;
whistle_mouth_offset_x = 3.55 - whistle_thick;
whistle_mouth_offset_z = -2*bottom_section_height-0.01;
whistle_hole_short = 2;
whistle_hole_long = 3;
whistle_hole_offset_x = 4.1;
whistle_hole_offset_z = 2;

module whistle_cutout() {
    // Mouth cavity
    translate([whistle_mouth_offset_x, 0, whistle_mouth_offset_z]){
        cube([whistle_mouth_short, whistle_mouth_long, whistle_height], true);
    }
    // Sound cavity
    translate([whistle_hole_offset_x, 0, whistle_hole_offset_z]) {
        cube([whistle_hole_short+2, whistle_hole_short, whistle_hole_long], true);
        translate([0, 0, whistle_hole_long*0.7])
          cube(whistle_hole_short, true);
    }
}

module whistle_pos() {
    translate([whistle_hole_offset_x, 0, whistle_hole_offset_z]) {
        translate([0, 0, whistle_hole_long*0.7])
          half_cube(whistle_hole_short);
    }
}

module assembly() {
    difference(){
        buoy_whole();
        // cutout on top
        translate([0,0,section_height*2.91]){
            cylinder(d=torus_hole_diameter, h=ridge_width*2);
        }
        whistle_cutout();
        buoy_number();
    }
    whistle_pos();
}

module half_cube(size) {
  rotate([-45, 0, 90])
    intersection() {
      rotate([45, 0, 0])
        cube(size, true);
      translate([0, 0, size])
        cube(size*2, true);
    }
}

assembly();
