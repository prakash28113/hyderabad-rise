extends CharacterBody3D
var yaw := 0.0
var pitch := -0.22
var stick := Vector2.ZERO
var move_touch := -1
var look_touch := -1
var touch_origin := Vector2.ZERO
var pivot: Node3D
var spring_arm: SpringArm3D
func _ready():
 var capsule := CapsuleShape3D.new()
 capsule.radius = 0.35
 capsule.height = 1.8
 var collider := CollisionShape3D.new()
 collider.shape = capsule
 collider.position.y = 0.9
 add_child(collider)
 var mesh := MeshInstance3D.new()
 var body := CapsuleMesh.new()
 body.radius = 0.35
 body.height = 1.8
 mesh.mesh = body
 mesh.position.y = 0.9
 add_child(mesh)
 pivot = Node3D.new()
 pivot.position.y = 1.6
 add_child(pivot)
 spring_arm = SpringArm3D.new()
 var arm := spring_arm
 var probe := SphereShape3D.new()
 probe.radius = 0.2
 arm.shape = probe
 arm.margin = 0.1
 arm.spring_length = 5.0
 arm.add_excluded_object(get_rid())
 pivot.add_child(arm)
 var camera := Camera3D.new()
 camera.current = true
 arm.add_child(camera)
func _input(event):
 if event is InputEventScreenTouch:
  if event.pressed:
   if event.position.x < get_viewport().get_visible_rect().size.x * 0.45 and move_touch == -1:
    move_touch = event.index
    touch_origin = event.position
   elif look_touch == -1:
    look_touch = event.index
  else:
   if event.index == move_touch:
    move_touch = -1
    stick = Vector2.ZERO
   if event.index == look_touch: look_touch = -1
 if event is InputEventScreenDrag:
  if event.index == move_touch: stick = ((event.position-touch_origin)/80.0).limit_length()
  if event.index == look_touch:
   yaw -= event.relative.x*0.004
   pitch = clamp(pitch-event.relative.y*0.004,-1.05,1.15)
 if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
  yaw -= event.relative.x*0.004
  pitch = clamp(pitch-event.relative.y*0.004,-1.05,1.15)
func _notification(what):
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
  stick = Vector2.ZERO
  move_touch = -1
  look_touch = -1
func _physics_process(delta):
 var input := stick
 input.x += float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A))
 input.y += float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W))
 var direction := Vector3(input.x,0,input.y).rotated(Vector3.UP,yaw).limit_length()
 velocity.x = direction.x*4.5
 velocity.z = direction.z*4.5
 if not is_on_floor(): velocity.y -= 18.0*delta
 else: velocity.y = 0
 update_camera()
 move_and_slide()

func update_camera():
 pivot.rotation = Vector3(pitch,yaw,0)
 # Keep the third-person camera above the ground while looking up at tall landmarks.
 spring_arm.spring_length = minf(5.0,(pivot.position.y-0.25)/maxf(sin(pitch),0.001)) if pitch>0 else 5.0
