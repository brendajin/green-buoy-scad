// Parameters
threaded_insert_diameter = 7.35;
thread_cylinder_diameter = 6.3;
main_shaft_diameter = 10;
bottom_section_height = 10;

torus_hole_diameter = 15;
torus_diameter = 6;


// Derived parameters
offset = bottom_section_height/2;
ridge_width = 2;

torus_total_radius = (torus_hole_diameter + torus_diameter)/2;



// Helper: optional torus geometry (currently unused)
module torus() {

translate([0, torus_total_radius, main_shaft_height - torus_total_radius - torus_diameter/2])
rotate([0, 90, 0])
rotate_extrude()
    translate([(torus_hole_diameter + torus_diameter)/2, 0, 0])
    circle(r = torus_diameter/2);
}


// Component: buoy bottom assembly
module buoy_bottom() {
    union(){
        union(){
            intersection(){
                translate([0, 0, -bottom_section_height]){
                        sphere(1.95*bottom_section_height);
                }
                translate([0, 0, -2*bottom_section_height]){
                    cylinder(h = 2*bottom_section_height, r = main_shaft_diameter*1.72);
                }
            }
    cylinder(r1=main_shaft_diameter*1.662, r2=bottom_section_height, h=ridge_width);
    }
}
}

// Common subcomponents
module buoy_divider(vertical_offset) {
    translate([0,0,vertical_offset]){
        cube([bottom_section_height+ridge_width,bottom_section_height+ridge_width,1], true);
    }
}

module buoy_section(vertical_offset, height_pcnt) {
    translate([0,0,vertical_offset]){
       cube([bottom_section_height, bottom_section_height, bottom_section_height*height_pcnt], true);
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
        cylinder(d=bottom_section_height*1.4, h=bottom_section_height*3.2);
        buoy_top_raw();
    }
    translate([0,0,bottom_section_height*3-1]){
        cylinder(d1=bottom_section_height, d2=bottom_section_height*2, h=ridge_width);
    }
    top_cap(bottom_section_height*3+1);
}

// Internal: raw geometry for top assembly
module buoy_top_raw(){
    buoy_section(bottom_section_height+bottom_section_height*.4,.8);
    buoy_divider(bottom_section_height);
    buoy_section(bottom_section_height/2, 1);
    pillars(0, bottom_section_height);
    pillars(bottom_section_height, bottom_section_height*.8);
    criss_cross(bottom_section_height, bottom_section_height*1.3, bottom_section_height*2.45);
    buoy_divider(bottom_section_height*2.3+2);

}

// Subcomponent: top cap
module top_cap(vertical_offset){
    translate([0,0,vertical_offset]){
        cylinder(d=2*bottom_section_height, h=ridge_width);
    }
    translate([0,0,vertical_offset+ridge_width]){
        cylinder(d=1.5*ridge_width, h=ridge_width);
    }
}


// Assemble
buoy_bottom();
buoy_top();
