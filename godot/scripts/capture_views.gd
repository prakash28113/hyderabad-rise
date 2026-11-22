extends SceneTree
func _initialize(): call_deferred("run")
func run():
 if DisplayServer.get_name() == "headless":
  push_error("Rendered captures require a graphical display; no synthetic screenshots")
  quit(2)
  return
 var label := "after"
 var args := OS.get_cmdline_user_args()
 if not args.is_empty(): label = args[0]
 assert(label in ["before","after"])
 var output := "/workspace/scratch/01d788014159/hyderabad-rise/docs/evidence/sprint15/"
 var world = load("res://main.tscn").instantiate()
 root.add_child(world)
 world.player.visible = false
 var camera := Camera3D.new()
 root.add_child(camera)
 camera.current = true
 var views: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/qa-views.json"))
 var records: Array = []
 for view in views:
  camera.position = Vector3(view.position[0],view.position[1],view.position[2])
  camera.look_at(Vector3(view.look_at[0],view.look_at[1],view.look_at[2]))
  camera.fov = view.fov_degrees
  for i in 60: await process_frame
  var intervals: Array[float] = []
  var last := Time.get_ticks_usec()
  var draws: Array[float] = []
  for i in 180:
   await process_frame
   var now := Time.get_ticks_usec()
   intervals.append((now-last)/1000.0)
   draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
   last = now
  await RenderingServer.frame_post_draw
  var result := root.get_texture().get_image().save_png(output+label+"_"+view.name+".png")
  assert(result == OK)
  intervals.sort()
  var avg := 0.0
  for value in intervals: avg += value
  records.append({"label":label,"view":view,"platform":OS.get_name(),"display_driver":DisplayServer.get_name(),"callback_interval_ms_p50":intervals[89],"callback_interval_ms_p95":intervals[170],"callback_interval_ms_p99":intervals[178],"callback_interval_ms_max":intervals[-1],"callback_rate_hz":1000.0/(avg/intervals.size()),"last_frame_draw_calls":draws[-1],"last_frame_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"engine_static_bytes":OS.get_static_memory_usage(),"scope":"Desktop rendered session; engine callback intervals, not Android presented-frame timings or PSS"})
 if label == "after" and world.get("old_city") != null:
  if world.old_city.sign_root.get_child_count()>0:
   var sign: Node3D = world.old_city.sign_root.get_child(0)
   var front: Vector3 = sign.global_basis.z.normalized()
   camera.position = sign.global_position+front*7.0
   camera.position.y = 1.7
   camera.look_at(sign.global_position)
   for i in 30: await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(output+"after_signage.png")
  if world.old_city.batches.has("auto_rickshaw"):
   var trans: Transform3D = world.old_city.batches["auto_rickshaw"].multimesh.get_instance_transform(0)
   camera.position = trans.origin+Vector3(4.0,1.7,4.0)
   camera.look_at(trans.origin+Vector3(0,0.9,0))
   for i in 30: await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(output+"after_auto.png")
 var file := FileAccess.open(output+label+"-desktop-metrics.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(records,"  "))
 print("HYD_CAPTURE_DONE ",label," ",records.size()," real rendered views")
 quit(0)
