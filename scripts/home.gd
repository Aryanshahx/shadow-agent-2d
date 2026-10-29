extends Control
var stats: Label
var sound: AudioStreamPlayer
func box(color: Color, border: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(12)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s
func button(text: String, pos: Vector2, size_: Vector2, color: Color) -> Button:
	var b = Button.new()
	b.text = text
	b.position = pos
	b.size = size_
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_stylebox_override("normal", box(color, color.lightened(0.25)))
	b.add_theme_stylebox_override("hover", box(color.lightened(0.15), Color.WHITE))
	add_child(b)
	return b
func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color("#101b30")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var head = Label.new()
	head.text = "SHADOW AGENCY  /  OPERATIONS"
	head.position = Vector2(32, 28)
	head.add_theme_font_size_override("font_size", 27)
	head.add_theme_color_override("font_color", Color("#72efff"))
	add_child(head)
	stats = Label.new()
	stats.position = Vector2(35, 85)
	stats.add_theme_font_size_override("font_size", 18)
	add_child(stats)
	var panel = Panel.new()
	panel.position = Vector2(32, 130)
	panel.size = Vector2(768, 120)
	panel.add_theme_stylebox_override("panel", box(Color("#263754"), Color("#4c6887")))
	add_child(panel)
	var mission = Label.new()
	mission.position = Vector2(58, 150)
	mission.text = "NEXT OPERATION   /   MISSION %d\n\nEliminate guards and reach the exit." % Global.mission
	mission.add_theme_font_size_override("font_size", 19)
	add_child(mission)
	button("CHANGE AGENT", Vector2(32, 273), Vector2(370, 63), Color("#4b3c96")).pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/login.tscn"))
	button("UPGRADE ARMOR  •  25 GEMS", Vector2(415, 273), Vector2(385, 63), Color("#346d83")).pressed.connect(upgrade_armor)
	button("UPGRADE SPEED  •  25 GEMS", Vector2(415, 348), Vector2(385, 63), Color("#346d83")).pressed.connect(upgrade_speed)
	button("TEST SOUND  ♪", Vector2(32, 348), Vector2(370, 63), Color("#334866")).pressed.connect(test_sound)
	button("START MISSION %d  ▶" % Global.mission, Vector2(220, 458), Vector2(392, 70), Color("#b46d12")).pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	sound = AudioStreamPlayer.new()
	var audio_path = "res://assets/sfx/gem_pickup.wav"
	if ResourceLoader.exists(audio_path):
		sound.stream = load(audio_path)
	else:
		sound.stream = AudioStreamWAV.load_from_file(ProjectSettings.globalize_path(audio_path))
	add_child(sound)
	refresh()
func refresh() -> void:
	stats.text = "AGENT %s     ◇ %d GEMS     ARMOR %d     SPEED %d" % [Global.agent_name.to_upper(), Global.gems, Global.hp_lvl, Global.spd_lvl]
func upgrade_armor() -> void:
	if Global.gems >= 25 and Global.hp_lvl < 5:
		Global.gems -= 25
		Global.hp_lvl += 1
		Global.save_data()
		test_sound()
		refresh()
func upgrade_speed() -> void:
	if Global.gems >= 25 and Global.spd_lvl < 5:
		Global.gems -= 25
		Global.spd_lvl += 1
		Global.save_data()
		test_sound()
		refresh()
func test_sound() -> void:
	if sound.stream:
		sound.play()
