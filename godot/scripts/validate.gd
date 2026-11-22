extends SceneTree
func _initialize():
 call_deferred("run")
func run():
 var world = load("res://main.tscn").instantiate()
 root.add_child(world)
 await process_frame
 var initial = world.loaded.size()
 assert(initial > 0)
 for point in [Vector3(350,2,350),Vector3(-350,2,-350),Vector3(0,2,55)]:
  world.player.position = point
  world.update_stream()
  await process_frame
  assert(world.loaded.size() <= 9)
  for id in world.residents:
   var count = 0
   for key in world.loaded:
    if id in world.loaded[key]: count += 1
   assert(count == world.residents[id].refs)
 print("PASS: scene load, three streaming transitions, nine-tile bound, reference counts")
 quit(0)
