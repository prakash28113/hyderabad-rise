#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
query='[out:json][timeout:30];(way[highway](17.355,78.468,17.367,78.481);way[building](17.355,78.468,17.367,78.481);nwr[name="Charminar"](17.355,78.468,17.367,78.481););out body;>;out skel qt;'
curl --fail --max-time 90 --get --data-urlencode "data=$query" https://overpass-api.de/api/interpreter -o data/raw/download.tmp
python3 -c 'import json; d=json.load(open("data/raw/download.tmp")); assert d["elements"] and not d.get("remark")'
mv data/raw/download.tmp data/raw/charminar.osm.json
python3 tools/preprocess.py
