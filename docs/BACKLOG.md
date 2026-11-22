# Milestone gate and next sprint
Do not expand districts until the Charminar scene has passed visual/authenticity review and physical Android profiling.

1. Debug ARM64 APK and signature/package/permission checks are complete. Install on physical Android hardware and resolve any launch/runtime issues. Add pinned Godot import, smoke and Android artifact CI jobs once a remote exists. Current workflow validates geography only.
2. Inspect visuals, controller, spawn collision and touch on a real device. Fix triangulation/winding, camera obstruction, terrain and study-edge recovery. Add regression tests for shared junction coordinates, tile seams and invalid polygons.
3. Queue mesh work across frames; batch roads/buildings per tile using ArrayMesh/MultiMesh and simplified collision. Respect frame budget; track unload hysteresis and peak memory.
4. In QGIS compare junctions and Charminar footprint to independently permitted reference. Record discrepancies and confidence. Preserve layer/bridge tags in future routing graph.
5. Original Charminar model in Blender: metre units, OSM aligned footprint, reference board of licensed sources, separately validated dimensions, facade and minaret silhouette, LOD0/1/2, collision proxy; export glTF with source .blend and license metadata. Do not infer exact measurements from generic photos.
6. Build original Hyderabad shop modules and props from field/CC0 reference; Telugu, Urdu and English signage requires licensed fonts and native-language review. No copied commercial logos.
7. Auto-rickshaw controller, road graph traffic, pedestrian navigation, all at reduced update frequency. Delivery mission anchored to validated OSM destinations; local wallet/save with schema version, atomic save, backup and corruption recovery.
8. District registry with adjacency, source version, transformation CRS and accuracy records; expand only after milestone gate.

Proposed Android budgets, not measurements: 30 FPS / 33.3 ms frame; CPU p95 <=25 ms, GPU p95 <=28 ms, no streaming stall >100 ms; process PSS <=600 MB, textures <=128 MB, visible triangles <=250k, draw calls <=180, 9 near tiles. Test 4 GB baseline Android device plus Pixel 9a and a midrange device. Run 15 minute walking route + repeated streaming boundaries offline and warm; capture Perfetto/Godot profiler, dumpsys meminfo, thermal state and p50/p95/p99 frame times. No physical device available in this workspace.

## Sprint 1.5 follow-up
The ordered, current acceptance backlog is in [SPRINT15_REPORT.md](SPRINT15_REPORT.md#known-issues-and-ordered-backlog). Physical phone verification, authenticated branch delivery, streaming hitches, source completeness and measured architectural refinement precede Sprint 2 gameplay.
