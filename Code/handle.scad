/*  Parametric Vz.61 Charging Knob — v8
    body_style: "knurl" | "fin"   fit_check: plain coupon body
    socket=true: keyhole bayonet in the face to stow the OG knob
                 (insert, twist 90°, lock with radial M3 grub screw)
    Two-tier obround nub (dims = OVERALL), debossed fit_clear label,
    45° head underside chamfer -> support-free.
    Print: face down, 100% infill, 5+ walls, layer 0.2mm max.
*/

// ---- Mode ----
fit_check   = false;
body_style  = "knurl";   // "knurl" | "fin"
socket      = true;      // OG-knob stowage socket (replaces dish)

// ---- Socket ----
sock_clear  = 0.15;   // per-side; printed holes run tight — start here
sock_plate  = 1.4;    // retention plate (slightly under OG neck 1.5)
sock_screw  = 2.6;    // M3 self-tap pilot Ø; 0 = no screw hole

// ---- Knob / boss ----
knob_d      = 16;
knob_h      = 10;
rim_chamfer = 0.8;

// ---- Dish (final only, ignored when socket=true) ----
dish_depth  = 1.5;
dish_dia    = 12;

// ---- Knurl ----
knurl_n     = 24;
knurl_depth = 0.6;
helix_angle = 30;

// ---- Fin ----
fin_len     = 22;
fin_sweep   = 6;
fin_tip_r   = 4;
fin_scoop_r = 18;
fin_scoop_x = 12;
fin_scoop_y = 16;
fin_angle   = 0;

// ---- Nub: two-tier obround (all dims = OVERALL, tip-to-tip) ----
// Also defines the socket negative — these ARE the OG measurements.
neck_len   = 9;      neck_w = 3.0;  neck_h = 1.5;
head_len   = 10;     head_w = 4.0;  head_h = 3.5;
head_ch    = 0.5;    head_uch = 0.5;

fit_clear  = 0.0;

// ---- Variant label ----
label_size = 2.6;
label_deep = 0.4;

$fn = 90;

// ================= MAIN =================
knob(fit_clear);
// for (i = [0:2]) translate([i*24, 0, 0]) knob(i * 0.1);

module knob(fc) {
    difference() {
        union() {
            if (fit_check)              cylinder(d=knob_d, h=knob_h);
            else if (body_style=="fin") rotate([0,0,fin_angle]) fin_body();
            else                        knurled_knob();
            translate([0,0,knob_h])
                obround(neck_len - neck_w, neck_w/2 - fc, neck_h);
            translate([0,0,knob_h + neck_h])
                obround_ch2(head_len - head_w, head_w/2 - fc,
                            head_h, head_ch, head_uch);
        }
        if (socket) socket_cut();
        if (!fit_check && !socket && dish_depth > 0) {
            R = (dish_dia*dish_dia/4 + dish_depth*dish_depth) / (2*dish_depth);
            translate([0,0,-(R - dish_depth)]) sphere(r=R);
        }
        translate([0, -(head_w/2 + 1.2 + label_size/2), knob_h - label_deep])
            linear_extrude(label_deep + 0.01)
                text(str(fc), size=label_size,
                     font="Liberation Sans:style=Bold",
                     halign="center", valign="center");
    }
}

// ================ SOCKET ================
module socket_cut() {
    // keyhole through plate: head entry obround + neck rotation bore
    translate([0,0,-0.01])
        linear_extrude(sock_plate + 0.02) {
            hull() for (x = [-1,1])
                translate([x*(head_len - head_w)/2, 0])
                    circle(r=head_w/2 + sock_clear);
            circle(d=neck_len + 2*sock_clear);
        }
    // rotation cavity (stadium's swept circle = its overall length)
    translate([0,0,sock_plate])
        cylinder(d=head_len + 2*sock_clear + 0.4, h=head_h + 0.4);
    // radial grub screw pilot (+Y wall), bears on head end after 90° twist
    if (sock_screw > 0)
        translate([0, knob_d/2 + 1, sock_plate + head_h/2 + 0.2])
            rotate([90,0,0])
                cylinder(d=sock_screw, h=knob_d/2 - head_len/2 + 2, $fn=24);
}

// ================ FIN ================
module fin_profile() {
    difference() {
        hull() {
            circle(d=knob_d);
            translate([fin_len, -fin_sweep]) circle(r=fin_tip_r);
        }
        translate([fin_scoop_x, fin_scoop_y]) circle(r=fin_scoop_r);
    }
}

module fin_body(steps=4) {
    ch = rim_chamfer; dz = ch/steps;
    for (i=[0:steps-1]) {
        translate([0,0,i*dz]) linear_extrude(dz+0.01)
            offset(r=-(ch-(i+1)*dz)) fin_profile();
        translate([0,0,knob_h-(i+1)*dz]) linear_extrude(dz+0.01)
            offset(r=-(ch-(i+1)*dz)) fin_profile();
    }
    translate([0,0,ch]) linear_extrude(knob_h-2*ch) fin_profile();
}

// ================ SHARED ================
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

module obround_ch2(mid, r, h, ch_t, ch_b)
    hull() for (x = [-mid/2, mid/2])
        translate([x,0,0]) {
            if (ch_b > 0) cylinder(r1=r-ch_b, r2=r, h=ch_b);
            translate([0,0,ch_b]) cylinder(r=r, h=h-ch_t-ch_b);
            translate([0,0,h-ch_t]) cylinder(r1=r, r2=r-ch_t, h=ch_t);
        }
