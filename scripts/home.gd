extends Control
var wallet: Label
var message: Label
var snd: AudioStreamPlayer
func style(fill: Color, edge: Color, radius: int = 18) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = edge
	s.set_border_width_all(4)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, 0.55)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 5)
	return s
func text(content: String, at: Vector2, box: Vector2, sz: int, color: Color = Color.WHITE) -> Label:
	var l = Label.new()
	l.position = at
	l.size = box
	l.text = content
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color("#101524"))
	l.add_theme_constant_override("outline_size", 5)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l
func panel(at: Vector2, box: Vector2, fill: Color, edge: Color) -> Panel:
	var p = Panel.new()
	p.position = at
	p.size = box
	p.add_theme_stylebox_override("panel", style(fill, edge))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(p)
	return p
func btn(content: String, at: Vector2, box: Vector2, fill: Color, edge: Color, sz: int) -> Button:
	var b = Button.new()
	b.position = at
	b.size = box
	b.text = content
	b.add_theme_font_size_override("font_size", sz)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color("#151322"))
	b.add_theme_constant_override("outline_size", 5)
	b.add_theme_stylebox_override("normal", style(fill, edge))
	b.add_theme_stylebox_override("hover", style(fill.lightened(0.12), edge.lightened(0.12)))
	b.add_theme_stylebox_override("pressed", style(fill.darkened(0.12), edge))
	add_child(b)
	return b
func _ready() -> void:
	var bg = ColorRect.new()
	bg.color = Color("#172641")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	# Full-width portrait layout, with no menu background image.
	panel(Vector2(30, 65), Vector2(286, 82), Color("#101926"), Color("#416878"))
	wallet = text("", Vector2(55, 81), Vector2(250, 55), 30, Color("#80f7f5"))
	panel(Vector2(342, 65), Vector2(300, 82), Color("#101926"), Color("#416878"))
	text("MISSION  %d" % Global.mission, Vector2(368, 81), Vector2(270, 55), 30, Color("#ffcf65"))
	var sound = btn("♪", Vector2(666, 64), Vector2(124, 84), Color("#34445c"), Color("#9ab0c0"), 38)
	sound.pressed.connect(test_sound)
	var top = text("SHADOW AGENCY", Vector2(33, 205), Vector2(766, 70), 41, Color("#8cf5fa"))
	top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub = text("PREPARE FOR YOUR NEXT OPERATION", Vector2(33, 276), Vector2(766, 45), 21, Color("#b9cbd7"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var choose = btn("CHANGE\nAGENT", Vector2(35, 395), Vector2(525, 170), Color("#6c38b2"), Color("#c58bef"), 33)
	choose.alignment = HORIZONTAL_ALIGNMENT_LEFT
	choose.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/login.tscn"))
	var portrait = TextureRect.new()
	portrait.position = Vector2(333, 407)
	portrait.size = Vector2(175, 145)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path = "res://assets/sprites/" + Global.suit + "_0.png" if Global.suit.begins_with("hero_") else "res://assets/sprites/" + Global.suit + ".png"
	if ResourceLoader.exists(path):
		portrait.texture = load(path)
	add_child(portrait)
	var armor = btn("UPGRADE\nARMOR", Vector2(582, 395), Vector2(215, 170), Color("#097d91"), Color("#79e4ed"), 26)
	armor.pressed.connect(upgrade_armor)
	panel(Vector2(35, 600), Vector2(762, 137), Color("#46546f"), Color("#8a9aac"))
	text("ELIMINATE THE GUARDS", Vector2(58, 621), Vector2(720, 50), 30)
	text("Clear the path to extraction", Vector2(58, 673), Vector2(700, 45), 22, Color("#c3ebf1"))
	panel(Vector2(35, 763), Vector2(762, 137), Color("#46546f"), Color("#8a9aac"))
	text("IMPROVE YOUR SPEED", Vector2(58, 783), Vector2(480, 48), 30)
	text("Permanent upgrade: 25 gems", Vector2(58, 836), Vector2(470, 40), 20, Color("#c3ebf1"))
	var speed = btn("UPGRADE", Vector2(566, 785), Vector2(207, 91), Color("#138866"), Color("#8af4a9"), 23)
	speed.pressed.connect(upgrade_speed)
	panel(Vector2(35, 926), Vector2(762, 137), Color("#46546f"), Color("#8a9aac"))
	text("REACH THE EXIT", Vector2(58, 947), Vector2(720, 50), 30)
	text("Use stealth and survive the mission", Vector2(58, 999), Vector2(700, 40), 21, Color("#c3ebf1"))
	message = text("", Vector2(40, 1090), Vector2(750, 48), 22, Color("#ffde88"))
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var start = btn("START MISSION\n%d" % Global.mission, Vector2(125, 1160), Vector2(582, 145), Color("#c68410"), Color("#ffdd71"), 38)
	start.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	var footer = text("HYPER TECH LABS", Vector2(45, 1390), Vector2(742, 36), 16, Color("#92adbc"))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	snd = AudioStreamPlayer.new()
	var sound_path = "res://assets/sfx/gem_pickup.wav"
	if ResourceLoader.exists(sound_path):
		snd.stream = load(sound_path)
	add_child(snd)
	refresh()
func refresh() -> void:
	wallet.text = "◇  %d" % Global.gems
func upgrade_armor() -> void:
	if Global.hp_lvl >= 5:
		message.text = "ARMOR IS FULLY UPGRADED"
	elif Global.gems < 25:
		message.text = "ARMOR UPGRADE NEEDS 25 GEMS"
	else:
		Global.gems -= 25
		Global.hp_lvl += 1
		Global.save_data()
		refresh()
		message.text = "ARMOR UPGRADED!"
		test_sound()
func upgrade_speed() -> void:
	if Global.spd_lvl >= 5:
		message.text = "SPEED IS FULLY UPGRADED"
	elif Global.gems < 25:
		message.text = "SPEED UPGRADE NEEDS 25 GEMS"
	else:
		Global.gems -= 25
		Global.spd_lvl += 1
		Global.save_data()
		refresh()
		message.text = "SPEED UPGRADED!"
		test_sound()
func test_sound() -> void:
	if snd and snd.stream:
		snd.play()
