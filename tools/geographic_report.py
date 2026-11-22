"""Exact-data QA overlay and source comparison; no survey-accuracy claim."""
import sys,json,math,hashlib
from pathlib import Path
from preprocess import ROOT,local
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle,Polygon
raw=json.loads((ROOT/'data/raw/charminar.osm.json').read_text());nodes={e['id']:e for e in raw['elements'] if e['type']=='node'}
anchor=json.loads((ROOT/'godot/data/charminar-anchor.json').read_text());cx,cz=anchor['center_local'];theta=anchor['footprint_axis_radians'];fig,ax=plt.subplots(figsize=(10,10))
for w in raw['elements']:
 if w['type']!='way' or not any(k in w.get('tags',{}) for k in ['building','highway']):continue
 ps=[local(nodes[n]['lat'],nodes[n]['lon']) for n in w['nodes']]
 if min(math.hypot(x-cx,z-cz) for x,z in ps)>140:continue
 xs,zs=zip(*ps)
 if 'building' in w['tags']:
  ax.fill(xs,zs,color='#d6ccbc' if w['id']!=238186115 else '#edd18e',alpha=.8)
  ax.plot(xs,zs,color='#aa9a80',linewidth=.6)
 else:ax.plot(xs,zs,color='#5c6770',linewidth=1.7)
def rot(x,z):return(cx+math.cos(theta)*x-math.sin(theta)*z,cz+math.sin(theta)*x+math.cos(theta)*z)
ax.add_patch(Polygon([rot(x,z) for x,z in [(-10,-10),(10,-10),(10,10),(-10,10)]],fill=False,edgecolor='#b72f20',linewidth=2,label='Model 20 m body (reference-based)'))
for x in [-10,10]:
 for z in [-10,10]:ax.add_patch(Circle(rot(x,z),3.15,fill=False,edgecolor='#b72f20',linewidth=1.5))
views=json.loads((ROOT/'godot/data/qa-views.json').read_text())
for v in views:
 x,_,z=v['position'];ax.scatter(x,z,color='#2765a6',s=60);ax.annotate(v['name']+'\nOSM '+str(v['road_osm_id']),(x,z),xytext=(6,5),textcoords='offset points',fontsize=8);ax.plot([x,cx],[z,cz],'--',color='#2765a6',alpha=.45)
ax.scatter(cx,cz,c='red',marker='+',s=90,label='OSM polygon centroid / model anchor')
ax.set(xlim=(cx-120,cx+120),ylim=(cz+120,cz-120),xlabel='Local east X (m)',ylabel='Local south Z (m)',title='Charminar: source geometry, model anchor and matched QA viewpoints')
ax.set_aspect('equal');ax.grid(alpha=.2);ax.legend(loc='upper left',fontsize=8)
fig.text(.12,.025,'© OpenStreetMap contributors · ODbL 1.0 | Model outline is approximate, not a surveyed building plan.',fontsize=8)
fig.savefig(ROOT/'docs/evidence/sprint15/geographic-overlay.png',dpi=150,bbox_inches='tight');plt.close(fig)
point=local(17.361607,78.474657)
result={'raw_json_sha256':hashlib.sha256((ROOT/'data/raw/charminar.osm.json').read_bytes()).hexdigest(),'anchor_local_m':[cx,cz],'rotation_clockwise_from_east_degrees':math.degrees(theta),'commons_object_point_wgs84':[17.361607,78.474657],'commons_point_vs_osm_centroid_distance_m':math.dist(point,[cx,cz]),'source':'Kdas1977 Commons file object-location metadata, CC0 structured data; not camera position','confidence':'Volunteered reference agreement only; no surveyed control point or absolute accuracy bound','qa_view_count':len(views),'model_height_parameter_m':48.7,'model_body_side_parameter_m':20,'widths_and_props':'Road width defaults, shop typologies and furniture are explicit art assumptions, not independently measured'}
(ROOT/'docs/evidence/sprint15/geographic-audit.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
