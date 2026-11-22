# Hyderabad: Rise of an Empire — continuation QA

23 November 2026, India. **Sprint 1 is not accepted.** This is a geographically anchored, offline Godot prototype. Android performance, physical controls and full streetscape authenticity remain unverified. No new district or Sprint 2 gameplay was added before that gate.

## Recovered foundation

Restored the source and complete bundled Git history at `f43e01f689809ecdb8ac4aa3b26f94b571a2bcd8`, on `dev/sprint1-geographic-foundation`. Commits `3659f13` and `8526c48` remain ancestors; tag `sprint1-original-3659f13` is preserved. No history rewrite.

The map contains 509 OSM road ways and 925 building footprints in 76 registered 256 m tiles. Raw OSM XML/JSON, geographic preprocessing scripts, derived GeoJSON, study boundary, WGS84 local transformation, original Blender authoring scene and GLBs, license records and Godot Android configuration are present. Existing landmark LODs, shops, static auto-rickshaw and multilingual signs are prototypes; they do not establish surveyed architectural accuracy. See GEOGRAPHY.md and SPRINT15_REPORT.md for source confidence and reference limitations.

## Changes in this continuation

- Opening Licenses now disables walking and camera input and clears touch ownership, stick and horizontal velocity. Closing it requires a fresh gesture. Synthetic regression covers blocked drag, cleared velocity and resumed touch acquisition. Decorative HUD labels no longer intercept GUI input.
- New offline `tools/validate_bundle.py` checks the raw source hash, exact registry/tile inventory, all registered asset hashes, art/font coverage and packaged attribution. Missing license URLs in five existing records were filled; asset bytes were unchanged.
- Geographic CI now runs this integrity check with read-only repository permissions. The changed workflow has not run on GitHub.
- Host regression runner imports resources on fresh checkouts, detects engine/script errors and writes logs to a chosen directory instead of overwriting historical evidence.
- Corrected stale geography, recovery, repository and backlog documentation. Historical reports remain historical records.

## Executed checks

Host: Linux, Godot `4.7.2.stable.official.ed1daf0bf`. Evidence is in `docs/evidence/continuation-20261122/`.

| Check | Actual result |
|---|---|
| Geographic unit tests | 5 passed |
| Re-run preprocessing | 1,434 features / 76 tiles; generated map/GeoJSON unchanged against Git |
| Bundle integrity | 76 tiles, source SHA-256, 30 asset SHA-256 records, runtime art/font coverage and notices passed |
| Godot resource import | Completed without detected engine/script errors |
| Mesh regression | All 925 mapped building footprints passed normals/winding checks |
| Scene regression | Three streaming transitions, nine-tile bound, reference counts, boundary/fall recovery, touch ownership/focus reset, camera limit and modal input checks passed |
| Landmark regression | Source anchor/yaw, configured height, descending LOD triangles, building surface bound, 720 road endpoints, gateway/pier collision and prop LOD checks passed headlessly |
| Android export | Attempted and failed: matching Android templates and Android SDK tools absent; Java export path unconfigured |
| Physical Android | Not executed; no ADB/toolchain/device access available |
| GitHub Actions | Not executed; no remote branch uploaded |

Scene-test synchronous streaming samples: startup 130.126 ms; transitions 13.864 / 67.390 / 50.123 ms. Scene setup 328.903 ms excludes engine/activity startup. These are single-run headless host samples, **not Android FPS, GPU times, PSS or a performance acceptance**. Two transitions exceed 33.33 ms; frame-budgeted streaming remains a priority. No new graphical performance claim is made.

## APK identity and limitation

The recovered `Hyderabad-Rise-v0.1.5-debug.apk` is 33,989,536 bytes, SHA-256 `bdb74c6fcac86e30b787fa17b3b46119f7b3de43a4f681d2e321f90f0e1ce6fd`. Its bytes match the prior delivery. It corresponds to the recovered baseline, **not the new modal-input fix or continuation source**. Prior signature/permission checks are historical; signature verification was not rerun here because Android tools are absent. No phone install was performed. Do not label this APK as newly built.

## GitHub delivery status

Existing destination: https://github.com/prakash28113/hyderabad-rise . Connected metadata reports public visibility and Munna-account push permission. `git ls-remote` returned no refs. No duplicate repository was created.

An ordinary push of `dev/sprint1-geographic-foundation` and `sprint1-original-3659f13` was attempted. Automatic approval review rejected it because this would publish source/assets to a public repository while the current task requires approval before publication. The action was not retried through another route. A subsequent remote-ref check still returned no refs. Local commits and a full-history Git bundle are supplied for review. No merge, release, deployment or paid service was used.

Approval needed: upload the development branch and original tag to this existing public destination. Before any approved push, recheck remote refs and use a normal non-force push; stop if unexpected remote work conflicts.

## Remaining milestone work

1. Approved GitHub branch delivery; no merge or release.
2. Install matching Android templates/SDK and rebuild current source; verify package, signature, offline permissions and packaged map/notices.
3. Physical Android cold/warm launch, offline walking, multitouch/camera/collision, tile traversal, background/resume, 15-minute route, presented-frame timings, PSS and thermal measurements. Compare representative baseline/midrange hardware and Pixel 9a when available.
4. Profile and distribute synchronous tile mesh/collider work across frames; measure residency/unload memory and visual seams on hardware.
5. Validate market density, landmark details, junctions and multilingual signage with legally usable references and native-language review.
6. Only after acceptance: controllable auto-rickshaw, traffic/pedestrians, geographically anchored delivery, wallet/reward and versioned atomic local save.
