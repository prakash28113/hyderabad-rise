extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var world = load("res://main.tscn").instantiate()
 root.add_child(world)
 await physics_frame
 await physics_frame
 var anchor: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/charminar-anchor.json"))
 assert(world.old_city.landmark.position.is_equal_approx(Vector3(anchor.center_local[0],0,anchor.center_local[1])))
 assert(is_equal_approx(world.old_city.landmark.rotation.y,anchor.godot_yaw_radians))
 var counts: Array[int] = []
 for lod in world.old_city.landmark_lods:
  var mesh: Mesh = lod.mesh
  var bounds := mesh.get_aabb()
  assert(absf(bounds.end.y-48.7)<0.01,"Landmark height differs from documented model parameter")
  var count := 0
  for s in mesh.get_surface_count(): count += mesh.surface_get_array_index_len(s)/3
  counts.append(count)
 assert(counts[0]>counts[1] and counts[1]>counts[2],"LOD mesh complexity did not decrease")
 assert(world.building_batch.mesh.get_surface_count()<=6)
 var checked_segments := 0
 for resident in world.residents.values():
  var node: Node3D = resident.node
  var f: Dictionary = node.get_meta("feature")
  if f.kind != "road": continue
  var visual: MultiMeshInstance3D = node.get_child(0)
  var index := 0
  for i in f.points.size()-1:
   var a := Vector3(f.points[i][0],0.025,f.points[i][1])
   var b := Vector3(f.points[i+1][0],0.025,f.points[i+1][1])
   if a.distance_to(b)<0.01: continue
   var trans: Transform3D = visual.get_meta("cpu_transforms")[index] if DisplayServer.get_name() == "headless" else visual.multimesh.get_instance_transform(index)
   var p := trans*Vector3(0,0,-.5)
   var q := trans*Vector3(0,0,.5)
   var error := minf(p.distance_to(a)+q.distance_to(b),p.distance_to(b)+q.distance_to(a))
   if error>=.002: print("ROAD_ERROR ",f.id," index ",index," error ",error," expected ",a," ",b," actual ",p," ",q," transform ",trans)
   assert(error<.002,"Rendered road endpoints displaced")
   index += 1
   checked_segments += 1
 assert(world.road_batch.get_child_count()<=2)
 assert(world.road_batch.get_child(0).multimesh.instance_count == checked_segments)
 var space: PhysicsDirectSpaceState3D = world.get_world_3d().direct_space_state
 var transform: Transform3D = world.old_city.landmark.global_transform
 var query := PhysicsRayQueryParameters3D.create(transform*Vector3(0,1.0,-14),transform*Vector3(0,1.0,14))
 assert(space.intersect_ray(query).is_empty(),"Central Charminar passage blocked")
 query = PhysicsRayQueryParameters3D.create(transform*Vector3(8.3,1.0,0),transform*Vector3(8.3,1.0,14))
 var hit := space.intersect_ray(query)
 assert(not hit.is_empty() and hit.collider.get_parent() == world.old_city.landmark,"Landmark pier collision missing")
 assert(world.old_city.batches.has("shop_lod0") and world.old_city.batches.has("shop_lod1"))
 assert(world.old_city.batches.has("auto_rickshaw"))
 print("PASS: source anchor/yaw, 48.7 m model parameter, decreasing LODs ",counts,", <=6 building surfaces, ",checked_segments," road segment endpoints (CPU transforms on headless; renderer readback on desktop), open gateway and pier collision, instanced shop LODs and auto")
 quit(0)
