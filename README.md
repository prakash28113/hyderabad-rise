# Hyderabad: Rise of an Empire
Sprint 1 geographic foundation, 22 November 2026. This is an early geometry prototype, not an authenticated recreation or release-ready game.

## Run offline
Open `godot/project.godot` in Godot 4.7.2 and press F6/F5. WASD + right mouse; touchscreen left drag walks, right drag rotates camera. No network requests at runtime. Open `data/charminar.geojson` in QGIS as EPSG:4326 to inspect OSM IDs against source. Source XML and JSON are included.

```sh
python3 tools/import_xml.py
python3 tools/preprocess.py
python3 -m unittest discover -s tests -v
godot --headless --path godot --script res://scripts/validate.gd
```

Debug APK: `build/hyderabad-v0.1.6-debug.apk` (separately supplied). Android 7.0+ ARM64; target SDK 36. Device install/launch remains untested.

See docs/GEOGRAPHY.md, docs/QA.md, docs/LICENSE_REGISTER.md and docs/BACKLOG.md. Development branch: `dev/sprint1-geographic-foundation` is now delivered to the existing public repository `prakash28113/hyderabad-rise`. The exact source history through `b37d082` and original tag `sprint1-original-3659f13` were imported successfully. See [GitHub delivery receipt](docs/GITHUB_DELIVERY.md) for verification. No game changes were merged into main; no release or deployment was published.

## Verification follow-up v0.1.1
Local branch `dev/sprint1-verification-fixes` fixes mesh fronts/normals, adds boundary recovery, 30 FPS cap, scoped performance logs, a physical-device collection tool and rendered desktop screenshots. See `docs/VERIFICATION_FOLLOWUP.md`. Original commit preserved by ancestry and tag `sprint1-original-3659f13`. Physical Android verification and recognizable Hyderabad art remain incomplete.

## Sprint 1.5
Original reference-informed Charminar LODs, Old City modules/props, a static auto-rickshaw, trilingual place-name signs, road/building batching and matched graphical evidence are included. See [Sprint 1.5 report](docs/SPRINT15_REPORT.md) for accuracy, licensing, actual desktop measurements and physical Android blockers. Full visual authenticity and the sustained Android 30 FPS milestone have not passed.

## Current continuation
See [current QA and delivery report](docs/CONTINUATION_REPORT.md). The source now prevents movement/camera input while Licenses is open and adds offline asset-integrity checks. The newly built **v0.1.6 APK includes these changes**; it has a new debug signer, so an older installed prototype may need uninstalling first (clears app data). Run `python3 tools/validate_bundle.py` and `python3 tools/validate_host.py` after the geographic tests. Host validation imports resources first and writes new logs under ignored `build/host-validation`, preserving historical evidence.
