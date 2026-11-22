extends Node3D
const BuildingMesh = preload("res://scripts/building_mesh.gd")
const Player = preload("res://scripts/player.gd")
var registry: Dictionary
var loaded := {}
var residents := {}
var player: CharacterBody3D
var status: Label
var last_tile := Vector2i(999,999)
var road_material := StandardMaterial3D.new()
const SPAWN := Vector3(0,2,55)
var study_bounds := Rect2()
var boot_usec := Time.get_ticks_usec()
var ready_msec := 0.0
var streaming_msec := 0.0
var last_frame_usec := 0
var frame_samples: Array[float] = []
var sample_elapsed := 0.0
var recoveries := 0
var building_material := StandardMaterial3D.new()
func _ready():
 var boundary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/study_boundary.json"))
 study_bounds = Rect2(Vector2(boundary.min[0],boundary.min[1]),Vector2(boundary.max[0]-boundary.min[0],boundary.max[1]-boundary.min[1]))
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
 player.position = SPAWN
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
 ready_msec = (Time.get_ticks_usec()-boot_usec)/1000.0
 print("HYD_READY ",JSON.stringify({"platform":OS.get_name(),"scene_ready_ms":ready_msec,"scope":"scene setup only; excludes Android activity startup"}))
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
  var building_mesh := BuildingMesh.build(points)
  if building_mesh == null: return root
  var mesh := MeshInstance3D.new()
  mesh.mesh = building_mesh
  mesh.material_override = building_material
  root.add_child(mesh)
  mesh.create_trimesh_collision()
 return root
func update_stream():
 var center := Vector2i(floori(player.position.x/256),floori(player.position.z/256))
 if center == last_tile: return
 var streaming_start := Time.get_ticks_usec()
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
 streaming_msec = (Time.get_ticks_usec()-streaming_start)/1000.0
 print("HYD_STREAM ",JSON.stringify({"tile_x":center.x,"tile_z":center.y,"tiles":loaded.size(),"features":residents.size(),"sync_update_ms":streaming_msec}))
func enforce_boundary():
 var pos := Vector2(player.position.x,player.position.z)
 if not study_bounds.has_point(pos) or player.position.y < -10.0:
  player.position = SPAWN
  player.velocity = Vector3.ZERO
  recoveries += 1
func percentile(sorted: Array[float], p: float) -> float:
 if sorted.is_empty(): return 0.0
 return sorted[clampi(ceili(p*sorted.size())-1,0,sorted.size()-1)]
func record_frame(delta: float):
 var now := Time.get_ticks_usec()
 if last_frame_usec != 0: frame_samples.append((now-last_frame_usec)/1000.0)
 last_frame_usec = now
 sample_elapsed += delta
 if sample_elapsed < 5.0: return
 if frame_samples.is_empty(): return
 frame_samples.sort()
 print("HYD_PERF ",JSON.stringify({"platform":OS.get_name(),"display_driver":DisplayServer.get_name(),"samples":frame_samples.size(),"interval_ms_p50":percentile(frame_samples,0.50),"interval_ms_p95":percentile(frame_samples,0.95),"interval_ms_p99":percentile(frame_samples,0.99),"interval_ms_max":frame_samples[-1],"engine_fps":Engine.get_frames_per_second(),"engine_static_bytes":OS.get_static_memory_usage(),"scope":"engine process callback intervals and engine allocation counter; not presented-frame GPU timings or Android PSS"}))
 frame_samples.clear()
 sample_elapsed = 0.0
func _notification(what):
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_IN:
  frame_samples.clear()
  sample_elapsed = 0.0
  last_frame_usec = 0
func _process(delta):
 enforce_boundary()
 record_frame(delta)
 update_stream()
 status.text = "HYDERABAD: RISE OF AN EMPIRE
CHARMINAR · Geographic foundation
%d tiles · %d features · %d engine FPS" % [loaded.size(),residents.size(),Engine.get_frames_per_second()]
func _unhandled_key_input(event):
 if event is InputEventKey and event.pressed and event.physical_keycode == KEY_F12 and OS.get_name() == "Linux":
  await RenderingServer.frame_post_draw
  var path := ProjectSettings.globalize_path("res://").path_join("../docs/evidence/fixes/desktop-capture.png").simplify_path()
  var result := get_viewport().get_texture().get_image().save_png(path)
  print("HYD_DESKTOP_CAPTURE ",result," ",path)
