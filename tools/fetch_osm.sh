#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
curl --fail --max-time 90 'https://www.openstreetmap.org/api/0.6/map?bbox=78.468,17.355,78.481,17.367' -o data/raw/download.tmp
python3 -c 'import xml.etree.ElementTree as E; r=E.parse("data/raw/download.tmp").getroot(); assert r.tag=="osm" and r.findall("way")'
mv data/raw/download.tmp data/raw/charminar.osm.xml
python3 tools/import_xml.py
python3 tools/preprocess.py
