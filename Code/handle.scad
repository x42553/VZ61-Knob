/*  Parametric Extended Knurled Vz.61 Charging Knob — v3
    - Helical diamond knurl, chamfered rims, exact-depth thumb dish
    - Two-tier obround nub from OG measurements
    Print: flat (dished) face down, 100% infill, 5+ walls, CF-nylon or resin.
*/

// ---- Knob ----
knob_d      = 16;
knob_h      = 10;
rim_chamfer = 0.8;

// ---- Dish (exposed face, z=0) ----
dish_depth  = 1.5;
dish_dia    = 12;

// ---- Knurl ----
knurl_n     = 24;
knurl_depth = 0.6;
helix_angle = 30;

// ---- Nub: two-tier obround ----
// "mid" = straight middle section; overall length = mid + 2*r
neck_mid   = 9;     // bottom tier (sits in bolt slot)
neck_r     = 2.0;
neck_h     = 1.5;

head_mid   = 10;    // top tier (retaining head)
head_r     = 2.0;
head_h     = 3.5;
head_ch    = 0.5;   // chamfer around top edge

fit_clear  = 0.0;   // subtracted from radii; tune via test coupon

$fn = 90;

// ================= MAIN =================
difference() {
    union() {
        knurled_knob();
        translate([0,0,knob_h])
            obround(neck_mid, neck_r - fit_clear, neck_h);
        translate([0,0,knob_h + neck_h])
            obround_ch(head_mid, head_r - fit_clear, head_h, head_ch);
    }
    if (dish_depth > 0) {
        R = (dish_dia*dish_dia/4 + dish_depth*dish_depth) / (2*dish_depth);
        translate([0,0,-(R - dish_depth)]) sphere(r=R);
    }
}

// ================ MODULES ================
module knurled_knob() {
    intersection() {
        knurl_cyl(knob_d, knob_h, knurl_n, knurl_depth, helix_angle);
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

module obround(mid, r, h)
    hull() for (x = [-mid/2, mid/2])
        translate([x,0,0]) cylinder(r=r, h=h);

module obround_ch(mid, r, h, ch)
    hull() for (x = [-mid/2, mid/2])
        translate([x,0,0]) {
            cylinder(r=r, h=h - ch);
            translate([0,0,h-ch]) cylinder(r1=r, r2=r-ch, h=ch);
        }
