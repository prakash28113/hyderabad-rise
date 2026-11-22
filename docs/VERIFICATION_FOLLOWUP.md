# Sprint 1 verification fixes — v0.1.1

Date: 22 November 2026. Sprint 1 remains **INCOMPLETE**. No physical Android device is connected. The private GitHub repository exists at https://github.com/prakash28113/hyderabad-rise but remains empty because the authenticated SSH transport failed; HTTPS CLI is signed out and connector access returns 404. These changes are on a separate local branch, `dev/sprint1-verification-fixes`. The original `dev/sprint1-geographic-foundation` branch remains at full commit `3659f13ee634c64b1c475ed371f0ce21bec7ed3b`.

## Fixed and verified on host

- **Incorrect roof and wall fronts/normals:** baseline diagnostic showed a roof normal with Y approximately -0.667 and smoothed wall normals; 25 source footprint loops also had the opposite winding to the other 900. New mesh generation normalizes a private traversal copy and explicitly supplies upward roof and outward wall normals. All **925 actual OSM building footprints** now pass front-face/normal agreement and roof/wall checks with zero skipped footprints. Both winding fixtures pass. Source coordinates, OSM IDs and raw data are unchanged.
- **Leaving the playable study / falling forever:** player position is checked against the local AABB enclosing the documented study rectangle; out-of-bounds or Y<-10 returns to spawn and clears velocity. Three recovery cases pass. This is recovery, not a physical wall, and the AABB is an engineering approximation rather than an administrative boundary.
- **Timing evidence:** `HYD_READY` reports scene setup time, `HYD_STREAM` reports synchronous streaming duration, and `HYD_PERF` reports five-second distributions of process callback intervals and engine allocation counters. The FPS display is capped at 30. These do not measure GPU presentation, Android total PSS, or time from Android activity launch to an interactive city. Background/resume resets frame samples.
- **Input regression:** synthetic two-finger ownership, movement release and focus reset checks pass. These are generated Godot input events, not physical touchscreen testing.
- **SDK alignment:** new APK exported using build-tools 36.0.0 / platform 36 and matching Godot 4.7.2 templates. No prior build-tools fallback warning in the final export log. APK has version code 2 / version 0.1.1, target SDK 36, minimum SDK 24 and ARM64 architecture. Signature verified with apksigner; no requested permissions.

## Rendered desktop session actually executed

Opened the source project in the graphical Godot 4.7.2 editor and ran it. Captured the actual game viewport using its Linux development F12 shortcut. Pressed W for 1.5 seconds and then 8 seconds; the scene visibly advanced toward the landmark placeholder and streaming feature count changed from 276 to 356, with 9 tiles displayed. This is a basic desktop walking/streaming smoke observation, not full collision or input acceptance. No physical phone session occurred.

- `docs/evidence/fixes/desktop-spawn.png`: initial Charminar-area view.
- `docs/evidence/fixes/desktop-approach.png`: approach to the placeholder building.
- The two screenshots show live engine FPS counters near 30 in isolated frames. They are not a sustained performance benchmark and must not be used as proof of Android FPS.
- Visual judgment: the real source road pattern is visible, but the scene is schematic tan building extrusions and flat terrain. Charminar's minarets/arches, surrounding facades, local signage and street activity are missing. **Hyderabad visual-authenticity acceptance fails.**

## Regression and build evidence

`python3 tools/validate_host.py` runs the mesh and scene tests with a 30-second timeout, rejects engine/script errors even when Godot returns zero, and requires explicit PASS markers. This harness was added after a typed-array test fixture error was caught and corrected; the successful logs are from the corrected final run. Python geographic tests: 5 pass. Original geographic data is unchanged.

`tools/collect_android.py` is a user-run ADB evidence collector. It refuses missing/unauthorized/multiple-unspecified devices and emulators; with a physical phone it installs the selected APK, captures launcher timing, samples raw meminfo and saves app-PID logcat. It does not delete application data or declare acceptance. Its no-device preflight was executed here and correctly returned BLOCKED; the successful-device collection path is not tested.

Example for a development PC, after connecting and authorizing a physical phone:

```sh
python3 tools/collect_android.py --apk Hyderabad-Rise-v0.1.1-debug.apk --serial YOUR_ADB_SERIAL --seconds 900 --out physical-run-01
```

Walk and rotate the camera manually during the run. Inspect `HYD_PERF` records in app-logcat, raw TOTAL PSS in memory snapshots, crash/ANR output and launch timing. Use Perfetto FrameTimeline for presented frame times, video/screen captures for time-to-interactive and actual phone screenshots for visual acceptance. Do not substitute engine memory counters for PSS.

## Still open before Sprint 2

Physical install/launch, two-thumb touch camera/walking, sustained FPS/frame times/PSS/loading/thermal measurements, physical screenshots, camera clipping, worst-case streaming stalls, independently validated reference accuracy, and recognizable landmark/street art. Streaming still creates meshes synchronously; no claim that Android frame budgets pass. No merge, release or publication occurred.
