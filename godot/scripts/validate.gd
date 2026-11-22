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
 for point in [Vector3(10000,2,0),Vector3(-10000,2,0),Vector3(0,-11,55)]:
  world.player.position = point
  world.player.velocity = Vector3(3,-9,4)
  world.enforce_boundary()
  assert(world.player.position == world.SPAWN)
  assert(world.player.velocity == Vector3.ZERO)
 assert(world.recoveries == 3)
 var touch := InputEventScreenTouch.new()
 touch.index = 0
 touch.position = Vector2(20,200)
 touch.pressed = true
 world.player._input(touch)
 touch = InputEventScreenTouch.new()
 touch.index = 1
 touch.position = Vector2(1100,200)
 touch.pressed = true
 world.player._input(touch)
 assert(world.player.move_touch == 0 and world.player.look_touch == 1)
 var drag := InputEventScreenDrag.new()
 drag.index = 0
 drag.position = Vector2(100,200)
 world.player._input(drag)
 assert(world.player.stick.x>0.9)
 touch = InputEventScreenTouch.new()
 touch.index = 0
 touch.pressed = false
 world.player._input(touch)
 assert(world.player.stick == Vector2.ZERO and world.player.look_touch == 1)
 world.player._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 assert(world.player.move_touch == -1 and world.player.look_touch == -1)
 var samples: Array[float] = [1.0,2.0,3.0,100.0]
 assert(is_equal_approx(world.percentile(samples,0.95),100.0))
 print("PASS: boundary/fall recovery, zeroed velocity, synthetic multitouch ownership/release/focus reset, percentile fixture")
 print("PASS: scene load, three streaming transitions, nine-tile bound, reference counts")
 quit(0)
