"""Original procedural Charminar study + Old City modules. Run Blender --background --python FILE.
Coordinate convention: Blender X east, Y north, Z up. Dimensions are art estimates except documented anchors.
All source meshes/atlas are original; references and attribution in references/ and docs/LICENSE_REGISTER.md.
"""
import bpy,math,json,random
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'godot/assets';OUT.mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
# 4x4 original palette atlas with deterministic plaster grain; no photo pixels used.
colors=[(.76,.72,.62),(.92,.87,.75),(.24,.15,.09),(.10,.15,.16),(.64,.28,.16),(.75,.64,.46),(.16,.35,.30),(.82,.59,.17),(.13,.12,.10),(.27,.39,.43),(.36,.43,.21),(.94,.69,.07),(.08,.09,.08),(.39,.29,.19),(.65,.63,.52),(.45,.46,.41)]
image=bpy.data.images.new('Original_OldCity_Atlas',512,512);rng=random.Random(1591);pixels=[]
for y in range(512):
 for x in range(512):
  c=colors[(y//128)*4+x//128];n=rng.uniform(-.022,.022)
  pixels.extend([max(0,min(1,v+n)) for v in c]+[1])
image.pixels=pixels;image.filepath_raw=str(OUT/'old_city_atlas.png');image.file_format='PNG';image.save()
mat=bpy.data.materials.new('OldCity_Original_Atlas');mat.use_nodes=True
bs=mat.node_tree.nodes.get('Principled BSDF');bs.inputs['Roughness'].default_value=.86
tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=image;mat.node_tree.links.new(tex.outputs['Color'],bs.inputs['Base Color'])
class Builder:
 def __init__(self):self.v=[];self.f=[];self.tiles=[]
 def face(self,vs,t=0):
  start=len(self.v);self.v.extend(vs);self.f.append(tuple(range(start,start+len(vs))));self.tiles.append(t)
 def cube(self,c,size,t=0,angle=0):
  x,y,z=c;a,b,h=[s/2 for s in size];co=math.cos(angle);si=math.sin(angle)
  def p(i,j,k):return(x+co*i-si*j,y+si*i+co*j,z+k)
  pts=[p(i,j,k) for i,j,k in [(-a,-b,-h),(a,-b,-h),(a,b,-h),(-a,b,-h),(-a,-b,h),(a,-b,h),(a,b,h),(-a,b,h)]]
  for ids in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:self.face([pts[i] for i in ids],t)
 def lathe(self,x,y,profile,t=0,n=24):
  for (r,z),(r2,z2) in zip(profile,profile[1:]):
   for i in range(n):
    a=2*math.pi*i/n;b=2*math.pi*(i+1)/n
    self.face([(x+r*math.cos(a),y+r*math.sin(a),z),(x+r*math.cos(b),y+r*math.sin(b),z),(x+r2*math.cos(b),y+r2*math.sin(b),z2),(x+r2*math.cos(a),y+r2*math.sin(a),z2)],t)
 def cylinder(self,x,y,z,r,h,t=0,n=24,r2=None):
  self.lathe(x,y,[(0,z),(r,z),(r if r2 is None else r2,z+h),(0,z+h)],t,n)
 def beam(self,a,b,r,t=0,n=8):
  av,bv=Vector(a),Vector(b);axis=(bv-av).normalized();u=axis.cross(Vector((0,0,1)))
  if u.length<.1:u=axis.cross(Vector((0,1,0)))
  u.normalize();v=axis.cross(u)
  for i in range(n):
   p=u*math.cos(2*math.pi*i/n)*r+v*math.sin(2*math.pi*i/n)*r;q=u*math.cos(2*math.pi*(i+1)/n)*r+v*math.sin(2*math.pi*(i+1)/n)*r
   self.face([tuple(av+p),tuple(av+q),tuple(bv+q),tuple(bv+p)],t)
 def object(self,name):
  mesh=bpy.data.meshes.new(name);mesh.from_pydata(self.v,[],self.f);mesh.materials.append(mat);mesh.update()
  ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob);uv=mesh.uv_layers.new()
  for poly,t in zip(mesh.polygons,self.tiles):
   tx=t%4;ty=t//4
   for j,li in enumerate(poly.loop_indices):
    corners=[(.1,.1),(.9,.1),(.9,.9),(.1,.9)];u,v=corners[j%4];uv.data[li].uv=((tx+u)/4,(ty+v)/4)
  return ob

def portal(b,width,spring,depth,zbase,top,turn=0,halfwall=10,steps=20,t=0):
 # Pointed arch: two circular segments; remaining spandrel is actual solid geometry.
 a=width/2
 def arch(x):return zbase+spring+math.sqrt(max(0,4*a*a-(abs(x)+a)**2)) if abs(x)<=a else zbase
 def orient(x,d,z):return(x*math.cos(turn)-d*math.sin(turn),x*math.sin(turn)+d*math.cos(turn),z)
 xs=sorted(set([-halfwall,-a]+[-a+width*i/steps for i in range(steps+1)]+[a,halfwall]))
 for x1,x2 in zip(xs,xs[1:]):
  z1=arch(x1) if x1>=-a and x2<=a else zbase;z2=arch(x2) if x1>=-a and x2<=a else zbase
  for d,rev in [(depth,True),(depth-1.25,False)]:
   vs=[orient(x1,d,z1),orient(x2,d,z2),orient(x2,d,top),orient(x1,d,top)]
   b.face(vs[::-1] if rev else vs,t)
  b.face([orient(x1,depth,z1),orient(x1,depth-1.25,z1),orient(x2,depth-1.25,z2),orient(x2,depth,z2)],1)
  if -a<=x1 and x2<=a:
   b.beam(orient(x1,depth+.06,z1),orient(x2,depth+.06,z2),.16,1,6)
 # Vertical portal jamb trims.
 for x in [-a,a]:b.beam(orient(x,depth+.1,zbase),orient(x,depth+.1,zbase+spring),.20,1)

def arch_window(b,cx,depth,z,w,h,turn=0):
 def o(x,d,y):return(x*math.cos(turn)-d*math.sin(turn),x*math.sin(turn)+d*math.cos(turn),y)
 vs=[o(cx-w/2,depth,z),o(cx+w/2,depth,z),o(cx+w/2,depth,z+h*.66),o(cx,depth,z+h),o(cx-w/2,depth,z+h*.66)]
 b.face(vs,2)
 for a,q in zip(vs,vs[1:]+vs[:1]):b.beam(a,q,.065,1,5)

def landmark(lod):
 b=Builder();n=[32,20,12][lod]
 # Recessed four-way crossing and four real open portals; no solid box in the passage.
 for k in range(4):
  turn=k*math.pi/2
  portal(b,11,8.2,10,0,21.0,turn,steps=[24,14,8][lod])
  # Gallery cornices, pierced-looking arched recesses, clock and parapet.
  for z,w,h in [(20.9,20.7,.45),(24.0,20.8,.45),(26.8,20.7,.5)]:
   b.cube((-10*math.sin(turn),10*math.cos(turn),z),(w,1.8,h),1,turn)
  for row,z in enumerate([21.45,24.55]):
   for j in range(-4,5):arch_window(b,j*1.85,10.1,z,1.0,1.8,turn)
  # Main spandrel circular clock on each cardinal facade.
  p=(-10.15*math.sin(turn),10.15*math.cos(turn),19.8)
  # Clock disc vertical; octagonal face laid in facade plane.
  disk=[]
  for i in range(24):
   a=2*math.pi*i/24;disk.append((math.cos(a)*.70*math.cos(turn)+p[0],math.cos(a)*.70*math.sin(turn)+p[1],p[2]+math.sin(a)*.70))
  b.face(disk,1)
  b.beam(p,(p[0]+.35*math.cos(turn),p[1]+.35*math.sin(turn),p[2]+.05),.045,2)
  b.beam(p,(p[0],p[1],p[2]+.42),.045,2)
  if lod<2:
   for j in range(-14,15):
    x=j*.65;y=10
    xx=x*math.cos(turn)-y*math.sin(turn);yy=x*math.sin(turn)+y*math.cos(turn)
    b.cube((xx,yy,27.5),(.24,.7,.8),1,turn)
 # Open inner courtyard and roof slabs on perimeter; centre remains open.
 for x,y,sz in [(0,8,(16,4,1)),(0,-8,(16,4,1)),(8,0,(4,16,1)),(-8,0,(4,16,1))]:b.cube((x,y,25.5),sz,0)
 for x in [-10,10]:
  for y in [-10,10]:
   # Four corner towers: taper, lotus-shaped bracket collars and multiple balconies.
   b.lathe(x,y,[(0,0),(3.15,0),(3.15,1),(2.85,1.5),(2.8,19),(2.55,20),(2.5,28),(2.2,29),(2.15,36),(1.85,37),(1.85,43),(0,43)],0,n)
   for z,r in [(1,3.22),(18.6,3.22),(20,3.35),(27.6,3.0),(29,3.1),(35.7,2.7),(37.0,2.8),(42.8,2.45)]:
    b.lathe(x,y,[(r-.4,z-.6),(r,z),(r,z+.22),(r-.12,z+.45)],1,n)
   for z,r in [(20.4,3.1),(29.4,2.85),(37.4,2.55),(43.1,2.2)]:
    b.lathe(x,y,[(r,z),(r,z+.55),(r-.13,z+.65)],1,n)
    if lod<2:
     for i in range([24,12][lod]):
      a=i*2*math.pi/[24,12][lod];b.cylinder(x+math.cos(a)*r,y+math.sin(a)*r,z,.09,.8,1,6)
   # Ringed upper arcade recesses on the tower; actual small panels not photo texture.
   for z,r,h in [(19.35,2.84,1.5),(28.6,2.56,1.4),(36.65,2.22,1.4),(41.3,1.9,1.45)]:
    for i in range([16,10,6][lod]):
     a=2*math.pi*i/[16,10,6][lod]
     # Tangent arched window oriented around local turret.
     ca,sa=math.cos(a),math.sin(a);ww=.38
     vs=[]
     for u,v in [(-ww,0),(ww,0),(ww,h*.7),(0,h),(-ww,h*.7)]:vs.append((x+ca*r-sa*u,y+sa*r+ca*u,z+v))
     b.face(vs,2)
   # Domed crown and narrow original finial. Final cap height 48.7 m.
   prof=[(1.85,43.7),(2.05,44.1),(2.12,44.7),(2.0,45.4),(1.7,46),(1.2,46.5),(.55,46.95),(0.12,47.3)]
   b.lathe(x,y,prof,1,n)
   b.lathe(x,y,[(.12,47.15),(.18,47.4),(.10,47.65),(.14,47.85),(.07,48.1),(.08,48.35),(0,48.7)],7,max(8,n//2))
   if lod==0:
    # Repeated lotus brackets under balcony rings.
    for z,r in [(18.4,3.0),(27.4,2.8),(35.5,2.5)]:
     for i in range(24):
      a=i*2*math.pi/24;b.beam((x+math.cos(a)*(r-.4),y+math.sin(a)*(r-.4),z-.6),(x+math.cos(a)*r,y+math.sin(a)*r,z+.1),.12,1,5)
 return b.object('Charminar_LOD'+str(lod))

def shop(lod=0):
 b=Builder();b.cube((0,.28,1.5),(3.8,.65,3.0),0)
 b.cube((0,-.08,1.1),(2.8,.08,2.1),3)
 # shutter rails, lintel, pillars, window jali and balcony.
 for x in [-1.65,1.65]:b.cube((x,-.12,1.6),(.22,.4,3.2),1)
 for z in [0,2.4,3.1]:b.cube((0,-.12,z),(3.95,.42,.18),1)
 for z in [3.3,5.8]:b.cube((0,.1,z),(4.05,.9,.24),1)
 for x in [-.85,.85]:
  b.cube((x,-.1,4.55),(1.1,.15,1.55),2)
  for dx in [-.45,0,.45]:b.cube((x+dx,-.19,4.55),(.06,.10,1.5),1)
 if lod==0:
  for i in range(11):b.cube((0,-.14,.2+i*.18),(2.8,.06,.035),14)
  b.cube((0,-.48,3.5),(3.8,1.3,.18),5)
  for x in [-1.6,-.8,0,.8,1.6]:b.cube((x,-1.0,3.98),(.08,.08,.9),3)
  b.cube((0,-1,4.4),(3.8,.09,.09),3)
 b.cube((0,-.28,2.72),(3.1,.18,.40),6)
 # Market awning, sloped toward street.
 b.face([(-1.9,-.25,2.5),(1.9,-.25,2.5),(1.9,-2.0,2.18),(-1.9,-2.0,2.18)],4)
 return b.object('OldCityShop_LOD'+str(lod))
def stall():
 b=Builder();b.cube((0,0,.65),(2.5,1.25,.2),13)
 for x in [-1.15,1.15]:
  for y in [-.55,.55]:b.cylinder(x,y,0,.035,2.25,13,6)
 b.face([(-1.4,-.85,2.2),(1.4,-.85,2.2),(1.4,.85,2.5),(-1.4,.85,2.5)],7)
 for x in [-.85,-.3,.3,.85]:b.cube((x,0,.95),(.4,.7,.4),4 if x<0 else 6)
 return b.object('MarketStall')
def lamp():
 b=Builder();b.cylinder(0,0,0,.12,6.1,8,10);b.beam((0,0,6),(.9,0,6.5),.08,8);b.cube((1,0,6.48),(.7,.32,.12),1);return b.object('StreetLamp')
def pole():
 b=Builder();b.cylinder(0,0,0,.15,7.5,15,10);b.cube((0,0,7),(1.7,.12,.14),8)
 for x in [-.65,0,.65]:b.cylinder(x,0,7,.10,.3,14,8)
 return b.object('ElectricalPole')
def tree():
 b=Builder();b.cylinder(0,0,0,.24,3.2,13,8)
 for z,r in [(2.4,1.5),(3.0,2.0),(4.1,1.7),(5.0,1.0)]:b.lathe(0,0,[(0,z-.6),(r,z),(r*.85,z+.8),(0,z+1.5)],10,8)
 return b.object('NeemLikeTree')
def auto():
 b=Builder();b.cube((0,0,.6),(1.35,2.5,.42),6);b.cube((0,.70,1.0),(1.3,.6,.5),11)
 b.cube((0,-.25,1.05),(1.22,.85,.2),12);b.cube((0,.35,1.0),(.8,.5,.2),12)
 # Curved black fabric canopy, original mesh based on observed vehicle typology.
 for i in range(12):
  x1=-.74+1.48*i/12;x2=-.74+1.48*(i+1)/12
  z1=1.67+.32*math.sqrt(max(0,1-(x1/.75)**2));z2=1.67+.32*math.sqrt(max(0,1-(x2/.75)**2))
  b.face([(x1,-1.3,z1),(x2,-1.3,z2),(x2,.45,z2),(x1,.45,z1)],12)
 b.cube((0,-1.23,1.32),(1.4,.08,.85),12)
 b.cube((0,-1.29,1.45),(.85,.03,.34),9)
 for x in [-.52,.52]: b.cube((x,-1.3,.72),(.16,.06,.28),4)
 for x in [-.65,.65]:
  for y in [-1.22,.4]:b.beam((x,y,.75),(x,y,1.78),.045,12)
  b.cube((x,-.8,1.12),(.08,1.0,.45),6)
 # Front windshield is opaque tinted material for mobile performance.
 b.face([(-.65,.65,.95),(.65,.65,.95),(.58,.35,1.75),(-.58,.35,1.75)],9)
 b.cube((0,1.1,.95),(1.1,.15,.5),11)
 for x in [-.42,.42]:b.cube((x,1.2,1.04),(.22,.08,.16),1)
 # Three wheels: mesh axes in X, two rear one front.
 for x,y in [(-.68,-.9),(.68,-.9),(0,1.0)]:
  c=(x,y,.36)
  # Wheels via beam cylinders with radial profile in YZ plane.
  for i in range(16):
   a=2*math.pi*i/16;q=2*math.pi*(i+1)/16
   b.face([(x-.12,y+.32*math.cos(a),.36+.32*math.sin(a)),(x+.12,y+.32*math.cos(a),.36+.32*math.sin(a)),(x+.12,y+.32*math.cos(q),.36+.32*math.sin(q)),(x-.12,y+.32*math.cos(q),.36+.32*math.sin(q))],12)
  for side in [-1,1]:b.face([(x+side*.13,y+.22*math.cos(2*math.pi*i/16),.36+.22*math.sin(2*math.pi*i/16)) for i in range(16)],14)
 b.beam((0,.55,.9),(0,.55,1.3),.035,8);b.beam((-.28,.55,1.3),(.28,.55,1.3),.025,8)
 return b.object('HyderabadAutoRickshaw')

def export(ob,name):
 bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);bpy.context.view_layer.objects.active=ob
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_yup=True,export_apply=True,export_materials='EXPORT',export_extras=True)
 triangles=sum(len(f.vertices)-2 for f in ob.data.polygons)
 return {'file':name+'.glb','triangles':triangles,'vertices':len(ob.data.vertices),'materials':len(ob.data.materials)}
records=[]
for i in range(3):records.append(export(landmark(i),'charminar_lod'+str(i)))
for i in range(2):records.append(export(shop(i),'shop_lod'+str(i)))
for fn,name in [(stall,'market_stall'),(lamp,'street_lamp'),(pole,'electrical_pole'),(tree,'neem_tree'),(auto,'auto_rickshaw')]:records.append(export(fn(),name))
for ob in bpy.data.objects: ob.hide_set(ob.name != 'Charminar_LOD0')
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/blender/Hyderabad_Original_Assets.blend'))
(ROOT/'art/blender/asset-stats.json').write_text(json.dumps(records,indent=2));print('HYD_ASSETS',json.dumps(records))
