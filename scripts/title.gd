extends Control
func _ready() -> void:
	var bg = TextureRect.new()
	bg.texture = load("res://assets/splash_original.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	var shade = ColorRect.new()
	shade.color = Color(0.01, 0.03, 0.08, 0.32)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var title = Label.new()
	title.text = "SHADOW AGENT 2D"
	title.position = Vector2(30, 65)
	title.size = Vector2(772, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#eafcff"))
	title.add_theme_color_override("font_outline_color", Color("#09132a"))
	title.add_theme_constant_override("outline_size", 8)
	add_child(title)
	var sub = Label.new()
	sub.text = "ENTER THE SHADOWS"
	sub.position = Vector2(30, 145)
	sub.size = Vector2(772, 32)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color("#70f1ff"))
	add_child(sub)
	var btn = Button.new()
	btn.position = Vector2(291, 478)
	btn.size = Vector2(250, 58)
	btn.text = "ENTER AGENCY  ▶"
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/login.tscn"))
	add_child(btn)
