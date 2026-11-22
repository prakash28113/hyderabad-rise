# Hyderabad: Rise of an Empire — Sprint 1.5 verification

22 November 2026 (India). **Sprint 1 remains BLOCKED. No physical Android acceptance or full visual-authenticity acceptance.** This is an offline geographic/art prototype, not a metropolitan recreation or a release.

## Delivery and Git history

Work continued from `8526c48`. Local `dev/sprint1-geographic-foundation` was fast-forwarded from `3659f13` to its descendant `8526c48` before this work. The original commit is preserved by ancestry and local tag `sprint1-original-3659f13`; `dev/sprint1-verification-fixes` remains at `8526c48`. The source delivery includes a Git bundle preserving history and refs.

The approved private repository `prakash28113/hyderabad-rise` exists and its signed-in web page was inspected as empty. No duplicate was created, no unrelated content was overwritten, no branch was merged and no release was published. Push is blocked: connected GitHub get-repository returned 404, installation listing returned no installations, gh CLI has no authenticated session, and a noninteractive HTTPS remote check failed with exit 128 because no username/credential was available. A browser sign-in does not supply Git terminal credentials. `evidence/sprint15/git-https-check.txt` records the terminal failure. Previous temporary deploy key was removed; no persistent key was added in this sprint. There is **no verified remote development branch URL**. Do not treat the repository landing page as delivered source. Resolve access using a GitHub connection with access to this private repository or authenticated HTTPS Git, then perform an ordinary non-force push of the development branch and original tag. Recheck remote heads first.

## Implemented project changes

- Original Blender authoring scene and reproducible Python generator; no downloaded mesh or photo-projected texture. Charminar has four open pointed portals, tapered corner minarets, tiered balconies, gallery arches, parapets, clocks and domes/finials. Its position and rotation derive from the original OSM footprint.
- Charminar LOD0/1/2: 38,560 / 22,672 / 10,448 triangles, one atlas material each. LOD thresholds 55 and 150 m use the active camera distance. Geometry is an architectural study with estimated decorative proportions, not a measured conservation model.
- Old City shop modules with balconies, shutters and awnings: 434/218 triangles, two distance ranges. Market stall 206, streetlamp 88, electrical pole 216, neem-style tree 240 and original static auto-rickshaw 458 triangles. One original 512×512 palette/noise atlas is used by instanced props. GLB exports include identical atlas copies for portable authoring; runtime props share the cached material.
- Nearby shop details align to selected existing footprint edges near existing roads; original footprint polygons are retained. Place-of-worship footprints are excluded from shop decoration. Limits: 80 shops, 18 stalls, 18 lamps, 10 poles, 9 trees and 3 autos. These are caps, not claims that every prop appears in every tile.
- Three-language Charminar place-name signs use Noto fonts with Urdu right-to-left rendering. Telugu `చార్మినార్` is source-matched to OSM; English `Charminar` and Urdu `چار مینار` to Wikidata Q1771696. Sign text is source-verified, not native-speaker proofread. These are illustrative wayfinding signs, not copied commercial signs. An observed fascia-clipping issue was corrected before the final capture.
- Loaded road rendering is combined into two MultiMeshes; visible building surfaces are combined into at most six material surfaces. Source IDs, individual metadata and collision shapes remain available. Nine-tile residency/refcounts remain bounded. Realtime shadows are disabled by default after an expensive desktop experiment. Camera sphere probe and pitch limits reduce ground clipping while looking up at the minarets.
- Auto-rickshaw is a parked visual/collision prototype. Driving, traffic, pedestrians and delivery gameplay are not implemented in Sprint 1.5.

## Geographic accuracy and reference confidence

Original source remains 509 OSM road ways and 925 building footprints, 76 registry tiles. The raw converted JSON SHA-256 remains `710252a9b396c0229cfbb757a4edac7e839dd0e94099c7cdadc8ba2f18abdfd9`. Existing study boundary and WGS84-to-local east/up/south transform are documented in `GEOGRAPHY.md`; no city substitution or landmark relocation was performed.

Charminar source way **238186115**: polygon centroid local X −6.265406 m, Z −0.257255 m; source long-edge orientation 11.088704° clockwise from east (Godot yaw is negative). Model body side 20 m and total-height parameter 48.7 m follow the Hyderabad District reference below. Incredible India lists a conflicting 56 m height; no surveyed drawing was obtained. The chosen parameter is a documented reference choice, not an invented field measurement. Individual tower radii, portal curves, gallery heights and decorative details are artist estimates.

Independent PROJ topocentric conversion at four points agrees within 7.67×10⁻¹¹ m mathematically. That validates the conversion implementation, not OSM positional accuracy. The Commons photograph's object-location metadata differs from the OSM centroid by 1.773 m; it is volunteered metadata, not a surveyed control point, and does not establish an absolute error bound. Camera position and object position are not interchangeable. Field accuracy is **not measured**.

The graphical regression checked 720 currently loaded road-segment endpoints against the converted source with total endpoint error below 0.002 m per segment. This validates rendered alignment to this dataset, not independent real-world road accuracy or citywide completeness. Source connectivity tests pass. See `evidence/sprint15/geographic-overlay.png` and `geographic-audit.json`; the overlay includes original roads/footprints, model outline and QA camera positions.

Road widths use source numeric width where available, otherwise explicit defaults (primary 10 m, secondary 8, tertiary 7, residential 6, pedestrian 8, footway/path/steps 3/2/2, service 4). One-metre illustrative sidewalks are added away from the landmark core. Most building heights remain 7 m placeholders. Road widths, sidewalk profiles, shop typologies, vegetation and furniture positions are **not surveyed**. The source has no mapped lamp/tree points in this extract. Footprint gaps and low building-height assumptions leave the scene visibly sparse; they are not silently filled with fictional urban blocks.

## Visual acceptance evidence

Actual Godot graphical rendering on Linux/X11, 1280×720, Compatibility/OpenGL, Mesa llvmpipe software rendering. These are **desktop screenshots, not Android screenshots**. The before project is a detached `8526c48` worktree with only the QA capture harness added; original game source remains unchanged. Both builds use the same four source-road-snapped camera positions, 1.7 m eye height, 60° FOV and fixed landmark look-at. `godot/data/qa-views.json` records exact positions and OSM road/node IDs. Views are south (Charminar Road), north (unnamed source way), east (Bhagya laxmi mandir road), west (Purana Pul Road). These named capture directions are local approach labels, not a claim of surveyed photography poses.

- `before-after-four-views.jpg`: all four matched before/after views, source PNGs retained.
- `before-after-south.jpg`: larger south comparison.
- `reference-comparison.jpg`: licensed Kdas1977 aerial / Zahid street photograph beside actual rendered views. Perspectives are different; this is qualitative feature comparison, not a pixel or photogrammetric accuracy score.
- `after_signage.png`, `after_auto.png`: actual prop/detail views; no generated promotional imagery.

| Criterion | Evidence and judgement | Status |
|---|---|---|
| Landmark silhouette/proportions | Four minarets, pointed portals, balconies, gallery, domes and clocks now visible versus the old footprint extrusion. Reference photos show much richer carved stucco and complex mosque/parapets. Decorative dimensions unmeasured; western mosque/interior simplified. | Partial; survey/fidelity gate open |
| Road alignment/junctions | Source geometry and connections retained; renderer endpoint regression and geographic overlay pass relative to OSM. Widths/pavements not independently validated. | Source alignment passed; field gate open |
| Architecture/density | Local-style balcony/shutter/awning modules added, but many generic-height blocks and footprint gaps remain; cannot reproduce photographed continuous market frontage yet. | Not accepted |
| Signs/furniture | Source-matched proper-name signs and original market/utility props rendered; no survey of real sign or pole locations; native proofread outstanding. | Prototype only |
| Overall Hyderabad recognition | Charminar form improves recognition; whole streetscape does not yet establish an authentic reconstruction. No user/field visual acceptance obtained. | Not accepted |
| Android performance impact | More geometry; fewer draw calls through batching; desktop spikes remain. No physical-device rendering evidence. | Blocked |

## Android verification

Signed debug APK v0.1.5, version code 3; package `in.hyderabad.rise.prototype`; min SDK 24 (Android 7), target 36, ARM64. Export used matching Godot 4.7.2 Android template and Android build-tools 36. Signature verification passed v2/v3 with one debug signer; not a release signing identity. APK archive checks verify all 76 tile JSONs, anchor/signage, credits/font notice and ARM64 engine library. Permission dump contains no INTERNET permission. Offline-first packaging is checked; offline play on a phone is not tested.

APK SHA-256: `bdb74c6fcac86e30b787fa17b3b46119f7b3de43a4f681d2e321f90f0e1ce6fd`.

Physical-device preflight: ADB reported no connected authorized devices. Collector exited **BLOCKED** before install. The user's chat phone is not automatically exposed to this execution environment. No physical device model/Android version can be recorded as tested. No phone screenshots were captured.

| Required physical check | Actual result |
|---|---|
| Install/launch/cold startup | Not executed; no physical ADB device |
| Walking / multitouch / camera / collision | Not executed on phone; synthetic and desktop regression evidence only |
| Traversing tile boundaries / long-session recovery | Not executed on phone |
| Presented FPS / p50,p95,p99 frame times | Not measured on phone |
| RAM/PSS / GPU allocation / thermal behavior | Not measured on phone |
| Activity launch and tile loading times | Not measured on phone |
| Android screenshots and visual acceptance | Not available |

`tools/collect_android.py` refuses emulators, installs on one explicitly selected authorized device, captures model/Android version, launch timing, PSS samples and process logcat. Run it on a workstation connected to the phone, using this APK. It does not automatically declare acceptance. Supplement its logs with actual touch exercises, gameplay screenshots, cold/warm launch repetitions, streamed traversal and a presented-frame/GPU-capable profiler where available. Collectors that only measure engine callbacks must not be relabeled as presented-frame timing.

## Executed regression checks

Five Python geographic tests passed. All 925 building footprints passed front-face/normal checks. Godot scene regression passed three streaming transitions, nine-tile bound, reference counts, boundary/fall recovery, zeroed velocity and synthetic multi-finger ownership/release/focus behavior. High-pitch camera safety assertion passes. New authenticity regression passed source anchor/yaw, configured height, decreasing LOD complexity, batched surface limits, source-road endpoints and central-passage/pier collision rays. The graphical test repeated road endpoints using renderer transform readback rather than DummyRenderer's unavailable transform readback. All three host regression processes completed without engine/script errors. Logs are in `evidence/sprint15/*regression.log`. These checks do not replace physical testing or a manual playthrough.

## Performance observations

| Build / view | Callback Hz | p50 / p95 / p99 / max ms | Draw calls | Primitives | Engine static MiB (not PSS) |
|---|---:|---|---:|---:|---:|
| before / south | 29.86 | 33.33 / 34.69 / 54.78 / 73.21 | 225 | 3477 | 83.77 |
| before / north | 30.00 | 33.33 / 33.56 / 34.76 / 39.04 | 354 | 5132 | 83.87 |
| before / east | 30.00 | 33.33 / 33.60 / 34.75 / 37.01 | 204 | 3262 | 83.89 |
| before / west | 30.00 | 33.33 / 33.56 / 36.41 / 39.00 | 420 | 5886 | 83.98 |
| after / south | 29.35 | 33.32 / 41.31 / 50.51 / 58.10 | 45 | 52782 | 87.83 |
| after / north | 28.80 | 33.25 / 44.19 / 59.22 / 115.31 | 21 | 52646 | 87.83 |
| after / east | 29.70 | 33.32 / 38.38 / 52.91 / 73.50 | 33 | 52606 | 87.83 |
| after / west | 29.42 | 33.20 / 39.57 / 54.26 / 62.05 | 33 | 52822 | 87.83 |

Each final static QA view warms for 60 process frames and samples 180 intervals. Metric is wall-clock interval between engine process callbacks; rate is callbacks/elapsed time, not Android presented FPS. One run per view is a diagnostic sample, not a statistical performance guarantee. Capture reads one final render draw/primitives counter and engine static allocation; the latter excludes total resident/PSS and is **not RAM usage**. The engine cap is 30 FPS. Renderer warns VSync mode cannot be changed. Desktop performance cannot predict representative ARM Android hardware.

Scene/stream timing samples from the final headless regression: scene setup 609.100 ms (excludes engine/activity startup), initial synchronous stream 189.575 ms, transitions 19.814 / 91.996 / 49.411 ms. These are host samples, not phone loading measurements; multiple exceed a 33.33 ms budget and show that synchronous tile work still needs further optimization. Inspect the retained logs instead of treating this as a seamless-streaming pass.

The early high-detail realtime-shadow experiment ran around 12–16 desktop callback Hz with 185–255 draw calls. The final default removes realtime shadows, uses LODs and batches roads/buildings. Previous runs and a capture overlapping APK export are retained under clearly named `experiment-*` directories. The before run and final after run were captured after the preceding build completed, with no build/test task launched concurrently. A final sign-placement-only adjustment was followed by a fresh after run and then a fresh APK export. Timing variation and software rendering remain limitations. **A sustained 30 FPS gate has not passed.**

## Licensing and reproducibility

See `LICENSE_REGISTER.md`, per-file `references/asset-license-register.json` (SHA-256, author, source, license, changes), `godot/data/ASSET_CREDITS.txt` and `FONT-LICENSE.txt`. Original code MIT; original reference-informed art, Blender scene, atlas and art screenshots CC BY-SA 4.0; OSM original/derived databases ODbL 1.0; unmodified Noto fonts SIL OFL 1.1; Wikidata labels CC0. Photo originals and attribution accompany source; photo pixels are not textures. Godot/third-party engine notices and ODbL notice remain available in the game Licenses UI. Do not remove source databases or notices when redistributing the APK.

References accessed 22 November 2026:
- Hyderabad District architectural description: https://hyderabad.telangana.gov.in/tourist-place/charminar/ (20 m square, 48.7 m minaret figure used).
- Telangana Tourism: https://tourism.telangana.gov.in/ (Charminar description corroborates 48.7 m; no survey supplied).
- Conflicting government tourism height: Incredible India Charminar page (56 m); recorded as conflict, not averaged.
- Kdas1977, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Charminar_of_Hyderabad_Telangana.jpg
- S K Zahid Basha, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Charminar_-_Hyderabad,_Telangana,_India.jpg
- Rashid Jorvee, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Charminar_Arc_complete_view_of_other_gate.jpg
- Wasiul Bahar, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Auto_rickshaw_at_Hyderabad.jpg
- Wikidata place labels: https://www.wikidata.org/wiki/Q1771696 ; OSM source files include original tags and feature IDs.

## Known issues and ordered backlog

1. **P0 delivery:** enable authenticated HTTPS/connected GitHub access to the existing private repository, inspect remote heads, push this development branch without force and original tag. No merge/release.
2. **P0 milestone:** physical ARM64 phone install, movement/multitouch/camera, collision traversal, boundary/fall recovery, 10-minute streamed route, background/resume, screenshots, cold/warm load timing, frame intervals/presented FPS, PSS and thermal samples. Until passed, Sprint 1 remains blocked.
3. **P1 performance:** profile physical-device hotspots; distribute synchronous tile build work across frames, prewarm shaders, check batch culling/LOD thresholds and memory across tile unload/reload. Static screenshots do not exercise these risks.
4. **P1 accuracy:** obtain legally usable measured drawings/control points; verify west-side mosque, minaret/gallery proportions, landmark orientation and nearby junctions; resolve published height conflict. Document confidence rather than invent measurements.
5. **P1 streetscape:** improve source footprint coverage and real building heights, documented façade references and dense market edges; retain source positions. Survey furniture/vegetation locations before calling them accurate. Recheck local temple treatment and landmark passages on foot.
6. **P1 language/visual QA:** Telugu/Urdu native proofreading; compare all four approaches against licensed ground-level references from comparable viewpoints; validate signs remain readable across LOD/camera settings and phone resolutions.
7. **P2 gameplay after foundation gate:** controllable auto, traffic/pedestrian prototypes, geographically anchored delivery, wallet/reward/local save. Current auto is static; no Sprint 2 completion claimed.
