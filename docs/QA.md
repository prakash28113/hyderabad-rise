# QA — actual execution, 22 November 2026
Status: PARTIAL SPRINT 1. Android milestone NOT PASSED. Sprint 2 implementation deferred until gate.

Executed on Linux host, Godot 4.7.2.stable.official.ed1daf0bf:
- Official OSM map API extract succeeded. Overpass primary returned HTTP 406; alternate was not needed.
- Preprocessing produced 509 road ways, 925 building ways, total 1434 unique features, 76 registered tiles, one Charminar named way.
- Python unittest: 5 passed (origin, axis/scale, negative tiles, source node resolution, overlap identity/coverage).
- Godot headless 90-frame smoke: completed; no script errors observed.
- Godot validation script: passed scene load, three streaming transitions, <=9 loaded tiles, feature reference counts.
- Android debug export attempted and failed: missing matching android_debug.apk/android_release.apk export templates, unconfigured valid Java SDK path, missing Android SDK platform-tools/build-tools/apksigner/adb. No APK produced.
- GitHub read-only inspection returned no owned repositories for either connected account. No designated repo URL supplied. Local git branch only; no remote created or published.

Not executed: rendered visual QA, touch/device controller testing, independent geodetic comparison, landmark authenticity review, physical Android FPS/frame times/memory/thermal testing, release signing, APK install, driving, mission/save testing. Host headless FPS is not a device performance result. Blender/QGIS installed but no original landmark authored or visual GIS review performed.

Known limitations: flat terrain, placeholder heights/road widths, no authentic Charminar 3D silhouette, unbounded study edge, no vertical roads/bridge layers, relation buildings omitted, synchronous streaming, unoptimized per-segment draw calls/colliders, no LOD, no traffic/routing, no mission/wallet/save. Therefore neither recognizable landmark fidelity nor Android performance is accepted.

Raw validation logs are included in docs/evidence. The geographic workflow has no runtime network dependency. CI configuration is supplied but has not run on GitHub. No claim of zero hosting/build-service charges; tools require no purchase and no paid services were enabled.
