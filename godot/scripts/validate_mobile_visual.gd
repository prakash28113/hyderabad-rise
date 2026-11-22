extends SceneTree
func _initialize(): call_deferred("run")
func capture(name: String, output: String):
 for frame in 12: await process_frame
 await RenderingServer.frame_post_draw
 var picture := root.get_texture().get_image()
 assert(picture.get_width()>0 and picture.get_height()>0)
 assert(picture.save_png(output.path_join(name+".png"))==OK)
func run():
 if DisplayServer.get_name()=="headless":
  push_error("Graphical display required; no synthetic screenshots")
  quit(2)
  return
 var output := ProjectSettings.globalize_path("res://").path_join("../build/mobile-visuals").simplify_path()
 DirAccess.make_dir_recursive_absolute(output)
 var world = load("res://main.tscn").instantiate()
 root.add_child(world)
 for frame in 60: await process_frame
 assert(world.player.visual.visible)
 await capture("normal-camera",output)
 world.player.pitch = 0.65
 world.player.update_camera()
 assert(not world.player.visual.visible)
 await capture("look-up-no-obstruction",output)
 world.hud.credits_button.pressed.emit()
 assert(world.hud.panel.visible and not world.player.controls_enabled)
 await capture("licenses",output)
 world.hud.set_licenses_open(false)
 world.player.pitch = -0.22
 world.player.update_camera()
 root.size = Vector2i(1280,720)
 await capture("standard-landscape",output)
 # SpringArm hit length updates on physics frames, so do not inspect the
 # restored body in the same instant as changing the pitch.
 assert(world.player.controls_enabled and world.player.visual.visible)
 print("PASS: graphical camera/HUD/license states captured from actual Godot rendering; desktop only, not Android acceptance")
 quit(0)
