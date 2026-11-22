# License and attribution register
| Item | Origin | License / obligations | Status |
|---|---|---|---|
| Raw charminar.osm.xml, converted JSON | OpenStreetMap contributors, official map API, 2026-11-22 | ODbL 1.0, https://opendatacommons.org/licenses/odbl/1-0/ ; © OpenStreetMap contributors, https://www.openstreetmap.org/copyright | Included; XML source metadata retained |
| Derived GeoJSON, registry, tile data | OSM extract processed by tools/preprocess.py | ODbL 1.0 derivative database; retain attribution and make corresponding database available under ODbL when publicly used/distributed | Included with this source package; retain download access with any release |
| GDScript, Python, scene, placeholder geometry | Original generated project work | MIT; see LICENSE; excludes OSM data and third-party tools | No external models/textures imported |
| Godot engine | Godot contributors | MIT, https://godotengine.org/license/ | Tool installed; redistribute engine notice with exported binary |
| Blender | Blender Foundation/contributors | GPL; https://www.blender.org/about/license/ ; output assets separately licensed | Original Blender models and authoring scene supplied; generated art CC BY-SA 4.0 |
| QGIS | QGIS contributors | GPL; https://qgis.org/license/ | Installed; GeoJSON inspection workflow supplied |

Runtime attribution is always displayed. No satellite imagery, Google data, commercial models or stock textures bundled. Noto fonts are bundled under SIL OFL 1.1. Matching Godot 4.7.2 license/third-party notices and an offline ODbL copy are bundled and accessible with the Licenses button (ODbL copy is raw HTML text). APK packaging checks confirm these files are included. Public release still requires visual credits verification and making corresponding OSM derived databases available. New assets require author, origin URL, retrieval date, hash, license, modifications and attribution before ingestion.

## Sprint 1.5 additions

HYDERABAD RISE — SPRINT 1.5 ASSET CREDITS
Original procedural Charminar/Old City study models, auto-rickshaw, props and palette atlas:
Hyderabad Rise project contributors, CC BY-SA 4.0.
Authoring source: art/blender/build_assets.py and Hyderabad_Original_Assets.blend.
This is an approximate reference-informed model, not an ASI-approved survey reproduction.

Visual references (photograph pixels not used in game textures):
charminar-aerial-Kdas1977.jpg — Kdas1977, CC BY-SA 4.0
https://commons.wikimedia.org/wiki/File:Charminar_of_Hyderabad_Telangana.jpg
charminar-street-Zahid.jpg — S K Zahid Basha, CC BY-SA 4.0
https://commons.wikimedia.org/wiki/File:Charminar_-_Hyderabad,_Telangana,_India.jpg
charminar-portal-Rashid.jpg — Rashid Jorvee, CC BY-SA 4.0
https://commons.wikimedia.org/wiki/File:Charminar_Arc_complete_view_of_other_gate.jpg
auto-reference-Wasiul.jpg — Wasiul Bahar, CC BY-SA 4.0
https://commons.wikimedia.org/wiki/File:Auto_rickshaw_at_Hyderabad.jpg

License: https://creativecommons.org/licenses/by-sa/4.0/
Changes: original procedural reinterpretation of observed architectural forms; no photogrammetry or photo projection.
Reference photos and source model files are included with the source package.
No endorsement by photographers, ASI or Government of Telangana is implied.

Map data: © OpenStreetMap contributors, ODbL 1.0.
https://www.openstreetmap.org/copyright
Charminar footprint way 238186115; road/building feature IDs retained.

Signage: English and Urdu proper-name labels from Wikidata Q1771696 (CC0).
https://www.wikidata.org/wiki/Q1771696
Telugu sign uses OSM name:te spelling; Wikidata lists a documented variant.
No claim of native-speaker proofreading or surveyed commercial sign reproduction.
Noto Sans, Noto Sans Telugu, Noto Naskh Arabic — SIL OFL 1.1; see FONT-LICENSE.txt.

Complete per-file hashes and provenance: `references/asset-license-register.json`. All GLBs, atlas and Blender source are licensed CC BY-SA 4.0; GDScript/Python code remains MIT and OSM-derived databases remain ODbL. Screenshots of this art are distributed with the same CC BY-SA 4.0 notice. The original MIT notice does not relicense fonts, reference photographs or this art.
