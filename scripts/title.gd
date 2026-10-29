extends Control
func _ready() -> void:
	var back = TextureRect.new()
	back.texture = load("res://assets/splash_original.png")
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(back)
	var shade = ColorRect.new()
	shade.color = Color(0.01,0.03,0.08,0.17)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var logo = Label.new()
	logo.position = Vector2(24, 100)
	logo.size = Vector2(784, 110)
	logo.text = "SHADOW AGENT"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 63)
	logo.add_theme_color_override("font_color", Color("#8ff7ff"))
	logo.add_theme_color_override("font_outline_color", Color("#03111f"))
	logo.add_theme_constant_override("outline_size", 9)
	add_child(logo)
	var enter = Button.new()
	enter.position = Vector2(205, 1220)
	enter.size = Vector2(422, 95)
	enter.text = "ENTER THE AGENCY  ▶"
	enter.add_theme_font_size_override("font_size", 28)
	enter.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/home.tscn"))
	add_child(enter)
	var footer = Label.new()
	footer.position = Vector2(100, 1385)
	footer.size = Vector2(632, 45)
	footer.text = "Hyper Tech Labs"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer.add_theme_color_override("font_color", Color("#d3ecf0"))
	add_child(footer)
