extends SceneTree
const Buildings = preload("res://scripts/building_mesh.gd")
func _initialize():
 var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/registry.json"))
 var features := {}
 for key in registry.tiles:
  var items: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/tile_%s.json"%key))
  for f in items:
   if f.kind == "building": features[str(f.id)] = f
 var checked := 0
 var skipped := 0
 for f in features.values():
  var mesh = Buildings.build(f.points)
  if mesh == null:
   skipped += 1
   continue
  var arrays = mesh.surface_get_arrays(0)
  var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
  var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
  for i in range(0,vertices.size(),3):
   var front := -(vertices[i+1]-vertices[i]).cross(vertices[i+2]-vertices[i])
   if front.length_squared()<0.00000001: continue
   assert(front.normalized().dot(normals[i])>0.99,"Front face/normal mismatch on OSM "+str(f.id))
   if vertices[i].y>6.99 and vertices[i+1].y>6.99 and vertices[i+2].y>6.99:
    assert(normals[i].y>0.99,"Downward roof on OSM "+str(f.id))
   else: assert(absf(normals[i].y)<0.001,"Tilted wall normal")
  checked += 1
 assert(checked+skipped == 925)
 assert(skipped == 0,"Footprints could not be triangulated")
 # Both source windings must produce upward roofs with clockwise front faces.
 for points in [[[0,0],[10,0],[10,10],[0,10],[0,0]],[[0,0],[0,10],[10,10],[10,0],[0,0]]]:
  var a = Buildings.build(points).surface_get_arrays(0)
  assert(a[Mesh.ARRAY_NORMAL][0].y>0.99)
 print("PASS: ",checked," actual OSM buildings; roof/wall normals and clockwise faces; both winding fixtures; skipped=",skipped)
 quit(0)
