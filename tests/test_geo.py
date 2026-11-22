import sys,unittest,json,math
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from preprocess import local,tile,ROOT,LAT,LON
class GeoTests(unittest.TestCase):
 def test_origin(self): self.assertEqual(local(LAT,LON),[0.0,0.0])
 def test_axes_and_scale(self):
  east=local(LAT,LON+0.001); north=local(LAT+0.001,LON)
  self.assertTrue(105<east[0]<108); self.assertTrue(-112<north[1]<-109)
 def test_negative_tile(self): self.assertEqual(tile(-0.01,0),' -1_0'.strip())
 def test_source_connectivity(self):
  raw=json.loads((ROOT/'data/raw/charminar.osm.json').read_text()); nodes={e['id']:e for e in raw['elements'] if e['type']=='node'}
  ways=[e for e in raw['elements'] if e['type']=='way' and 'highway' in e.get('tags',{})]
  self.assertGreater(len(ways),0)
  for w in ways:
   for n in w['nodes']: self.assertIn(n,nodes)
 def test_tile_coverage_and_identity(self):
  reg=json.loads((ROOT/'godot/data/registry.json').read_text()); seen={}
  for key in reg['tiles']:
   for f in json.loads((ROOT/f'godot/data/tile_{key}.json').read_text()):
    if f['id'] in seen: self.assertEqual(f,seen[f['id']])
    seen[f['id']]=f
  self.assertEqual(len(seen),reg['feature_count'])
if __name__=='__main__': unittest.main()
