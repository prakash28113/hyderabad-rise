# Android build and validation
Godot 4.7.2 with matching export templates, ARM64 debug export, OpenJDK 21 installed on this host, Android build-tools 35.0.0, platform-tools and platform 35. The prebuilt Godot template reports compile/target 36 and minSdk 24. Build-tools fallback warning is recorded. Install SDK platform/build-tools matching target 36 for follow-up validation. No Gradle/custom build is used.

Configure Editor Settings > Export > Android with your Java SDK and Android SDK directories, and install matching Godot export templates. Do not commit host paths or private signing credentials.

```sh
python3 -m unittest discover -s tests -v
godot --headless --path godot --script res://scripts/validate.gd
godot --headless --path godot --export-debug Android ../build/hyderabad-debug.apk
apksigner verify --verbose build/hyderabad-debug.apk
aapt dump badging build/hyderabad-debug.apk
aapt dump permissions build/hyderabad-debug.apk
adb install -r build/hyderabad-debug.apk
```
Last command has NOT been executed; no physical device is connected. Debug key is development-only. No store publication or production signing. Use APK hash and exact source commit when recording device QA. Do not publish until approval and milestone gate pass.

## v0.1.1 follow-up
Build-tools and platform 36 installed; final follow-up export uses build-tools 36.0.0 with target 36. Version code 2. See VERIFICATION_FOLLOWUP.md for actual scope, screenshots and physical collector instructions.

## Current v0.1.6 continuation
Godot 4.7.2 official matching Android templates, OpenJDK 21, SDK platform/build-tools 36 and platform-tools were installed in this workspace. Export succeeded after configuring local Editor Settings and creating `build/`. Export preset version code 4/name 0.1.6 targets Android 7+ ARM64. Run `mkdir -p build` before export; preset output is `../build/hyderabad-v0.1.6-debug.apk`. Verify with build-tools 36 `apksigner` and `aapt`. New signature v2/v3, package, all 76 tile bytes and packaged attribution checks passed. No Internet permission is present. See CONTINUATION_REPORT.md and its evidence directory.

The new debug signer differs from v0.1.5; upgrading an installed older prototype can require uninstalling it (clears app data). Neither a phone installation nor physical performance test has run. No release key/store publication is configured. Host paths and private keys stay outside version control.
