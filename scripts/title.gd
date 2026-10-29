extends Control
func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color("#071322")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var art = TextureRect.new()
	art.texture = load("res://assets/splash_original.png")
	art.position = Vector2.ZERO
	art.size = Vector2(832, 1479)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	var logo = TextureRect.new()
	logo.texture = load("res://assets/shadow_logo.png")
	logo.position = Vector2(58, 80)
	logo.size = Vector2(716, 380)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)
	var enter = Button.new()
	enter.position = Vector2(180, 1215)
	enter.size = Vector2(472, 106)
	enter.text = "ENTER THE AGENCY  ▶"
	enter.add_theme_font_size_override("font_size", 29)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#c27b11")
	style.border_color = Color("#ffe283")
	style.set_corner_radius_all(18)
	style.set_border_width_all(4)
	enter.add_theme_stylebox_override("normal", style)
	enter.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/home.tscn"))
	add_child(enter)
	var footer = Label.new()
	footer.position = Vector2(100, 1385)
	footer.size = Vector2(632, 45)
	footer.text = "Hyper Tech Labs"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 18)
	footer.add_theme_color_override("font_color", Color("#e4f8ff"))
	add_child(footer)
