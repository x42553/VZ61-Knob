/*  ============================================================
    Vz.61 Extended Charging Knob — Parametric OpenSCAD
    Copyright (c) 2026 Simon Fischer
    First published: 2026-07-20
    Canonical source: https://github.com/x42553/VZ61-Knob/
    License: CC BY-SA 4.0
             https://creativecommons.org/licenses/by-sa/4.0/

    You may print, modify, and share this design — including commercially — provided you (a) credit the author and link the canonical source, and (b) release any derivative under this same license. You may NOT relicense this design or any derivative under more restrictive terms, and no one may assert claims against people printing or sharing it under this license.

    Authorship provenance: full development history (v1..v16, fit-test records) lives in the canonical repo. If anyone claims ownership of this design, check the commit history there. Printed parts carry an embedded internal watermark.
    ============================================================ */
    /*  Parametric Vz.61 Charging Knob — v16
    body_style: "knurl" | "fin" | "spur"
      knurl: round knurled knob          (face-down print)
      fin:   blade in the face plane     (face-down print)
      spur:  blade standing OFF the receiver — hollow window, jimped +
             curved trailing edge (print lying on blade side; small
             support tower under the nub only)
    fit_check=true: plain cylinder coupon body
    socket=true: bayonet keyhole to stow/use the OG knob — twist 90° CCW,
      lock with radial M3 grub screw. KNURL/FIN ONLY. Conical roof.
      screw_mode: "selftap" (FDM/SLS) | "tap" (SLA/CNC; spec "M3 THRU"
      on the drawing — threads are NOT modeled) | "clearance" | "none"
    knurl_preset: "fdm04" | "fdm06" | "sla" | "sls" | "cnc" | "custom"
    v16 WATERMARKS (provenance, not protection — geometry is always
    removable/remodelable; pair with an explicit license):
      wm_visible:  small deboss on the bolt-side face (deters lazy
                   re-uploads; trivially sanded/edited away)
      wm_internal: text-shaped VOID buried inside solid material —
                   invisible on the part, visible in slicer layer
                   preview, provable by sectioning a print. Auto-skipped
                   when socket=true (no safe solid volume remains).
    
    v16 FIX: fit label on the spur previously landed outside the 8mm blade thickness (no label printed); now placed on the base top face beside the nub, rotated to fit.
    
    Two-tier obround nub (dims = OVERALL), head_uch default 0 (validated
    flat bearing ledge). Print: 100% infill, 5+ walls, layer 0.2mm max,
    CF-nylon for fin/spur. NO support inside the socket cavity.
*/

// ---- Mode ----
fit_check   = false;
body_style  = "spur";   // "knurl" | "fin" | "spur"
socket      = false;     // OG-knob bayonet socket (knurl/fin only)

// ---- Watermarks ----
wm_text     = "SF-26";   // your mark; keep short
wm_visible  = true;      // deboss on bolt-side face
wm_internal = true;      // buried void (skipped when socket=true)
wm_size     = 2.2;
wm_deep     = 0.4;       // visible deboss depth
wm_void_t   = 0.6;       // internal void thickness (keep <= 0.6)

// ---- Socket ----
sock_clear  = 0.15;   // per-side vs steel OG nub; coupon-test 0.15/0.25
sock_plate  = 1.45;   // retention plate; MAX = OG neck height 1.5
sweep_step  = 5;      // degrees per slice of the 90° neck sweep cut
roof_angle  = 40;     // cavity roof cone; >=~35 support-free; 0 = flat

// ---- Grub screw hole ----
screw_mode  = "selftap";  // "selftap" | "tap" | "clearance" | "none"
// selftap:   O2.6 — M3 self-taps into FDM/SLS plastic
// tap:       O2.5 — M3x0.5 tap drill; hand-tap (SLA/CNC)
// clearance: O3.4 — M3 passes through (split-plate variants)
// Rendered/SLA threads: use BOSL2 threaded_rod(..., internal=true)

// ---- Knob / boss ----
knob_d      = 18;     // 18 recommended if socket=true; 16 min otherwise
knob_h      = 10;
rim_chamfer = 0.8;

// ---- Dish (knurl final only; ignored when socket=true) ----
dish_depth  = 1.5;
dish_dia    = 12;

// ---- Knurl ----
knurl_preset = "fdm04";  // "fdm04" | "fdm06" | "sla" | "sls" | "cnc" | "custom"

// used only when knurl_preset = "custom"
knurl_n     = 24;
knurl_depth = 0.6;
helix_angle = 30;

// ---- Fin (blade in face plane) ----
fin_len     = 22;
fin_sweep   = 6;
fin_tip_r   = 4;
fin_scoop_r = 18;
fin_scoop_x = 12;
fin_scoop_y = 16;
fin_angle   = 90;    // rotation about nub axis (fin AND spur)

// ---- Spur (blade standing off the receiver) ----
spur_out    = 16;
spur_thick  = 8;
spur_base   = 18;
spur_rake   = 6;
spur_tip_r  = 3.5;
spur_scoop_r   = 14;
spur_scoop_off = 11;
spur_round  = 1.2;

// ---- Spur skeleton window ----
spur_hollow = true;
spur_wall   = 3.5;
spur_web    = 5;      // solid band under the nub (hosts internal wm)

// ---- Spur jimping ----
jimp_on     = true;
jimp_r      = 1.0;
jimp_pitch  = 3.0;
jimp_margin = 3;

// ---- Spur trailing-edge curve ----
trail_curve = 2.5;    // inward bow (sagitta); 0 = straight

// ---- Nub: two-tier obround (all dims = OVERALL, tip-to-tip) ----
// Also defines the socket negative — these ARE the OG measurements.
neck_len   = 9;      neck_w = 3.0;  neck_h = 1.5;
head_len   = 10;     head_w = 4.0;  head_h = 3.5;
head_ch    = 0.5;
head_uch   = 0;      // 0 = flat ledge (VALIDATED: full bearing, no
                     // wobble; prints support-free). 0.3 max if needed.

fit_clear  = 0.0;    // validated on coupons: 0.0

// ---- Variant label ----
label_size = 2.6;
label_deep = 0.4;

$fn = 90;

// ================= MAIN =================
knob(fit_clear);
// for (i = [0:2]) translate([i*24, 0, 0]) knob(i * 0.1);

module knob(fc) {
    use_socket = socket && body_style != "spur" && !fit_check;
    difference() {
        union() {
            if (fit_check)               cylinder(d=knob_d, h=knob_h);
            else if (body_style=="fin")  rotate([0,0,fin_angle]) fin_body();
            else if (body_style=="spur") rotate([0,0,fin_angle]) spur_body();
            else                         knurled_knob();
            translate([0,0,knob_h])
                obround(neck_len - neck_w, neck_w/2 - fc, neck_h);
            translate([0,0,knob_h + neck_h])
                obround_ch2(head_len - head_w, head_w/2 - fc,
                            head_h, head_ch, head_uch);
        }
        if (use_socket) socket_cut();
        if (!fit_check && !use_socket && body_style=="knurl" && dish_depth > 0) {
            R = (dish_dia*dish_dia/4 + dish_depth*dish_depth) / (2*dish_depth);
            translate([0,0,-(R - dish_depth)]) sphere(r=R);
        }
        // fit label (bolt-side face); spur: on base top face, rotated in
        if (body_style=="spur")
            rotate([0,0,fin_angle])
                translate([(head_len/2 + spur_base/2)/2, 0, knob_h - label_deep])
                    deboss_text(str(fc), label_size, label_deep, 90);
        else
            translate([0, -(head_w/2 + 1.2 + label_size/2), knob_h - label_deep])
                deboss_text(str(fc), label_size, label_deep);
        // watermarks
        if (wm_visible)  wm_visible_cut();
        if (wm_internal) wm_internal_cut(use_socket);
    }
}

// ================ WATERMARKS ================
module deboss_text(t, sz, dp, rot=0)
    linear_extrude(dp + 0.01)
        rotate([0,0,rot])
            text(t, size=sz, font="Liberation Sans:style=Bold",
                 halign="center", valign="center");

// visible deboss: bolt-side face, opposite the fit label
module wm_visible_cut() {
    if (body_style == "spur")
        rotate([0,0,fin_angle])
            translate([-(head_len/2 + spur_base/2)/2, 0, knob_h - wm_deep])
                deboss_text(wm_text, wm_size, wm_deep, 90);
    else
        translate([0, head_w/2 + 1.2 + wm_size/2, knob_h - wm_deep])
            deboss_text(wm_text, wm_size, wm_deep);
}

// internal void: buried in solid material, >=0.8mm from all surfaces.
// Invisible on the part; shows in slicer layer preview; provable by
// sectioning. Skipped with socket (no safe solid volume remains).
module wm_internal_cut(sock) {
    if (sock)
        echo("WATERMARK: internal void skipped (socket occupies the safe volume)");
    else if (body_style == "spur")
        // inside the solid web band under the nub (world z 6.2..6.8)
        rotate([0,0,fin_angle])
            translate([0, 0, knob_h - spur_web + 1.2])
                linear_extrude(wm_void_t)
                    text(wm_text, size=wm_size,
                         font="Liberation Sans:style=Bold",
                         halign="center", valign="center");
    else
        // mid-body, clear of dish below and nub root above
        translate([0, 0, 0.42*knob_h])
            linear_extrude(wm_void_t)
                text(wm_text, size=wm_size,
                     font="Liberation Sans:style=Bold",
                     halign="center", valign="center");
}

// ================ SOCKET ================
module stadium2d(len, w, c)
    hull() for (x = [-1,1])
        translate([x*(len - w)/2, 0]) circle(r=w/2 + c);

module socket_cut() {
    cav_d   = head_len + 2*sock_clear + 0.4;
    cav_top = sock_plate + head_h + 0.2;
    cone_h_full = (cav_d/2) * tan(roof_angle);
    cone_h      = min(cone_h_full, knob_h - 0.4 - cav_top);
    assert(cone_h > 0 || roof_angle == 0,
           "socket roof cone does not fit: increase knob_h or lower roof_angle");

    // through-plate keyhole: head entry + neck 90° CCW swept region
    translate([0,0,-0.01]) linear_extrude(sock_plate + 0.02) {
        stadium2d(head_len, head_w, sock_clear);
        for (a = [0 : sweep_step : 90])
            rotate([0,0,a]) stadium2d(neck_len, neck_w, sock_clear);
    }
    // rotation cavity: snug axially at the rim
    translate([0,0,sock_plate])
        cylinder(d=cav_d, h=head_h + 0.2);
    // self-supporting conical roof
    if (roof_angle > 0)
        translate([0,0,cav_top])
            cylinder(d1=cav_d, d2=0.8, h=cone_h);
    // radial grub hole (+Y): bears on head end after twist
    screw_d = screw_mode == "selftap"   ? 2.6 :
              screw_mode == "tap"       ? 2.5 :
              screw_mode == "clearance" ? 3.4 : 0;
    if (screw_d > 0)
        translate([0, knob_d/2 + 1, sock_plate + head_h/2 + 0.1])
            rotate([90,0,0])
                cylinder(d=screw_d, h=knob_d/2 - head_len/2 + 2, $fn=24);
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

// ================ SPUR ================
function unit(v) = v / norm(v);

function spur_P()  = [spur_base/2, 0];
function spur_Ct() = [spur_rake, -spur_out + spur_tip_r];
function spur_tdir() =
    let(dv = unit(spur_Ct() - spur_P()),
        a  = asin(spur_tip_r / norm(spur_Ct() - spur_P())))
    [dv.x*cos(a) - dv.y*sin(a), dv.x*sin(a) + dv.y*cos(a)];
function spur_T() = spur_P() + spur_tdir()
    * sqrt(pow(norm(spur_Ct()-spur_P()), 2) - spur_tip_r*spur_tip_r);

function trail_R() =
    let(c = norm(spur_T() - spur_P()))
    (c*c/4 + trail_curve*trail_curve) / (2*trail_curve);
function trail_O() =
    let(M = (spur_P() + spur_T())/2, t = unit(spur_T() - spur_P()))
    M + [-t.y, t.x] * (trail_R() - trail_curve);

module jimping2d() {
    if (trail_curve > 0) {
        O = trail_O(); R = trail_R();
        aP = atan2(spur_P().y - O.y, spur_P().x - O.x);
        aT = atan2(spur_T().y - O.y, spur_T().x - O.x);
        dA = aT - aP;
        sw = dA > 180 ? dA - 360 : dA < -180 ? dA + 360 : dA;
        mA = jimp_margin / R * 180/PI;
        pA = jimp_pitch  / R * 180/PI;
        n  = floor((abs(sw) - 2*mA) / pA);
        s  = sign(sw);
        for (i = [0:n]) {
            a = aP + s*(mA + i*pA);
            translate(O + R*[cos(a), sin(a)])
                circle(r=jimp_r, $fn=24);
        }
    } else {
        P = spur_P(); t = spur_tdir();
        L = sqrt(pow(norm(spur_Ct()-P),2) - spur_tip_r*spur_tip_r);
        n = floor((L - 2*jimp_margin) / jimp_pitch);
        for (i = [0:n])
            translate(P + t*(jimp_margin + i*jimp_pitch))
                circle(r=jimp_r, $fn=24);
    }
}

module spur_profile() {
    difference() {
        spur_outline();
        if (spur_hollow)
            intersection() {
                offset(r=-spur_wall) spur_outline();
                translate([-50, -100]) square([100, 100 + knob_h - spur_web]);
            }
        if (jimp_on) jimping2d();
    }
}

module spur_outline() {
    offset(r=spur_round) offset(delta=-spur_round)
    difference() {
        hull() {
            translate([-spur_base/2, 0]) square([spur_base, knob_h]);
            translate([spur_rake, -spur_out + spur_tip_r])
                circle(r=spur_tip_r);
        }
        translate([-(spur_base/2 + spur_scoop_off), -spur_out/2])
            circle(r=spur_scoop_r);
        if (trail_curve > 0)
            translate(trail_O()) circle(r=trail_R(), $fn=180);
    }
}

module spur_body()
    rotate([90,0,90])
        linear_extrude(spur_thick, center=true)
            spur_profile();

// ================ KNURL ================
function kp_from_pitch(d, pitch, depth, ha) =
    [max(8, round(PI*d/pitch)), depth, ha];

function knurl_params(p, d) =
    p == "fdm04" ? kp_from_pitch(d, 2.0, 0.60, 30) :  // 0.4 nozzle floor
    p == "fdm06" ? kp_from_pitch(d, 3.2, 0.80, 30) :  // coarse, deep
    p == "sla"   ? kp_from_pitch(d, 1.0, 0.35, 30) :  // fine; brittle-safe
    p == "sls"   ? kp_from_pitch(d, 1.6, 0.50, 30) :  // powder-rounding safe
    p == "cnc"   ? kp_from_pitch(d, 1.0, 0.30, 30) :  // visual DIN 82 RGE 1.0
                   [knurl_n, knurl_depth, helix_angle];

module knurled_knob() {
    kp = knurl_params(knurl_preset, knob_d);
    echo(str("knurl: n=", kp[0], " pitch=", PI*knob_d/kp[0],
             "mm depth=", kp[1], " helix=", kp[2]));
    intersection() {
        knurl_cyl(knob_d, knob_h, kp[0], kp[1], kp[2]);
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

// ================ SHARED ================
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
