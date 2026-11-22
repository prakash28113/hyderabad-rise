extends Node3D
const OldCity = preload("res://scripts/old_city.gd")
var old_city: Node3D
var building_batch: MeshInstance3D
var road_batch: Node3D
var sidewalk_material := StandardMaterial3D.new()
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
 sidewalk_material.albedo_color = Color("bdb8a8")
 var light := DirectionalLight3D.new()
 light.rotation_degrees = Vector3(-48,-32,0)
 light.light_color = Color("fff1d1")
 light.light_energy = 0.72
 light.shadow_enabled = false # Default mobile preset; high-shadow experiment failed desktop budget.
 light.directional_shadow_max_distance = 100.0
 add_child(light)
 var env := WorldEnvironment.new()
 env.environment = Environment.new()
 env.environment.background_mode = Environment.BG_COLOR
 env.environment.background_mode = Environment.BG_SKY
 var sky := Sky.new()
 var sky_material := ProceduralSkyMaterial.new()
 sky_material.sky_top_color = Color("5c9dc6")
 sky_material.sky_horizon_color = Color("e5d6b7")
 sky_material.ground_horizon_color = Color("c2b79e")
 sky.sky_material = sky_material
 env.environment.sky = sky
 env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.environment.ambient_light_color = Color.WHITE
 env.environment.ambient_light_energy = 0.32
 add_child(env)
 box(self,Vector3(0,-1,0),Vector3(2200,2,2200),Color("b6aa91"),true)
 player = Player.new()
 player.position = SPAWN
 add_child(player)
 var canvas := CanvasLayer.new()
 add_child(canvas)
 status = Label.new()
 status.position = Vector2(20,20)
 status.add_theme_font_size_override("font_size",20)
 canvas.add_child(status)
 var footer := ColorRect.new()
 footer.color = Color(0.04,0.06,0.07,0.85)
 footer.position = Vector2(10,580)
 footer.size = Vector2(990,125)
 footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
 canvas.add_child(footer)
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
 text.text = FileAccess.get_file_as_string("res://data/ASSET_CREDITS.txt") + "\n" + FileAccess.get_file_as_string("res://data/FONT-LICENSE.txt") + "\n" + "Map data © OpenStreetMap contributors, ODbL 1.0\nhttps://www.openstreetmap.org/copyright\nCorresponding geographic database is supplied with this prototype source package.\n\n" + FileAccess.get_file_as_string("res://data/ODbL-1.0.html") + "\n\n" + FileAccess.get_file_as_string("res://data/GODOT_LICENSE.txt") + "\n" + FileAccess.get_file_as_string("res://data/GODOT_COPYRIGHT.txt")
 panel.add_child(text)
 credits_button.pressed.connect(func(): panel.visible = not panel.visible)
 old_city = OldCity.new()
 old_city.world = self
 add_child(old_city)
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
 root.set_meta("feature",f)
 if int(f.id) == 238186115: return root
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
  var widths := {"primary":10.0,"secondary":8.0,"tertiary":7.0,"residential":6.0,"pedestrian":8.0,"footway":3.0,"path":2.0,"steps":2.0,"service":4.0}
  var width: float = widths.get(f.tags.get("highway",""),5.0)
  var source_width := str(f.tags.get("width","")).split(" ")[0]
  if source_width.is_valid_float(): width = clampf(source_width.to_float(),1.0,30.0)
  var road_transforms: Array[Transform3D] = []
  var sidewalk_transforms: Array[Transform3D] = []
  for i in range(points.size()-1):
   var a := Vector3(points[i][0],0.025,points[i][1])
   var b := Vector3(points[i+1][0],0.025,points[i+1][1])
   var length := a.distance_to(b)
   if length<0.01: continue
   var basis := Basis.looking_at(b-a,Vector3.UP)
   road_transforms.append(Transform3D((basis*Basis.from_scale(Vector3(width,0.04,length))),(a+b)*0.5))
   var side := Vector3((b-a).z,0,-(b-a).x).normalized()
   if ((a+b)*.5).length()>26.0:
    for sign_value in [-1.0,1.0]:
     var pos: Vector3 = (a+b)*0.5+side*(width*.5+.5)*sign_value
     pos.y = 0.075
     sidewalk_transforms.append(Transform3D((basis*Basis.from_scale(Vector3(1.0,0.15,length))),pos))
  road_instances(root,road_transforms,road_material)
  road_instances(root,sidewalk_transforms,sidewalk_material)
 else:
  var building_mesh := BuildingMesh.build(points)
  if building_mesh == null: return root
  var mesh := MeshInstance3D.new()
  mesh.mesh = building_mesh
  var facade_material := StandardMaterial3D.new()
  var palette := [Color("d5c2a2"),Color("bfae93"),Color("c8bea7"),Color("d4c9b5"),Color("aeb9b4"),Color("c3ad8c")]
  facade_material.albedo_color = palette[int(f.id)%palette.size()]
  mesh.material_override = facade_material
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
 rebuild_road_batches()
 rebuild_building_batches()
 if old_city != null: old_city.rebuild(residents)
 streaming_msec = (Time.get_ticks_usec()-streaming_start)/1000.0
 print("HYD_STREAM ",JSON.stringify({"tile_x":center.x,"tile_z":center.y,"tiles":loaded.size(),"features":residents.size(),"sync_update_ms":streaming_msec}))
func road_instances(parent: Node3D, transforms: Array[Transform3D], material: Material):
 if transforms.is_empty(): return
 var instance := MultiMeshInstance3D.new()
 var mesh := BoxMesh.new()
 mesh.size = Vector3.ONE
 var multi := MultiMesh.new()
 multi.transform_format = MultiMesh.TRANSFORM_3D
 multi.mesh = mesh
 multi.instance_count = transforms.size()
 for i in transforms.size(): multi.set_instance_transform(i,transforms[i])
 instance.multimesh = multi
 instance.set_meta("cpu_transforms",transforms)
 instance.material_override = material
 instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(instance)
func rebuild_road_batches():
 if road_batch != null:
  remove_child(road_batch)
  road_batch.queue_free()
 road_batch = Node3D.new()
 add_child(road_batch)
 var road_transforms: Array[Transform3D] = []
 var sidewalk_transforms: Array[Transform3D] = []
 for resident in residents.values():
  var root: Node3D = resident.node
  if not root.has_meta("feature") or root.get_meta("feature").kind != "road": continue
  for child in root.get_children():
   if child is MultiMeshInstance3D:
    child.visible = false
    if child.material_override == road_material: road_transforms.append_array(child.get_meta("cpu_transforms"))
    else: sidewalk_transforms.append_array(child.get_meta("cpu_transforms"))
 road_instances(road_batch,road_transforms,road_material)
 road_instances(road_batch,sidewalk_transforms,sidewalk_material)
func rebuild_building_batches():
 if building_batch != null:
  remove_child(building_batch)
  building_batch.queue_free()
 building_batch = MeshInstance3D.new()
 var array_mesh := ArrayMesh.new()
 for group in 6:
  var surface := SurfaceTool.new()
  surface.begin(Mesh.PRIMITIVE_TRIANGLES)
  var count := 0
  var mat: Material
  for id in residents:
   if int(id)%6 != group: continue
   var root: Node3D = residents[id].node
   if not root.has_meta("feature") or root.get_meta("feature").kind != "building": continue
   for child in root.get_children():
    if child is MeshInstance3D:
     surface.append_from(child.mesh,0,Transform3D.IDENTITY)
     mat = child.material_override
     child.visible = false
     count += 1
  if count>0:
   surface.set_material(mat)
   surface.commit(array_mesh)
 building_batch.mesh = array_mesh
 add_child(building_batch)
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
 print("HYD_PERF ",JSON.stringify({"platform":OS.get_name(),"display_driver":DisplayServer.get_name(),"samples":frame_samples.size(),"interval_ms_p50":percentile(frame_samples,0.50),"interval_ms_p95":percentile(frame_samples,0.95),"interval_ms_p99":percentile(frame_samples,0.99),"interval_ms_max":frame_samples[-1],"engine_fps":Engine.get_frames_per_second(),"engine_static_bytes":OS.get_static_memory_usage(),"render_draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"render_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"render_video_bytes":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),"scope":"engine process callback intervals and engine allocation counter; not presented-frame GPU timings or Android PSS"}))
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
