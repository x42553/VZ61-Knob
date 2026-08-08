/*  Parametric Vz.61 Charging Knob — v15
    body_style: "knurl" | "fin" | "spur"
      knurl: round knurled knob          (face-down print)
      fin:   blade in the face plane     (face-down print)
      spur:  blade standing OFF the receiver — hollow window, jimped +
             curved trailing edge (print lying on blade side; small
             support tower under the nub only)
    fit_check=true: plain cylinder coupon body
    socket=true: bayonet keyhole to stow/use the OG knob — twist 90° CCW,
      lock with radial M3 grub screw. KNURL/FIN ONLY.
      Conical self-supporting cavity roof (roof_angle); no internal bridge.
      screw_mode: process-aware grub hole — "selftap" (FDM/SLS),
      "tap" (SLA/CNC: M3x0.5 tap drill; spec "M3 THRU" on the drawing,
      threads are NOT modeled by convention), "clearance", "none".
    knurl_preset: process-optimized knurl texture, pitch-based:
      "fdm04" | "fdm06" | "sla" | "sls" | "cnc" | "custom"
      (cnc = visual match of DIN 82 RGE 1.0 — renders/mockups only.
       NOTE: the socket cavity is an undercut and cannot be milled from
       the face; for CNC the part must be split body + keyhole plate.)
    Two-tier obround nub (dims = OVERALL), debossed fit_clear label,
    45° head underside chamfer (head_uch) — DEFAULT 0: the flat ledge
    is the validated bearing surface; chamfer caused axial wobble.
    Print: 100% infill, 5+ walls, layer 0.2mm max, CF-nylon for fin/spur.
    NO support inside the socket cavity (unremovable past the plate).
*/

// ---- Mode ----
fit_check   = false;
body_style  = "spur";   // "knurl" | "fin" | "spur"
socket      = false;     // OG-knob bayonet socket (knurl/fin only)

// ---- Socket ----
sock_clear  = 0.15;   // per-side vs steel OG nub; coupon-test 0.15/0.25
sock_plate  = 1.45;   // retention plate; MAX = OG neck height 1.5
sweep_step  = 5;      // degrees per slice of the 90° neck sweep cut
roof_angle  = 40;     // cavity roof cone angle (deg); >=~35 support-free;
                      // 0 = flat roof (bridge; ok for SLA)

// ---- Grub screw hole ----
screw_mode  = "selftap";  // "selftap" | "tap" | "clearance" | "none"
// selftap:   O2.6 — M3 self-taps into FDM/SLS plastic
// tap:       O2.5 — M3x0.5 tap drill; hand-tap (SLA/CNC). CNC: spec
//            "M3 THRU" on the drawing; do NOT model the thread.
// clearance: O3.4 — M3 passes through (split-plate variants)
// For rendered/SLA-printed threads, use BOSL2 instead of the cylinder:
//   include <BOSL2/std.scad>  include <BOSL2/threading.scad>
//   threaded_rod(d=3, pitch=0.5, l=..., internal=true, orient=BACK);

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
fin_len     = 22;    // boss center -> tip center
fin_sweep   = 6;     // tip drop sideways
fin_tip_r   = 4;
fin_scoop_r = 18;    // concave hook cut
fin_scoop_x = 12;
fin_scoop_y = 16;
fin_angle   = 90;    // rotation about nub axis (fin AND spur)

// ---- Spur (blade standing off the receiver) ----
spur_out    = 16;    // projection beyond the old face plane
spur_thick  = 8;     // blade thickness
spur_base   = 18;    // base width along X (>= head_len)
spur_rake   = 6;     // tip sweep in X
spur_tip_r  = 3.5;
spur_scoop_r   = 14; // finger-hook cut on leading edge
spur_scoop_off = 11; // scoop center dist from blade edge; smaller = deeper
spur_round  = 1.2;   // profile corner rounding

// ---- Spur skeleton window ----
spur_hollow = true;
spur_wall   = 3.5;   // rim thickness all around the window
spur_web    = 5;     // solid band kept under the nub (base side)

// ---- Spur jimping (trailing edge serrations) ----
jimp_on     = true;
jimp_r      = 1.0;   // notch radius (depth = r, width = 2r)
jimp_pitch  = 3.0;   // center-to-center spacing
jimp_margin = 3;     // keep-clear from base corner and tip

// ---- Spur trailing-edge curve ----
trail_curve = 2.5;   // inward bow depth (sagitta); 0 = straight

// ---- Nub: two-tier obround (all dims = OVERALL, tip-to-tip) ----
// Also defines the socket negative — these ARE the OG measurements.
neck_len   = 9;      neck_w = 3.0;  neck_h = 1.5;
head_len   = 10;     head_w = 4.0;  head_h = 3.5;
head_ch    = 0.5;
head_uch   = 0;      // 45deg underside chamfer. 0 = flat ledge (VALIDATED:
                     // full bearing, no wobble; ledge prints support-free).
                     // 0.3 max if eased slot entry is ever needed.

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
        translate([0, -(head_w/2 + 1.2 + label_size/2), knob_h - label_deep])
            linear_extrude(label_deep + 0.01)
                text(str(fc), size=label_size,
                     font="Liberation Sans:style=Bold",
                     halign="center", valign="center");
    }
}

// ================ SOCKET ================
module stadium2d(len, w, c)
    hull() for (x = [-1,1])
        translate([x*(len - w)/2, 0]) circle(r=w/2 + c);

module socket_cut() {
    cav_d   = head_len + 2*sock_clear + 0.4;   // cavity diameter
    cav_top = sock_plate + head_h + 0.2;       // cylindrical cavity ceiling
    // cone height for roof_angle, clamped to stay under the nub root
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
    // rotation cavity: head turns here, snug axially at the rim
    translate([0,0,sock_plate])
        cylinder(d=cav_d, h=head_h + 0.2);
    // self-supporting conical roof (dead air above the head; the head
    // bears on the PLATE, so extra apex depth is harmless)
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

function spur_P()  = [spur_base/2, 0];                      // base corner
function spur_Ct() = [spur_rake, -spur_out + spur_tip_r];   // tip circle center
function spur_tdir() =
    let(dv = unit(spur_Ct() - spur_P()),
        a  = asin(spur_tip_r / norm(spur_Ct() - spur_P())))
    [dv.x*cos(a) - dv.y*sin(a), dv.x*sin(a) + dv.y*cos(a)];
function spur_T() = spur_P() + spur_tdir()
    * sqrt(pow(norm(spur_Ct()-spur_P()), 2) - spur_tip_r*spur_tip_r);

// arc through P and T with sagitta trail_curve
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
// preset -> [tooth count, depth, helix angle], from process-limited pitch
function kp_from_pitch(d, pitch, depth, ha) =
    [max(8, round(PI*d/pitch)), depth, ha];

function knurl_params(p, d) =
    p == "fdm04" ? kp_from_pitch(d, 2.0, 0.60, 30) :  // 0.4 nozzle floor
    p == "fdm06" ? kp_from_pitch(d, 3.2, 0.80, 30) :  // coarse, deep
    p == "sla"   ? kp_from_pitch(d, 1.0, 0.35, 30) :  // fine; brittle-safe depth
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
