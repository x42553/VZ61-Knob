/*  Parametric Vz.61 Charging Knob — v17
    body_style: "knurl" | "fin" | "spur"
    fit_check=true: plain cylinder coupon body
    socket=true: bayonet keyhole (knurl/fin only), conical roof,
      screw_mode selects grub hole spec (selftap/tap/clearance/none)
    knurl_preset: "fdm04" | "fdm06" | "sla" | "sls" | "cnc" | "custom"
    Watermarks: wm_visible (deboss) + wm_internal (buried void,
      auto-skipped with socket)
    v17: spur_support — INTEGRATED breakaway support for the spur's
      side-lying FDM print (replaces slicer-generated tower):
      - tower under the nub, sized from the nub's rotated footprint,
        separated by sup_gap (~1 layer); snaps off by hand
      - if fin_angle makes the nub protrude past the blade face
        (|sin(fin_angle)| large, e.g. 90deg), fused skid rails are added
        under the blade automatically so the part still lies flat;
        rails are sacrificial — cut/sand off after printing (echo warns)
      - FDM ONLY: SLS needs no supports at all (powder bed);
        SLA should use the slicer's own angled supports instead
    Two-tier obround nub (dims = OVERALL), head_uch default 0
    (validated flat bearing ledge).
    Print: 100% infill, 5+ walls, layer 0.2mm max, CF-nylon for
    fin/spur. NO support inside the socket cavity.
*/

// ---- Mode ----
fit_check   = false;
body_style  = "spur";   // "knurl" | "fin" | "spur"
socket      = false;     // OG-knob bayonet socket (knurl/fin only)

// ---- Spur integrated print support (FDM side-lying print) ----
spur_support = true;    // breakaway tower under the nub (spur only)
sup_gap      = 0.20;     // breakaway gap, ~1 layer height
sup_inset    = 0.6;      // tower shrink vs nub footprint, per side

// ---- Watermarks ----
wm_text     = "SF-26";   // your mark; keep short
wm_visible  = true;      // deboss on bolt-side face
wm_internal = true;      // buried void (skipped when socket=true)
wm_size     = 2.2;
wm_deep     = 0.4;
wm_void_t   = 0.6;

// ---- Socket ----
sock_clear  = 0.15;
sock_plate  = 1.45;   // MAX = OG neck height 1.5
sweep_step  = 5;
roof_angle  = 40;     // >=~35 support-free; 0 = flat (ok for SLA)

// ---- Grub screw hole ----
screw_mode  = "selftap";  // "selftap" | "tap" | "clearance" | "none"
// selftap O2.6 (FDM/SLS) | tap O2.5 (SLA/CNC, spec "M3 THRU" on the
// drawing — threads not modeled) | clearance O3.4 | none

// ---- Knob / boss ----
knob_d      = 18;
knob_h      = 10;
rim_chamfer = 0.8;

// ---- Dish (knurl final only; ignored when socket=true) ----
dish_depth  = 1.5;
dish_dia    = 12;

// ---- Knurl ----
knurl_preset = "fdm04";  // "fdm04" | "fdm06" | "sla" | "sls" | "cnc" | "custom"
knurl_n     = 24;        // used only when knurl_preset = "custom"
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
head_uch   = 0;      // 0 = flat ledge (VALIDATED). 0.3 max if needed.

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
            if (body_style=="spur" && spur_support && !fit_check)
                rotate([0,0,fin_angle]) spur_support_body();
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

// ================ SPUR SUPPORT ================
// Local blade frame: thickness along Y, bed = -Y face when side-lying.
// Nub footprint in this frame = world nub rotated by -fin_angle.

// lowest extent of the head footprint below the nub axis, local frame
function nub_hy() = (head_len - head_w)/2 * abs(sin(fin_angle)) + head_w/2;

// local-frame head footprint, grown (g>0) or shrunk (g<0) per side
module nub_fp2d(g)
    rotate([0,0,-fin_angle]) stadium2d(head_len, head_w, g);

module spur_support_body() {
    prot = max(0, nub_hy() - spur_thick/2);   // nub past blade face?
    rail_h = prot > 0 ? prot + 0.4 : 0;       // skid rail height
    bed  = -(spur_thick/2 + rail_h);          // local bed plane (y)

    if (rail_h > 0)
        echo(str("SPUR SUPPORT: nub protrudes ", prot,
                 "mm past the blade face at fin_angle=", fin_angle,
                 " -> fused skid rails (h=", rail_h,
                 "mm) added under the blade. CUT OFF after printing."));

    // breakaway tower: nub footprint swept down to the bed, gap all
    // around the nub itself (snaps off; no scar on the bearing ledge)
    translate([0,0,knob_h])
        linear_extrude(neck_h + head_h)
            difference() {
                intersection() {
                    hull() {
                        nub_fp2d(-sup_inset);
                        translate([0,-30]) nub_fp2d(-sup_inset);
                    }
                    translate([-60, bed]) square([120, 60]);
                }
                nub_fp2d(sup_gap);
            }

    // fused sacrificial skid rails so the blade still lies flat
    if (rail_h > 0)
        for (sx = [-1, 1])
            translate([sx*(spur_base/2 - 2) - 0.6, bed, 0])
                cube([1.2, rail_h + 0.01, knob_h]);
}

// ================ WATERMARKS ================
module deboss_text(t, sz, dp, rot=0)
    linear_extrude(dp + 0.01)
        rotate([0,0,rot])
            text(t, size=sz, font="Liberation Sans:style=Bold",
                 halign="center", valign="center");

module wm_visible_cut() {
    if (body_style == "spur")
        rotate([0,0,fin_angle])
            translate([-(head_len/2 + spur_base/2)/2, 0, knob_h - wm_deep])
                deboss_text(wm_text, wm_size, wm_deep, 90);
    else
        translate([0, head_w/2 + 1.2 + wm_size/2, knob_h - wm_deep])
            deboss_text(wm_text, wm_size, wm_deep);
}

module wm_internal_cut(sock) {
    if (sock)
        echo("WATERMARK: internal void skipped (socket occupies the safe volume)");
    else if (body_style == "spur")
        rotate([0,0,fin_angle])
            translate([0, 0, knob_h - spur_web + 1.2])
                linear_extrude(wm_void_t)
                    text(wm_text, size=wm_size,
                         font="Liberation Sans:style=Bold",
                         halign="center", valign="center");
    else
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

    translate([0,0,-0.01]) linear_extrude(sock_plate + 0.02) {
        stadium2d(head_len, head_w, sock_clear);
        for (a = [0 : sweep_step : 90])
            rotate([0,0,a]) stadium2d(neck_len, neck_w, sock_clear);
    }
    translate([0,0,sock_plate])
        cylinder(d=cav_d, h=head_h + 0.2);
    if (roof_angle > 0)
        translate([0,0,cav_top])
            cylinder(d1=cav_d, d2=0.8, h=cone_h);
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
    p == "fdm04" ? kp_from_pitch(d, 2.0, 0.60, 30) :
    p == "fdm06" ? kp_from_pitch(d, 3.2, 0.80, 30) :
    p == "sla"   ? kp_from_pitch(d, 1.0, 0.35, 30) :
    p == "sls"   ? kp_from_pitch(d, 1.6, 0.50, 30) :
    p == "cnc"   ? kp_from_pitch(d, 1.0, 0.30, 30) :
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
