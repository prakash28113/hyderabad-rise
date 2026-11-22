"""Derive reproducible street-level QA viewpoints from licensed OSM road segments."""
import json,math
from pathlib import Path
from preprocess import ROOT,local
r=json.loads((ROOT/'data/raw/charminar.osm.json').read_text());nodes={e['id']:e for e in r['elements'] if e['type']=='node'}
a=json.loads((ROOT/'godot/data/charminar-anchor.json').read_text());cx,cz=a['center_local'];angle=a['footprint_axis_radians'];segments=[]
for w in r['elements']:
 if w['type']!='way' or 'highway' not in w.get('tags',{}):continue
 for n,m in zip(w['nodes'],w['nodes'][1:]):segments.append((w,n,m,local(nodes[n]['lat'],nodes[n]['lon']),local(nodes[m]['lat'],nodes[m]['lon'])))
views=[]
for name,dx,dz in [('south',0,70),('north',0,-70),('east',70,0),('west',-70,0)]:
 target=(cx+math.cos(angle)*dx-math.sin(angle)*dz,cz+math.sin(angle)*dx+math.cos(angle)*dz)
 best=None
 for w,n,m,p,q in segments:
  vx,vz=q[0]-p[0],q[1]-p[1];den=vx*vx+vz*vz
  if den<1e-6:continue
  t=max(0,min(1,((target[0]-p[0])*vx+(target[1]-p[1])*vz)/den));pos=(p[0]+vx*t,p[1]+vz*t);dist=math.dist(target,pos)
  if best is None or dist<best[0]:best=(dist,w,n,m,t,pos)
 dist,w,n,m,t,pos=best
 views.append({'name':name,'position':[pos[0],1.7,pos[1]],'look_at':[cx,21.5,cz],'road_osm_id':w['id'],'road_name':w['tags'].get('name','unnamed'),'node_pair':[n,m],'snap_distance_m':dist,'fov_degrees':60.0})
(ROOT/'godot/data/qa-views.json').write_text(json.dumps(views,indent=2));print(json.dumps(views,indent=2))
