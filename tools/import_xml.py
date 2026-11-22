"""Convert official OSM map API XML into the preprocessing input schema."""
import xml.etree.ElementTree as ET,json
from pathlib import Path
p=Path(__file__).resolve().parents[1]/'data/raw'
r=ET.parse(p/'charminar.osm.xml').getroot(); elements=[]
for e in r:
 if e.tag not in ('node','way','relation'): continue
 d={'type':e.tag,'id':int(e.attrib['id']),'tags':{t.attrib['k']:t.attrib['v'] for t in e.findall('tag')}}
 for k in ('lat','lon'):
  if k in e.attrib:d[k]=float(e.attrib[k])
 if e.tag=='way':d['nodes']=[int(n.attrib['ref']) for n in e.findall('nd')]
 elements.append(d)
(p/'charminar.osm.json').write_text(json.dumps({'source':'https://www.openstreetmap.org/api/0.6/map?bbox=78.468,17.355,78.481,17.367','elements':elements}))
