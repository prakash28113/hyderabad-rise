# Hyderabad Rise v0.1.7 — mobile camera and HUD follow-up

This build responds to the supplied 26-second gameplay recording. The recording showed a working earlier prototype, but also avatar obstruction when looking up, hard-to-discover touch controls, a large persistent credits panel and side borders. It was not evidence of a sustained Android performance pass.

## Implemented

- The placeholder avatar fades when a short camera arm or upward pitch would make it obstruct the view; normal third-person visibility returns after the camera recovers. The existing ground-safe arm limit remains.
- Original vector MOVE joystick and DRAG TO LOOK indicators show the touch controls. The movement indicator follows the active finger and resets with touch release, focus loss or the license modal. Additional left-side fingers do not claim camera control.
- The large permanent attribution panel is replaced by one compact OpenStreetMap attribution/license button. Complete OSM, asset, font and engine notices remain in a scrollable modal with a clear return button. Opening it clears movement and touch ownership; gameplay HUD text is hidden behind an opaque readable panel.
- HUD layout follows viewport size and maps Android's reported safe area into viewport coordinates. Canvas aspect expansion is enabled for wide screens. Desktop captures fill the viewport; physical phone cutout/edge behavior still needs testing.
- No new external art or fonts were added. The geographic source, landmark anchors, footprints and existing art remain unchanged. UI drawing is original MIT project code.

## Build identity

- Runtime/source commit: `0c30ce547c5ce27b76fd1c3375d10616b467088f` on `dev/sprint1-geographic-foundation`. Subsequent report/README commits do not change the runtime.
- APK: `Hyderabad-Rise-v0.1.7-debug.apk`; package `in.hyderabad.rise.prototype`; version code 5; ARM64; min SDK 24; target SDK 36.
- APK size: 33,998,062 bytes.
- SHA-256: `89f7b74593c6da2cf64060635502b80404eb829ec7640399b15cad17e29c55f3`.
- Android export succeeded using Godot 4.7.2 and matching templates, Java 21 and Android build-tools 36. Signature v2/v3 verifies. The debug certificate matches v0.1.6, so it should install as an update; installation on a phone has not been executed here.
- No INTERNET permission. All packaged map JSON and attribution files match the source bytes. Offline gameplay itself remains a phone check.

## Executed verification

Final CI: https://github.com/prakash28113/hyderabad-rise/actions/runs/45046989814 — geography and Godot jobs succeeded for the exact source commit above.

| Check | Actual result |
|---|---|
| Geographic unit tests and preprocessing | Five tests passed; generated map unchanged |
| Source/asset integrity | 76 tile inventory, raw-source identity, 30 asset hashes, runtime art/font coverage and notices passed |
| Building mesh regression | All 925 mapped footprints passed winding/normal checks |
| Scene and touch regression | Streaming/refcounts, nine-tile bound, recovery, gesture/focus reset, camera limit/fade/restoration and real HUD modal tests passed |
| HUD bounds | Credits and modal remain inside the viewport safe rectangle for 960, 1280 and 1616 width fixtures |
| Landmark regression | Source anchor/yaw, configured height, LOD order, batched surfaces, 720 road endpoints and gateway/pier collision passed |
| Graphical regression | Four actual Godot desktop renders: normal, upward camera, licenses, standard landscape; restoration check passed after physics updated |
| APK export and package | Built; signature, version, ARM64 engine, map/notices and offline permission checks passed |
| Physical v0.1.7 Android | Not executed; no attached phone available |

Graphical environment: Linux/X11, Godot 4.7.2 Compatibility/OpenGL, Mesa llvmpipe software rendering under Xvfb. Captures include wide 1616×720 and standard 1280×720 views. They are desktop evidence, not Android screenshots or device-FPS evidence. The short screenshot run includes startup/shader work and is not a benchmark. Android FPS, presented frame times, PSS and thermal behavior were not measured.

Earlier graphical checks were cancelled/timed out after a test asserted camera restoration before SpringArm's next physics update; a missing runner audio device also emitted an error. The check now waits for the rendered state, explicitly uses dummy CI audio and has a 90-second timeout. Those earlier runs are not counted as passes. The final code passed the complete pipeline.

The QA evidence archive contains final local package checks, Godot logs and the final CI renders. The supplied phone recording has not been published to the repository or included in that archive. Screenshot art follows the existing project art attribution and CC BY-SA 4.0 terms; see LICENSE_REGISTER.md and the supplied asset credits.

## Remaining work and next phone check

The world is still visually sparse, the avatar is still a placeholder and synchronous tile creation can hitch. This update does not add market frontage, traffic, driving, pedestrians or missions, and does not establish a 30 FPS acceptance.

On the phone, install over v0.1.6 and repeat the same camera motions: look up at Charminar, return to a level view, walk while panning with another finger, release both fingers, open/close credits, then background/resume. Confirm screen edges/cutouts and touch sizes in a new recording. After that, improve documented market frontage/source coverage and profile streaming before district expansion or driving.

No merge, release or store publication was performed. Original Git history and tag remain preserved.
