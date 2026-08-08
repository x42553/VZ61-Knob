/* 
   Parametric Extended & Knurled Vz.61 Charging Handle/Knob

   Tips for printing: 
   - Print with the large flat face of the knob on the print bed.
   - Use high infill (80-100%) and 4+ walls for structural strength.
   - If using FDM plastic, hand-fitting the mounting nub with a fine 
     file is highly recommended for a crisp, perfect fit into your bolt.
*/
// --- PARAMETERS ---
// Knob Dimensions
knob_diameter  = 16;      // Original is tiny (~10mm); 16-18mm gives great grip
knob_thickness = 10;      // Thickness of the main outer body
ergonomic_dish = 1.5;     // Depth of the subtle thumb dish on the face
// Knurling Settings
knurl_lines     = 18;     // Total number of criss-cross cuts around the perimeter
knurl_depth     = 0.6;    // Depth of the texture cuts
knurl_width     = 1.0;    // Width of the knurling grooves
// Mounting Nub Dimensions (The part that slots into the bolt)
// Note: Measure your original nub or bolt slot carefully!
nub_diameter   = 5.5;     // Diameter of the inner neck / mounting pin
nub_length     = 6.0;     // How far the nub extends into the receiver/bolt
nub_flat_cut   = 1.2;     // Flat engagement depth (if your bolt uses a keyed slot)
$fn = 60;                 // Overall geometry smoothness
// --- MAIN ASSEMBLY ---
difference() {
    union() {
        // Main Textured Knob Body
        knurled_body(d=knob_diameter, h=knob_thickness, n=knurl_lines, depth=knurl_depth, kw=knurl_width);

        // Mounting Pin / Nub Extension
        translate([0, 0, knob_thickness/2])
            mounting_nub(d=nub_diameter, h=nub_length, flat=nub_flat_cut);
    }

    // Ergonomic Thumb Dish (removes material from the exposed front face)
    translate([0, 0, -knob_thickness/2 - 18]) // Big sphere cutout
        sphere(r=20 + ergonomic_dish);
}
// --- MODULES ---
// Generates the main cylindrical body with crossed knurling texture
module knurled_body(d, h, n, depth, kw) {
    difference() {
        // Base Cylinder
        cylinder(d=d, h=h, center=true);

        // Right-handed diamond cuts
        for (i = [0 : n-1]) {
            rotate([0, 0, i * (360 / n)])
                translate([d/2 - depth/2, 0, 0])
                    rotate([35, 0, 0]) // Angle of twist
                        cube([depth * 2, kw, h * 2], center=true);
        }

        // Left-handed diamond cuts
        for (i = [0 : n-1]) {
            rotate([0, 0, i * (360 / n)])
                translate([d/2 - depth/2, 0, 0])
                    rotate([-35, 0, 0]) // Opposite twist
                        cube([depth * 2, kw, h * 2], center=true);
        }
    }
}
// Generates the attachment nub that locks into the bolt slot
module mounting_nub(d, h, flat) {
    difference() {
        // Standard pin extension
        cylinder(d=d, h=h, $fn=40);

        // Optional flat side cutout (common on Vz.61 handles to lock alignment)
        if (flat > 0) {
            translate([d/2 - flat + 5/2, 0, h/2])
                cube([5, d + 1, h + 1], center=true);
        }
    }
}
