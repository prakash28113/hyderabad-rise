"""OSM JSON to local WGS84 tangent plane, GeoJSON and 256 m tiles. Stdlib only."""
import json, math, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LAT,LON=17.3616,78.4747
A=6378137.0
E2=6.69437999014e-3
def ecef(lat,lon):
    a,b=map(math.radians,(lat,lon)); n=A/math.sqrt(1-E2*math.sin(a)**2)
    return (n*math.cos(a)*math.cos(b),n*math.cos(a)*math.sin(b),n*(1-E2)*math.sin(a))
def local(lat,lon):
    x,y,z=(v-o for v,o in zip(ecef(lat,lon),ecef(LAT,LON)))
    a,b=map(math.radians,(LAT,LON))
    return [-math.sin(b)*x+math.cos(b)*y, math.sin(a)*math.cos(b)*x+math.sin(a)*math.sin(b)*y-math.cos(a)*z]
def tile(x,z): return f"{math.floor(x/256)}_{math.floor(z/256)}"
def main():
    src=ROOT/'data/raw/charminar.osm.json'; raw=json.loads(src.read_text()); nodes={e['id']:e for e in raw['elements'] if e['type']=='node'}
    tiles={}; features=[]; landmarks=[]
    for e in raw['elements']:
        tags=e.get('tags',{})
        if tags.get('name')=='Charminar': landmarks.append(e)
        if e['type']!='way' or not ('highway' in tags or 'building' in tags): continue
        if any(n not in nodes for n in e['nodes']): raise ValueError('Unresolved source node')
        pts=[local(nodes[n]['lat'],nodes[n]['lon']) for n in e['nodes']]
        if len(pts)<2: continue
        kind='road' if 'highway' in tags else 'building'
        # Segment ownership includes every intersected tile through AABB registration.
        item={'id':e['id'],'kind':kind,'points':pts,'nodes':e['nodes'],'tags':tags}
        lo=[math.floor(min(v[i] for v in pts)/256) for i in (0,1)]; hi=[math.floor(max(v[i] for v in pts)/256) for i in (0,1)]
        for tx in range(lo[0],hi[0]+1):
            for tz in range(lo[1],hi[1]+1): tiles.setdefault(f'{tx}_{tz}',[]).append(item)
        geom={'type':'LineString','coordinates':[[nodes[n]['lon'],nodes[n]['lat']] for n in e['nodes']]}
        features.append({'type':'Feature','properties':{'osm_id':e['id'],'kind':kind,**tags},'geometry':geom})
    out=ROOT/'godot/data'; out.mkdir(exist_ok=True)
    for old in out.glob('tile_*.json'): old.unlink()
    for key,items in tiles.items(): (out/f'tile_{key}.json').write_text(json.dumps(items))
    registry={'origin':[LAT,LON],'axis':'x east, y up, z south','tile_size':256,'tiles':sorted(tiles),'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'landmarks':landmarks,'feature_count':len(features)}
    (out/'registry.json').write_text(json.dumps(registry,indent=2))
    (ROOT/'data/charminar.geojson').write_text(json.dumps({'type':'FeatureCollection','features':features}))
    print(json.dumps({k:v for k,v in registry.items() if k not in ('tiles','landmarks')},indent=2)); print('tiles',len(tiles),'landmarks',len(landmarks))
if __name__=='__main__': main()
