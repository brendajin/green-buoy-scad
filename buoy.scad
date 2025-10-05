use <whistle.scad>


// Parameters
threaded_insert_diameter = 7.35;
thread_cylinder_diameter = 6.3;
main_shaft_diameter = 10;
bottom_section_radius = 8.5;
section_height =10;
bottom_section_height = 6;

torus_hole_diameter = 3;
torus_diameter = 3;

whistle_short = 3;
whistle_long = bottom_section_radius*2;
whistle_thickness = 2;


// Derived parameters
offset = section_height/2;
ridge_width = 2;

torus_total_radius = (torus_hole_diameter + torus_diameter)/2;



// Helper: optional torus geometry (currently unused)
module torus() {
    translate([0, torus_total_radius, torus_total_radius - torus_diameter/2]);
    rotate([0, 90, 0])
    rotate_extrude()
    translate([(torus_hole_diameter + torus_diameter)/2, 0, 0])
    circle(r = torus_diameter/2);
}


// Component: buoy bottom assembly
module buoy_bottom() {
    // union(){
    //     union(){
    //         intersection(){
    //             translate([0, 0, -section_height]){
    //                     sphere(1.95*section_height);
    //             }
                translate([0, 0, -2*bottom_section_height])
                    cylinder(h = 2*bottom_section_height, r = bottom_section_radius*1.72);

    //         }
    // cylinder(r1=bottom_section_radius*1.662, r2=section_height, h=ridge_width);
    // }
// }
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
    translate([0,0,section_height*3-1]){
        // cylinder(d1=section_height, d2=section_height*2, h=ridge_width);
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
        translate([0,0,-section_height/2]){
            cube(section_height, true);
        }
    }
}

// Subcomponent: top cap
module top_cap(vertical_offset){
    translate([0,0,vertical_offset]){
        cylinder(d=1.5*section_height, h=ridge_width);
    }
    // swap for torus
    translate([0,0,vertical_offset+ridge_width]){
        torus_cap();
    }
}



// Assemble
module buoy_whole(){
    buoy_bottom();
    buoy_top();
}

module my_whistle(){
    translate([-13,-4.3,-9.83])
        scale([0.45,0.45,0.45])
            whistle();
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
    offset = 2.7;
    thickness = 0.8;
    translate([0, 0, -2*bottom_section_height]){
        difference(){
            cylinder(h = 2*bottom_section_height - offset, r = bottom_section_radius*1.72);
            cylinder(h = 2*bottom_section_height - offset, r = bottom_section_radius*1.72 - thickness);
        }
    }
}

union(){
    difference(){
        buoy_whole();
        hull()
            my_whistle();
    }
    my_whistle();
    buoy_bottom_raw();
    fill_the_gap();
}
