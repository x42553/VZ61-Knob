/*  Parametric Extended Knurled Vz.61 Charging Knob — v6
    - fit_check=true: plain cylinder body, no dish (fast fit coupon)
    - fit_check=false: full knurl + chamfers + thumb dish (final)
    - Two-tier obround nub, all dims = OVERALL tip-to-tip
    - head_uch: 45° underside chamfer on head -> support-free print
    - Debossed fit_clear label on top face
    Print: flat face down, 100% infill, 5+ walls, layer 0.2mm max.
    0.6mm nozzle: consider knurl_n=16 / knurl_depth=0.8 for crisper diamonds.
*/

// ---- Mode ----
fit_check   = true;   // true = fit coupon, false = final knob

// ---- Knob ----
knob_d      = 16;
knob_h      = 10;
rim_chamfer = 0.8;

// ---- Dish (exposed face, z=0; final only) ----
dish_depth  = 1.5;
dish_dia    = 12;

// ---- Knurl (final only) ----
knurl_n     = 24;
knurl_depth = 0.6;
helix_angle = 30;

// ---- Nub: two-tier obround (all dims = OVERALL, tip-to-tip) ----
neck_len   = 9;      // bottom tier: overall length
neck_w     = 3.0;    //              width
neck_h     = 1.5;    //              height

head_len   = 10;     // top tier:    overall length
head_w     = 4.0;    //              width
head_h     = 3.5;    //              height
head_ch    = 0.5;    //              chamfer around top edge
head_uch   = 0.5;    //              underside chamfer, 45° support-free
                     //              (0 = flat ledge; reduce to 0.3 if the
                     //              head won't seat flush in the slot)

fit_clear  = 0.0;    // subtracted from nub half-widths; negative = tighter

// ---- Variant label ----
label_size = 2.6;
label_deep = 0.4;    // 2 layers at 0.2mm

$fn = 90;

// ================= MAIN =================
knob(fit_clear);

// coupon batch — uncomment for fit-check run:
// for (i = [0:2]) translate([i*24, 0, 0]) knob(i * 0.1);

module knob(fc) {
    difference() {
        union() {
            if (fit_check)
                cylinder(d=knob_d, h=knob_h);
            else
                knurled_knob();
            translate([0,0,knob_h])
                obround(neck_len - neck_w, neck_w/2 - fc, neck_h);
            translate([0,0,knob_h + neck_h])
                obround_ch2(head_len - head_w, head_w/2 - fc,
                            head_h, head_ch, head_uch);
        }
        // thumb dish — final version only
        if (!fit_check && dish_depth > 0) {
            R = (dish_dia*dish_dia/4 + dish_depth*dish_depth) / (2*dish_depth);
            translate([0,0,-(R - dish_depth)]) sphere(r=R);
        }
        // debossed variant label on top face, beside the nub
        translate([0, -(head_w/2 + 1.2 + label_size/2), knob_h - label_deep])
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

// head with top chamfer (ch_t) and 45° underside chamfer (ch_b)
module obround_ch2(mid, r, h, ch_t, ch_b)
    hull() for (x = [-mid/2, mid/2])
        translate([x,0,0]) {
            if (ch_b > 0) cylinder(r1=r-ch_b, r2=r, h=ch_b);
            translate([0,0,ch_b]) cylinder(r=r, h=h-ch_t-ch_b);
            translate([0,0,h-ch_t]) cylinder(r1=r, r2=r-ch_t, h=ch_t);
        }
