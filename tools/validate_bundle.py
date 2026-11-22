"""Check delivered map identity, packaged attribution and licensed asset hashes offline."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def validate():
    registry = json.loads((ROOT / 'godot/data/registry.json').read_text())
    raw = ROOT / 'data/raw/charminar.osm.json'
    if hashlib.sha256(raw.read_bytes()).hexdigest() != registry['source_sha256']:
        raise ValueError('Registry does not identify the bundled OSM source')
    expected = {f'tile_{key}.json' for key in registry['tiles']}
    actual = {p.name for p in (ROOT / 'godot/data').glob('tile_*.json')}
    if expected != actual:
        raise ValueError('Missing or stale map tiles')
    entries = json.loads((ROOT / 'references/asset-license-register.json').read_text())
    registered = set()
    for entry in entries:
        name = entry['file']
        if name in registered:
            raise ValueError(f'Duplicate license record: {name}')
        registered.add(name)
        for key in ('author', 'source', 'license', 'license_url', 'sha256'):
            if not entry.get(key):
                raise ValueError(f'Missing {key}: {name}')
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != entry['sha256']:
            raise ValueError(f'Asset changed without updating license register: {name}')
    for folder, extensions in [('godot/assets', {'.glb', '.png'}), ('godot/fonts', {'.ttf'})]:
        for path in (ROOT / folder).rglob('*'):
            if path.suffix in extensions and path.relative_to(ROOT).as_posix() not in registered:
                raise ValueError(f'Unregistered runtime asset: {path.relative_to(ROOT)}')
    for name in ('ASSET_CREDITS.txt', 'FONT-LICENSE.txt', 'GODOT_LICENSE.txt', 'GODOT_COPYRIGHT.txt', 'ODbL-1.0.html'):
        if not (ROOT / 'godot/data' / name).stat().st_size:
            raise ValueError(f'Empty attribution: {name}')
    print(f'PASS: {len(expected)} map tiles, source hash, {len(entries)} asset hashes, runtime art/font coverage and notices')


if __name__ == '__main__':
    validate()
