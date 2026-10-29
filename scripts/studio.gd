extends Control
func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color("#070d1d")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var title = Label.new()
	title.position = Vector2(80, 216)
	title.size = Vector2(672, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "HYPER TECH LABS"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("#75ecff"))
	title.modulate.a = 0.0
	add_child(title)
	var sub = Label.new()
	sub.position = Vector2(80, 295)
	sub.size = Vector2(672, 40)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.text = "IMAGINE  •  CREATE  •  PLAY"
	sub.modulate.a = 0.0
	add_child(sub)
	var tw = create_tween()
	tw.tween_property(title, "modulate:a", 1.0, 0.8)
	tw.parallel().tween_property(sub, "modulate:a", 0.8, 1.0)
	tw.tween_interval(1.0)
	tw.tween_property(title, "modulate:a", 0.0, 0.5)
	tw.parallel().tween_property(sub, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/title.tscn"))
