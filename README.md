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

Debug APK: `build/hyderabad-debug.apk` (separately supplied). Android 7.0+ ARM64; target SDK 36. Device install/launch remains untested.

See docs/GEOGRAPHY.md, docs/QA.md, docs/LICENSE_REGISTER.md and docs/BACKLOG.md. Local branch: dev/sprint1-geographic-foundation. Remote creation/push pending owner/repository approval. No merge, deployment or publishing performed.
