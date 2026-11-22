extends Node3D
const Player = preload("res://scripts/player.gd")
var registry: Dictionary
var loaded := {}
var residents := {}
var player: CharacterBody3D
var status: Label
var last_tile := Vector2i(999,999)
var road_material := StandardMaterial3D.new()
var building_material := StandardMaterial3D.new()
func _ready():
 registry = JSON.parse_string(FileAccess.get_file_as_string("res://data/registry.json"))
 road_material.albedo_color = Color("393b3b")
 building_material.albedo_color = Color("bd9d78")
 var light := DirectionalLight3D.new()
 light.rotation_degrees = Vector3(-55,-30,0)
 add_child(light)
 var env := WorldEnvironment.new()
 env.environment = Environment.new()
 env.environment.background_mode = Environment.BG_COLOR
 env.environment.background_color = Color("a5c3d1")
 env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.environment.ambient_light_color = Color.WHITE
 env.environment.ambient_light_energy = 0.65
 add_child(env)
 box(self,Vector3(0,-1,0),Vector3(2200,2,2200),Color("a89678"),true)
 player = Player.new()
 player.position = Vector3(0,2,55)
 add_child(player)
 var canvas := CanvasLayer.new()
 add_child(canvas)
 status = Label.new()
 status.position = Vector2(20,20)
 status.add_theme_font_size_override("font_size",20)
 canvas.add_child(status)
 var credit := Label.new()
 credit.text = "© OpenStreetMap contributors · ODbL 1.0
https://www.openstreetmap.org/copyright
Left drag: walk · Right drag: camera · Desktop: WASD + right mouse
OSM geometry prototype — heights, widths and terrain are placeholders"
 credit.position = Vector2(20,590)
 canvas.add_child(credit)
 var credits_button := Button.new()
 credits_button.text = "Licenses"
 credits_button.position = Vector2(1120,20)
 canvas.add_child(credits_button)
 var panel := PanelContainer.new()
 panel.position = Vector2(60,70)
 panel.size = Vector2(1160,490)
 panel.visible = false
 canvas.add_child(panel)
 var text := TextEdit.new()
 text.custom_minimum_size = Vector2(1160,490)
 text.editable = false
 text.text = "Map data © OpenStreetMap contributors, ODbL 1.0\nhttps://www.openstreetmap.org/copyright\nCorresponding geographic database is supplied with this prototype source package.\n\n" + FileAccess.get_file_as_string("res://data/ODbL-1.0.html") + "\n\n" + FileAccess.get_file_as_string("res://data/GODOT_LICENSE.txt") + "\n" + FileAccess.get_file_as_string("res://data/GODOT_COPYRIGHT.txt")
 panel.add_child(text)
 credits_button.pressed.connect(func(): panel.visible = not panel.visible)
 update_stream()
func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, collision: bool):
 var mesh := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 mesh.mesh = shape
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mesh.material_override = mat
 mesh.position = pos
 parent.add_child(mesh)
 if collision: mesh.create_trimesh_collision()
 return mesh
func add_feature(f: Dictionary):
 var root := Node3D.new()
 add_child(root)
 var points: Array = f.points
 if f.tags.get("name","") == "Charminar":
  var center := Vector2.ZERO
  for pt in points: center += Vector2(pt[0],pt[1])
  center /= points.size()
  var marker := Label3D.new()
  marker.text = "CHARMINAR\nOSM footprint · model pending"
  marker.position = Vector3(center.x,12,center.y)
  marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
  marker.font_size = 64
  root.add_child(marker)
 if f.kind == "road":
  var width := 5.0
  if f.tags.get("highway","") in ["footway","path","steps"]: width = 2.0
  for i in range(points.size()-1):
   var a := Vector3(points[i][0],0.025,points[i][1])
   var b := Vector3(points[i+1][0],0.025,points[i+1][1])
   if a.distance_to(b)<0.01: continue
   var mesh := MeshInstance3D.new()
   var road := BoxMesh.new()
   road.size = Vector3(width,0.04,a.distance_to(b))
   mesh.mesh = road
   mesh.material_override = road_material
   root.add_child(mesh)
   mesh.position = (a+b)*0.5
   mesh.look_at(b,Vector3.UP)
 else:
  var polygon := PackedVector2Array()
  for pt in points: polygon.append(Vector2(pt[0],pt[1]))
  if polygon.size()>1 and polygon[0].is_equal_approx(polygon[-1]): polygon.remove_at(polygon.size()-1)
  if polygon.size()<3: return root
  var triangles := Geometry2D.triangulate_polygon(polygon)
  if triangles.is_empty(): return root
  var surface := SurfaceTool.new()
  surface.begin(Mesh.PRIMITIVE_TRIANGLES)
  var height := 7.0 # Explicit visualization assumption, never a measured height.
  for i in range(0,triangles.size(),3):
   for j in [0,2,1]:
    var pt := polygon[triangles[i+j]]
    surface.add_vertex(Vector3(pt.x,height,pt.y))
  for i in polygon.size():
   var a := polygon[i]
   var b := polygon[(i+1)%polygon.size()]
   for v in [Vector3(a.x,0,a.y),Vector3(b.x,height,b.y),Vector3(b.x,0,b.y),Vector3(a.x,0,a.y),Vector3(a.x,height,a.y),Vector3(b.x,height,b.y)]: surface.add_vertex(v)
  surface.generate_normals()
  var mesh := MeshInstance3D.new()
  mesh.mesh = surface.commit()
  mesh.material_override = building_material
  root.add_child(mesh)
  mesh.create_trimesh_collision()
 return root
func update_stream():
 var center := Vector2i(floori(player.position.x/256),floori(player.position.z/256))
 if center == last_tile: return
 last_tile = center
 var wanted := {}
 for x in range(center.x-1,center.x+2):
  for z in range(center.y-1,center.y+2):
   var key := "%d_%d" % [x,z]
   if key in registry.tiles: wanted[key] = true
 for key in loaded.keys():
  if not wanted.has(key):
   for id in loaded[key]:
    residents[id].refs -= 1
    if residents[id].refs == 0:
     residents[id].node.queue_free()
     residents.erase(id)
   loaded.erase(key)
 for key in wanted:
  if loaded.has(key): continue
  var items: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/tile_%s.json"%key))
  loaded[key] = []
  for f in items:
   var id := str(f.id)
   if not residents.has(id): residents[id] = {"node":add_feature(f),"refs":0}
   residents[id].refs += 1
   loaded[key].append(id)
func _process(_delta):
 update_stream()
 status.text = "HYDERABAD: RISE OF AN EMPIRE
CHARMINAR · Geographic foundation
%d tiles · %d features · %d FPS (host only)" % [loaded.size(),residents.size(),Engine.get_frames_per_second()]
