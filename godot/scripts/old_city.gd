extends Node3D
var world: Node3D
var anchor: Dictionary
var landmark := Node3D.new()
var landmark_lods: Array[MeshInstance3D] = []
var batches := {}
var mesh_cache := {}
var sign_root := Node3D.new()
var shared_material := StandardMaterial3D.new()
var detail_count := 0
var last_lod := -1
func mesh_asset(name: String) -> Mesh:
 if mesh_cache.has(name): return mesh_cache[name]
 var packed: PackedScene = load("res://assets/%s.glb"%name)
 var temp := packed.instantiate()
 var instances := temp.find_children("*","MeshInstance3D",true,false)
 assert(not instances.is_empty(),"Asset has no mesh: "+name)
 var mesh: Mesh = instances[0].mesh
 mesh_cache[name] = mesh
 temp.free()
 return mesh
func _ready():
 shared_material.albedo_texture = load("res://assets/old_city_atlas.png")
 shared_material.roughness = 0.88
 shared_material.cull_mode = BaseMaterial3D.CULL_DISABLED
 anchor = JSON.parse_string(FileAccess.get_file_as_string("res://data/charminar-anchor.json"))
 add_child(landmark)
 landmark.position = Vector3(anchor.center_local[0],0,anchor.center_local[1])
 landmark.rotation.y = anchor.godot_yaw_radians
 for i in 3:
  var mesh := MeshInstance3D.new()
  mesh.mesh = mesh_asset("charminar_lod%d"%i)
  mesh.material_override = shared_material
  mesh.visible = i == 0
  landmark.add_child(mesh)
  landmark_lods.append(mesh)
 # Simplified collision on four piers and corner towers; central crossing remains open.
 for x in [-8.3,8.3]:
  for z in [-8.3,8.3]:
   var body := StaticBody3D.new()
   var shape := CollisionShape3D.new()
   var box := BoxShape3D.new()
   box.size = Vector3(4.5,20,4.5)
   shape.shape = box
   shape.position = Vector3(x,10,z)
   body.add_child(shape)
   var tower := CollisionShape3D.new()
   var cylinder := CylinderShape3D.new()
   cylinder.radius = 3.15
   cylinder.height = 43.0
   tower.shape = cylinder
   tower.position = Vector3(signf(x)*10.0,21.5,signf(z)*10.0)
   body.add_child(tower)
   landmark.add_child(body)
 add_child(sign_root)
func transform_at(pos: Vector3, yaw: float, scale_value: Vector3 = Vector3.ONE) -> Transform3D:
 return Transform3D(Basis(Vector3.UP,yaw).scaled(scale_value),pos)
func batch(name: String, transforms: Array):
 if transforms.is_empty(): return
 var instance := MultiMeshInstance3D.new()
 var multi := MultiMesh.new()
 multi.transform_format = MultiMesh.TRANSFORM_3D
 multi.mesh = mesh_asset(name)
 multi.instance_count = transforms.size()
 for i in transforms.size(): multi.set_instance_transform(i,transforms[i])
 instance.multimesh = multi
 instance.material_override = shared_material
 instance.visibility_range_end = 170.0 if name.begins_with("shop") else 140.0
 instance.visibility_range_end_margin = 12.0
 if name == "auto_rickshaw" or name == "market_stall":
  var collision_body := StaticBody3D.new()
  for trans in transforms:
   var shape := CollisionShape3D.new()
   var box := BoxShape3D.new()
   box.size = Vector3(1.4,1.8,2.6) if name == "auto_rickshaw" else Vector3(2.5,1.3,1.3)
   shape.shape = box
   shape.transform = trans
   shape.position.y += 0.9 if name == "auto_rickshaw" else 0.65
   collision_body.add_child(shape)
  instance.add_child(collision_body)
 add_child(instance)
 batches[name] = instance
 detail_count += transforms.size()
func rebuild(residents: Dictionary):
 for node in batches.values(): node.queue_free()
 batches.clear()
 for node in sign_root.get_children():
  sign_root.remove_child(node)
  node.queue_free()
 detail_count = 0
 var shops: Array = []
 var stalls: Array = []
 var lamps: Array = []
 var poles: Array = []
 var trees: Array = []
 var autos: Array = []
 var roads: Array = []
 var building_features: Array = []
 for resident in residents.values():
  if not resident.node.has_meta("feature"): continue
  var f: Dictionary = resident.node.get_meta("feature")
  if f.kind == "road": roads.append(f)
  elif int(f.id) != 238186115: building_features.append(f)
 building_features.sort_custom(func(a,b): return int(a.id)<int(b.id))
 for f in building_features:
  if f.tags.get("amenity","") == "place_of_worship": continue
  var points: Array = f.points
  if points.size()<4: continue
  var center := Vector2.ZERO
  var area := 0.0
  for i in points.size()-1:
   center += Vector2(points[i][0],points[i][1])
   area += Vector2(points[i][0],points[i][1]).cross(Vector2(points[i+1][0],points[i+1][1]))
  center /= points.size()-1
  if center.distance_to(Vector2(anchor.center_local[0],anchor.center_local[1]))>145: continue
  var best := INF
  var edge_a := Vector2.ZERO
  var edge_b := Vector2.ZERO
  for i in points.size()-1:
   var a := Vector2(points[i][0],points[i][1])
   var b := Vector2(points[i+1][0],points[i+1][1])
   if a.distance_to(b)<3.5: continue
   var midpoint := (a+b)*0.5
   for road in roads:
    var rp: Array = road.points
    for j in rp.size()-1:
     var nearest := Geometry2D.get_closest_point_to_segment(midpoint,Vector2(rp[j][0],rp[j][1]),Vector2(rp[j+1][0],rp[j+1][1]))
     var dist := midpoint.distance_squared_to(nearest)
     if dist<best:
      best = dist
      edge_a = a
      edge_b = b
  if best>225.0 or edge_a == edge_b: continue
  var edge := edge_b-edge_a
  var normal := Vector2(edge.y,-edge.x).normalized() * (1.0 if area>0 else -1.0)
  var midpoint := (edge_a+edge_b)*0.5
  var yaw := atan2(normal.x,normal.y)
  var count := mini(3,maxi(1,floori(edge.length()/4.0)))
  for i in count:
   if shops.size()>=80: break
   var pos := edge_a.lerp(edge_b,float(i+1)/float(count+1))
   shops.append(transform_at(Vector3(pos.x,0,pos.y),yaw))
  # Decorative props are typological art at source edges, NOT surveyed furniture positions.
  if int(f.id)%3 == 0 and stalls.size()<18:
   var pos := midpoint+normal*3.1
   if pos.length()>25: stalls.append(transform_at(Vector3(pos.x,0,pos.y),yaw))
  if int(f.id)%5 == 0 and lamps.size()<18:
   var pos := edge_a+normal*1.5
   lamps.append(transform_at(Vector3(pos.x,0,pos.y),yaw))
  if int(f.id)%9 == 0 and poles.size()<10:
   var pos := edge_b+normal*1.5
   poles.append(transform_at(Vector3(pos.x,0,pos.y),yaw))
  if int(f.id)%11 == 0 and trees.size()<9:
   var pos := edge_a-normal*1.2
   if pos.distance_to(Vector2(anchor.center_local[0],anchor.center_local[1]))>30: trees.append(transform_at(Vector3(pos.x,0,pos.y),0))
  if int(f.id)%13 == 0 and autos.size()<3:
   var pos := midpoint+normal*4.6
   if pos.length()>32: autos.append(transform_at(Vector3(pos.x,0,pos.y),yaw+PI/2))
  if sign_root.get_child_count()<5 and int(f.id)%7 == 0:
   make_sign(Vector3(midpoint.x+normal.x*1.3,5.05,midpoint.y+normal.y*1.3),yaw)
 batch("shop_lod0",shops)
 batch("shop_lod1",shops)
 if batches.has("shop_lod0"): batches["shop_lod0"].visibility_range_end = 75.0
 if batches.has("shop_lod1"): batches["shop_lod1"].visibility_range_begin = 75.0
 batch("market_stall",stalls)
 batch("street_lamp",lamps)
 batch("electrical_pole",poles)
 batch("neem_tree",trees)
 batch("auto_rickshaw",autos)
func make_sign(pos: Vector3, yaw: float):
 var root := Node3D.new()
 root.position = pos
 root.rotation.y = yaw
 sign_root.add_child(root)
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/signage.json"))
 for i in 3:
  var lang: String = ["en","te","ur"][i]
  var label := Label3D.new()
  label.text = data[lang]
  label.font = load("res://fonts/"+["NotoSans-Regular.ttf","NotoSansTelugu-Regular.ttf","NotoNaskhArabic-Regular.ttf"][i])
  label.font_size = 32
  label.pixel_size = 0.007
  label.position.y = 0.23-float(i)*.23
  label.modulate = Color("fff4c8")
  label.outline_size = 6
  if lang == "ur": label.text_direction = TextServer.DIRECTION_RTL
  root.add_child(label)
func _process(_delta):
 if world == null or world.player == null: return
 var camera := get_viewport().get_camera_3d()
 var observer: Vector3 = camera.global_position if camera != null else world.player.global_position
 var distance: float = observer.distance_to(landmark.global_position)
 var lod := 0 if distance<55 else (1 if distance<150 else 2)
 if lod == last_lod: return
 last_lod = lod
 for i in 3: landmark_lods[i].visible = i == lod
