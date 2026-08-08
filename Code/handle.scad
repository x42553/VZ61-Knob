/*  Parametric Extended Knurled Vz.61 Charging Knob — v2
    - True helical diamond knurl (twisted extrude intersection)
    - Chamfered rims, parametrically-correct thumb dish
    - Filleted nub root + optional M4 steel-core bore (recommended)
    Print: flat face down, 100% infill, 5+ walls. If dish quality
    on the bed face bothers you, set dish_depth = 0 or flip and
    support the nub.
*/

// ---- Knob ----
knob_d      = 16;
knob_h      = 10;
rim_chamfer = 0.8;

// ---- Dish (exposed face, z=0) ----
dish_depth  = 1.5;    // actual depth, guaranteed
dish_dia    = 12;     // opening diameter on the face

// ---- Knurl ----
knurl_n     = 24;     // teeth around circumference (pitch = PI*d/n ≈ 2.1mm)
knurl_depth = 0.6;
helix_angle = 30;     // degrees

// ---- Nub ----
nub_d       = 5.5;
nub_len     = 6.0;
nub_flat    = 1.2;    // depth of keying flat (0 = none)
nub_fillet  = 1.0;    // root fillet — do not skip this

// ---- Optional steel core ----
steel_core  = false;  // true: M4 screw through-bore + counterbore
core_d      = 4.3;    // M4 clearance
cbore_d     = 8.2;    // socket head
cbore_h     = 4.2;

$fn = 90;

// ================= MAIN =================
difference() {
    union() {
        knurled_knob();
        // nub + root fillet, keyed flat cut through both
        difference() {
            union() {
                translate([0,0,knob_h])
                    cylinder(d=nub_d, h=nub_len);
                translate([0,0,knob_h])
                    cylinder(d1=nub_d+2*nub_fillet, d2=nub_d, h=nub_fillet);
            }
            if (nub_flat > 0)
                translate([nub_d/2 - nub_flat, -25, knob_h - 0.01])
                    cube([50, 50, nub_len + 1]);
        }
    }
    // thumb dish — exact depth
    if (dish_depth > 0) {
        R = (dish_dia*dish_dia/4 + dish_depth*dish_depth) / (2*dish_depth);
        translate([0,0,-(R - dish_depth)]) sphere(r=R);
    }
    // steel core bore
    if (steel_core) {
        translate([0,0,-1]) cylinder(d=core_d, h=knob_h+nub_len+2);
        translate([0,0,-0.01]) cylinder(d=cbore_d, h=cbore_h);
    }
}

// ================ MODULES ================
module knurled_knob() {
    intersection() {
        knurl_cyl(knob_d, knob_h, knurl_n, knurl_depth, helix_angle);
        // chamfer envelope
        rotate_extrude()
            polygon([
                [0,0],[knob_d/2-rim_chamfer,0],[knob_d/2,rim_chamfer],
                [knob_d/2,knob_h-rim_chamfer],[knob_d/2-rim_chamfer,knob_h],[0,knob_h]
            ]);
    }
}

module knurl_cyl(d, h, n, depth, ha) {
    twist = 360 * h * tan(ha) / (PI * d);
    pts = [for (i=[0:2*n-1])
            let(a = i*180/n, r = (i%2==0) ? d/2 : d/2-depth)
            [r*cos(a), r*sin(a)]];
    intersection() {
        linear_extrude(h, twist= twist, slices=ceil(h*4), convexity=10) polygon(pts);
        linear_extrude(h, twist=-twist, slices=ceil(h*4), convexity=10) polygon(pts);
    }
}
