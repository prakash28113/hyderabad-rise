extends RefCounted
# Original footprint coordinates are preserved; only a private traversal copy is reordered.
static func build(points: Array, height: float = 7.0) -> ArrayMesh:
 var polygon := PackedVector2Array()
 for pt in points:
  var v := Vector2(pt[0],pt[1])
  if polygon.is_empty() or not polygon[-1].is_equal_approx(v): polygon.append(v)
 if polygon.size()>1 and polygon[0].is_equal_approx(polygon[-1]): polygon.remove_at(polygon.size()-1)
 if polygon.size()<3: return null
 var area := 0.0
 for i in polygon.size(): area += polygon[i].cross(polygon[(i+1)%polygon.size()])
 if absf(area)<0.001: return null
 if area<0: polygon.reverse()
 var triangles := Geometry2D.triangulate_polygon(polygon)
 if triangles.is_empty(): return null
 var surface := SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Godot front faces are clockwise in 3D. CCW X/Z roof indices face up.
 for index in triangles:
  var pt := polygon[index]
  surface.set_normal(Vector3.UP)
  surface.add_vertex(Vector3(pt.x,height,pt.y))
 for i in polygon.size():
  var a := polygon[i]
  var b := polygon[(i+1)%polygon.size()]
  var normal := Vector3(b.y-a.y,0,a.x-b.x).normalized()
  for v in [Vector3(a.x,0,a.y),Vector3(b.x,0,b.y),Vector3(b.x,height,b.y),Vector3(a.x,0,a.y),Vector3(b.x,height,b.y),Vector3(a.x,height,a.y)]:
   surface.set_normal(normal)
   surface.add_vertex(v)
 return surface.commit()
