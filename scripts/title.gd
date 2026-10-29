extends Control
func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color("#061322")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var art = TextureRect.new()
	art.texture = load("res://assets/selected_splash.png")
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	var enter = Button.new()
	enter.position = Vector2(185, 1220)
	enter.size = Vector2(462, 100)
	enter.text = "TAP TO ENTER"
	enter.add_theme_font_size_override("font_size", 28)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.03,0.15,0.22,0.90)
	s.border_color = Color("#6aeeff")
	s.set_border_width_all(3)
	s.set_corner_radius_all(18)
	enter.add_theme_stylebox_override("normal",s)
	enter.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/home.tscn"))
	add_child(enter)
