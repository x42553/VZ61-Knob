# Vz.61 Extended Charging Knob — Parametric OpenSCAD

Drop-in replacement charging handle/knob for the Vz.61, 3D-printable, with four
body styles, a selectable perimeter texture, and an optional stowage socket for
the original factory knob.

**File:** `vz61_charging_knob.scad` (current: v20)

## Body styles (`body_style`)

| Style       | Description                                            | Print orientation |
|-------------|--------------------------------------------------------|-------------------|
| `"knurl"`   | Round textured knob, thumb dish                        | Face down, no supports |
| `"fin"`     | Swept blade in the face plane (parallel to receiver)   | Face down, no supports |
| `"spur"`    | Blade standing off the receiver; hollow window, jimped + curved trailing edge | Lying on blade side; breakaway support under the nub — integrated (`spur_support`) or slicer-generated |
| `"scallop"` | Round knob, raked: taller on one side (`scal_high`) than the other (`scal_low`), slanted face dished concave. High side aims at `fin_angle` | Nub-up, standing on integrated breakaway pedestal (`scal_support`); rake, dish and texture print as quality surfaces, nub needs no support |

## Perimeter texture (`texture`, applies to knurl + scallop bodies)

| Texture    | Description | Process notes |
|------------|-------------|---------------|
| `"knurl"`  | Helical diamond knurl, sized by `knurl_preset` (`fdm04`/`fdm06`/`sla`/`sls`/`cnc`/`custom`, pitch-based; effective values echoed at compile) | `cnc` preset is a visual stand-in for DIN 82 RGE 1.0 — renders/mockups only; real knurls are spec'd on the drawing |
| `"vserr"`  | Vertical serrations (coin-edge grooves parallel to the nub axis), `serr_pitch`/`serr_depth` | Crispest FDM texture of the set — grooves print as vertical walls; recommended for 0.6 mm nozzles |
| `"hserr"`  | Horizontal serrations (circumferential ring grooves), auto-centered between rim chamfers | Slightly softened groove tops on FDM (small overhangs); ideal on SLA/SLS, and the one texture that is genuinely CNC-honest (straight plunge grooves) |
| `"smooth"` | Plain cylinder | — |

Scallop takes the texture when `scal_textured = true`.

## Mounting nub (measured from original handle)

Two-tier obround, all dims **overall tip-to-tip**:

- Neck (sits in bolt slot): 9 × 3.0 mm, 1.5 mm tall
- Head (retains behind slot): 10 × 4.0 mm, 3.5 mm tall, 0.5 mm chamfer top;
  `head_uch = 0` (flat underside ledge — **validated**: the 45° underside
  chamfer variant caused axial wobble and was reverted)

`fit_clear` is subtracted from the nub half-widths. Negative values = tighter.
**Validated: `fit_clear = 0.0`** (0.1 wobbled more on test coupons).
The nub stack is identical across all body styles and textures — a validated
clearance carries over without re-couponing.

## Workflow

1. `fit_check = true` — prints a plain-cylinder coupon with the full nub.
   Uncomment the batch line in MAIN to print several clearances at once;
   each coupon is self-labeled (debossed `fit_clear` value).
2. Test in the bolt: slides in without force, head hooks and seats flush,
   no wobble. Wobble diagnosis:
   - side-to-side/rotational → adjust `fit_clear`
   - in-and-out axial → check `neck_h` and `head_uch`, not `fit_clear`
3. `fit_check = false`, set the winning `fit_clear`, F6, export STL.

Name exported STLs by configuration (e.g. `vz61_scallop_vserr_fc0.stl`) —
the debossed label only records `fit_clear`.

## Socket variant (`socket = true`, knurl/fin only)

Bayonet keyhole in the face stows the original knob: insert nub-first,
twist **90° CCW** (viewed from the face), lock with a radial M3 grub screw.
The 90°-swept neck bore gives the OG head full-footprint bearing on the
1.45 mm plate — usable as a pull-load grip extension, not just storage.
Cavity roof is a self-supporting cone (`roof_angle`, 0 = flat for SLA).
Not available on spur (no face) or scallop (face is raked, keyhole needs flat).

- `sock_clear` is a separate fit variable vs. the steel OG nub — coupon it
  (thin disc + `socket_cut()`), start at 0.15.
- **Never let the slicer put support inside the socket cavity** — it cannot
  be removed past the plate.
- `knob_d = 18` recommended with socket (wall + screw thread budget).
- Grub hole is process-aware (`screw_mode`): `"selftap"` Ø2.6 (FDM/SLS),
  `"tap"` Ø2.5 (SLA/CNC — spec "M3 THRU" on the drawing; threads are not
  modeled by convention), `"clearance"` Ø3.4, `"none"`.
- **CNC note:** the cavity is a re-entrant undercut and cannot be milled
  from the face; machining requires a split body + keyhole plate (not
  implemented).

## Integrated print supports

**Spur** (`spur_support = true`): breakaway tower under the nub for the
side-lying FDM print. Tower matches the nub head's rotated footprint
(shrunk by `sup_inset`), separated by `sup_gap` (~1 layer) — snaps off by
hand and leaves the head's bearing ledge unmarked (no support teeth touch
it, by design). At the default `fin_angle = 90` the nub lies within the
blade thickness and the tower alone suffices; near `fin_angle = 0/180`
fused sacrificial skid rails are added automatically (console echo warns —
cut off after printing).

**Scallop** (`scal_support = true`): breakaway pedestal conforming to the
raked face; the part prints nub-up standing on it. Expect minor sag in the
dish center (unsupported shallow dome) — cosmetic.

**FDM only.** SLS needs no supports at all (the powder bed is the
support). SLA should use the slicer's own angled supports — flat
integrated supports fight resin peel-force orientation.

## Print settings

- 100% infill, 5+ walls, layer ≤ 0.2 mm
- Material: PETG acceptable for knurl/scallop; **CF-nylon or resin for
  fin/spur** (long moment arm on the 3 mm neck) and for the socket variant
- Elephant-foot compensation on; verify printed neck height with calipers
  (first-layer squish affects head clamping)

## Key parameters

- Spur sculpting: `spur_out`, `spur_rake`, scoop (`spur_scoop_r/off`),
  `spur_hollow`/`spur_wall`/`spur_web`, `jimp_*`, `trail_curve` (jimping
  follows the arc automatically)
- Scallop sculpting: `scal_low`/`scal_high` (rake), `scal_dish_r`/
  `scal_dish_d` (concave cup — deliberately independent of the knurl
  body's `dish_*`)
- `fin_angle` orients fin, spur, and the scallop's high side about the
  nub axis (default 90°). The spur blade sits at `fin_angle + 90` in
  world terms (see v18); spur-attached features track it via
  `blade_frame()`
- Keep `spur_wall − jimp_r ≥ 2` mm; after profile changes eyeball the
  preview for a pinched waist between scoop and trailing curve
- Watermarks: `wm_visible` (deboss, bolt-side face), `wm_internal`
  (buried void — see Provenance below); set `wm_text` to your mark

## Version history

| Ver | Changes |
|-----|---------|
| v1  | Initial concept: knurled knob, cylindrical pin nub. Knurl was fake (straight tangent cuts), dish math wrong, pin nub structurally doomed — all identified and rebuilt |
| v2  | True helical diamond knurl (twisted extrude intersection), exact-depth dish, rim chamfers, filleted nub + optional steel core |
| v3  | Real nub geometry from caliper measurements: two-tier obround (neck + chamfered head). Steel core dropped (no room), root fillet dropped (seats in slot) |
| v4  | Debossed `fit_clear` label; model wrapped in `knob(fc)` module for batch plates |
| v5  | `fit_check` coupon mode; nub reparameterized as overall length × width after "mid vs overall" measurement ambiguity produced a 4 mm-too-long print; neck corrected to 3 mm wide |
| v6  | `head_uch` 45° underside chamfer on head (support-free print). *Later found to cause axial wobble — see v15* |
| v7  | Fin body style (blade in face plane); `body_style` switch; `fin_angle` |
| v8  | Bayonet stowage socket: keyhole plate, rotation cavity, radial M3 grub screw |
| v9  | Socket upgraded to load-bearing grip extension: true 90°-swept neck bore (full-footprint head bearing), snug cavity, `knob_d` 18 |
| v10 | Spur body style (blade standing off the receiver); socket/dish auto-guards per body style |
| v11 | *(patch only, never a standalone file)* Hollow skeleton window (`spur_hollow`/`spur_wall`/`spur_web`) and trailing-edge jimping — merged directly into v12 |
| v12 | Trailing-edge inward curve (`trail_curve`); jimping follows the arc; window offsets from curved outline |
| v13 | Process-optimized knurl presets (`knurl_preset`), pitch-based with echo of effective values |
| v14 | Socket cavity roof: self-supporting cone (`roof_angle`) replaces flat internal bridge; auto-clamped under nub root with assert. CNC undercut limitation documented |
| v15 | `screw_mode` (selftap/tap/clearance/none) replaces fixed grub pilot; **`head_uch` default reverted to 0** after fit coupon showed the chamfer converted the head's entire bearing ledge to cone → axial wobble |
| v16 | Watermarks: visible deboss + internal void (auto-skipped with socket); fixed spur fit label landing outside the blade thickness (was silently absent on all prior spur prints) |
| v17 | `spur_support`: integrated breakaway tower for the spur's side-lying FDM print, with auto skid rails when the nub protrudes past the blade face. Documented that SLS needs no supports and SLA should use native angled supports |
| v18 | Spur blade orientation corrected to `rotate([90,0,90])` (field-verified facing); all spur auxiliaries re-derived in the new blade frame via `blade_frame()`. Side effect: at default `fin_angle = 90` the nub no longer protrudes past the blade face — plain tower suffices, no skid rails |
| v19 | Scallop body style: raked round knob (`scal_low`/`scal_high`) with concave dished face, high side aimed by `fin_angle`; integrated breakaway pedestal (`scal_support`) for the nub-up print. Socket disabled for scallop (keyhole needs a flat face) |
| v20 | Perimeter texture selector (`texture`: knurl/vserr/hserr/smooth) decoupled from body style — applies to round knob and scallop (`scal_textured`). Vertical serrations recommended for FDM/0.6 mm nozzles; horizontal serrations best on SLA/SLS/CNC |

## License & attribution

**License:** [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
**Author:** Simon Fischer - first published 2026-07-20
**Canonical source:** https://github.com/x42553/VZ61-Knob/

You are free to print, modify, share, and sell prints of this design,
provided you credit the author with a link to the canonical source and
license any derivative under CC BY-SA 4.0. The ShareAlike term means
**no one can relicense this design or its derivatives under more
restrictive terms** — any copyright claim made against people freely
printing or sharing this design under these terms is invalid on its face.

### Provenance

This design was developed iteratively from caliper measurements of an
original Vz.61 charging handle; the development history above is preserved
in the canonical repository's commit log. Re-uploads elsewhere have no such
history. Printed parts additionally contain an internal void watermark
(visible in slicer layer preview) identifying the origin.

If you find this design re-uploaded under someone else's name or with a
claim of ownership: it isn't theirs. Link them here.

## Safety / legal

Printed replacement parts on a firearm are use-at-your-own-risk: inspect
before each session, expect wear, and check local regulations regarding
modifications. The nub neck is the structural weak point by design analysis —
if a failure occurs it will be there.
