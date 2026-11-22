"""Independent implementation check using PROJ; not a field accuracy claim."""
from pyproj import Transformer
from preprocess import local,LAT,LON
import math,json
pipeline=f'+proj=pipeline +step +proj=cart +ellps=WGS84 +step +proj=topocentric +ellps=WGS84 +lat_0={LAT} +lon_0={LON} +h_0=0'
t=Transformer.from_pipeline(pipeline)
res=[]
for lat,lon in [(LAT,LON),(17.355,78.468),(17.367,78.481),(17.36,78.48)]:
 e,n,u=t.transform(lon,lat,0); x,z=local(lat,lon)
 res.append(math.hypot(x-e,z+n))
assert max(res)<1e-5
print(json.dumps({'points':len(res),'maximum_horizontal_residual_m':max(res),'reference':'PROJ WGS84 cart + topocentric','field_accuracy':'not measured'},indent=2))
