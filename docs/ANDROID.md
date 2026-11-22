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
