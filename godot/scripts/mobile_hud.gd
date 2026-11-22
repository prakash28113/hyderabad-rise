extends Control
# Original vector UI; no external textures or fonts added.
var player: CharacterBody3D
var status: Label
var credits_button: Button
var panel: PanelContainer
var safe_rect := Rect2()
var last_stick := Vector2(INF,INF)
var last_touch := -2

func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 status = Label.new()
 status.mouse_filter = Control.MOUSE_FILTER_IGNORE
 status.add_theme_font_size_override("font_size",22)
 status.add_theme_color_override("font_shadow_color",Color.BLACK)
 status.add_theme_constant_override("shadow_offset_x",1)
 status.add_theme_constant_override("shadow_offset_y",2)
 add_child(status)
 credits_button = Button.new()
 credits_button.text = "© OpenStreetMap contributors · Licenses"
 credits_button.add_theme_font_size_override("font_size",20)
 add_child(credits_button)
 panel = PanelContainer.new()
 var backdrop := StyleBoxFlat.new()
 backdrop.bg_color = Color("152731")
 backdrop.content_margin_left = 12
 backdrop.content_margin_right = 12
 backdrop.content_margin_top = 12
 backdrop.content_margin_bottom = 12
 panel.add_theme_stylebox_override("panel",backdrop)
 panel.visible = false
 add_child(panel)
 var contents := VBoxContainer.new()
 panel.add_child(contents)
 var close_button := Button.new()
 close_button.text = "Close licenses · Return to game"
 close_button.custom_minimum_size.y = 64
 close_button.add_theme_font_size_override("font_size",24)
 contents.add_child(close_button)
 var text := TextEdit.new()
 text.editable = false
 text.size_flags_vertical = Control.SIZE_EXPAND_FILL
 text.add_theme_font_size_override("font_size",20)
 text.add_theme_color_override("font_color",Color("e4edf2"))
 text.add_theme_color_override("font_readonly_color",Color("e4edf2"))
 text.text = "Map data © OpenStreetMap contributors · ODbL 1.0\nhttps://www.openstreetmap.org/copyright\nSource database accompanies the project source. Heights, widths and terrain include documented estimates.\n\n"
 for file in ["ASSET_CREDITS.txt","FONT-LICENSE.txt","GODOT_LICENSE.txt","GODOT_COPYRIGHT.txt","ODbL-1.0.html"]:
  text.text += FileAccess.get_file_as_string("res://data/"+file)+"\n\n"
 contents.add_child(text)
 credits_button.pressed.connect(func(): set_licenses_open(true))
 close_button.pressed.connect(func(): set_licenses_open(false))
 get_viewport().size_changed.connect(layout_hud)
 layout_hud()

func layout_hud():
 safe_rect = Rect2(Vector2.ZERO,get_viewport_rect().size)
 if OS.has_feature("android"):
  var screen_safe := DisplayServer.get_display_safe_area()
  if screen_safe.size.x>0 and screen_safe.size.y>0:
   var mapped: Rect2 = get_viewport().get_screen_transform().affine_inverse()*Rect2(screen_safe)
   var clipped := safe_rect.intersection(mapped)
   if clipped.size.x>0 and clipped.size.y>0: safe_rect = clipped
 safe_rect = safe_rect.grow(-24.0)
 status.position = safe_rect.position
 status.size = Vector2(safe_rect.size.x-180.0,80.0)
 credits_button.size = Vector2(minf(490.0,safe_rect.size.x-350.0),56.0)
 credits_button.position = Vector2(safe_rect.get_center().x-credits_button.size.x*.5,safe_rect.end.y-credits_button.size.y)
 panel.position = safe_rect.position+Vector2(16,16)
 panel.size = safe_rect.size-Vector2(32,32)
 queue_redraw()

func set_licenses_open(open: bool):
 panel.visible = open
 player.set_controls_enabled(not open)
 credits_button.visible = not open
 status.visible = not open
 queue_redraw()

func _unhandled_key_input(event):
 if event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE and panel.visible:
  set_licenses_open(false)
  get_viewport().set_input_as_handled()

func _process(_delta):
 if player.stick!=last_stick or player.move_touch!=last_touch:
  last_stick = player.stick
  last_touch = player.move_touch
  queue_redraw()

func _draw():
 if player==null or panel==null or panel.visible: return
 var active: bool = player.move_touch>=0
 var center: Vector2 = player.touch_origin if active else Vector2(safe_rect.position.x+100,safe_rect.end.y-115)
 var ink := Color(1.0,1.0,1.0,0.65)
 draw_circle(center,76,Color(0.04,0.08,0.1,0.24))
 draw_arc(center,76,0,TAU,64,ink,2.0,true)
 draw_circle(center+player.stick*56.0,25,Color(1.0,1.0,1.0,0.7))
 var font := ThemeDB.fallback_font
 draw_string(font,center+Vector2(-25,107),"MOVE",HORIZONTAL_ALIGNMENT_LEFT,-1,20,ink)
 var look := Vector2(safe_rect.end.x-100,safe_rect.end.y-115)
 draw_arc(look,50,0,TAU,48,ink,2.0,true)
 draw_line(look+Vector2(-18,0),look+Vector2(18,0),ink,2.0,true)
 draw_line(look+Vector2(0,-18),look+Vector2(0,18),ink,2.0,true)
 draw_string(font,look+Vector2(-62,85),"DRAG TO LOOK",HORIZONTAL_ALIGNMENT_LEFT,-1,20,ink)
