/*  Parametric Extended Knurled Vz.61 Charging Knob — v4.1
    - fit_check=true: plain cylinder body, no dish (fast fit coupon)
    - fit_check=false: full knurl + chamfers + dish
    - Two-tier obround nub, debossed fit_clear label
    Print: flat face down, 100% infill, 5+ walls.
*/

// ---- Mode ----
fit_check   = true;   // true = plain fast coupon, false = final knob

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

fit_clear  = 0.0;   // subtracted from nub radii; tune via test coupon

// ---- Variant label ----
label_size = 2.6;
label_deep = 0.4;   // 2 layers at 0.2mm

$fn = 90;

// ================= MAIN =================
knob(fit_clear);

// batch of variants instead:
// for (i = [0:2]) translate([i*24, 0, 0]) knob(i * 0.1);

module knob(fc) {
    difference() {
        union() {
            if (fit_check)
                cylinder(d=knob_d, h=knob_h);
            else
                knurled_knob();
            translate([0,0,knob_h])
                obround(neck_mid, neck_r - fc, neck_h);
            translate([0,0,knob_h + neck_h])
                obround_ch(head_mid, head_r - fc, head_h, head_ch);
        }
        // thumb dish — final version only (skip on coupon: faster, flatter bed face)
        if (!fit_check && dish_depth > 0) {
            R = (dish_dia*dish_dia/4 + dish_depth*dish_depth) / (2*dish_depth);
            translate([0,0,-(R - dish_depth)]) sphere(r=R);
        }
        // debossed variant label on top face, beside the nub
        translate([0, -(head_r + 1.2 + label_size/2), knob_h - label_deep])
            linear_extrude(label_deep + 0.01)
                text(str(fc), size=label_size,
                     font="Liberation Sans:style=Bold",
                     halign="center", valign="center");
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
