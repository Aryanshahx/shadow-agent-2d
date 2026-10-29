extends Control
var wallet: Label
var info: Label
var snd: AudioStreamPlayer

func make_style(bg: Color, border: Color, radius: int = 12) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 3)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 7
	s.content_margin_bottom = 7
	return s

func label(text: String, x: float, y: float, width: float, font_size: int, tint: Color) -> Label:
	var l = Label.new()
	l.position = Vector2(x,y)
	l.size = Vector2(width, 30)
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", tint)
	l.add_theme_color_override("font_outline_color", Color("#08111c"))
	l.add_theme_constant_override("outline_size", 3)
	add_child(l)
	return l

func make_button(text: String, x: float, y: float, w: float, h: float, color: Color, edge: Color, font_size: int = 17) -> Button:
	var b = Button.new()
	b.position = Vector2(x,y)
	b.size = Vector2(w,h)
	b.text = text
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color("#10131d"))
	b.add_theme_constant_override("outline_size", 3)
	b.add_theme_stylebox_override("normal", make_style(color,edge))
	b.add_theme_stylebox_override("hover", make_style(color.lightened(0.15),edge.lightened(0.2)))
	b.add_theme_stylebox_override("pressed", make_style(color.darkened(0.2),edge))
	add_child(b)
	return b

func _ready() -> void:
	var bg = TextureRect.new()
	bg.texture = load("res://assets/menu_vault.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	var dark = ColorRect.new()
	dark.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark.color = Color(0.02,0.07,0.15,0.68)
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dark)
	# Portrait-style arrangement centered in the current landscape viewport.
	var frame = Panel.new()
	frame.position = Vector2(211, 12)
	frame.size = Vector2(410, 552)
	frame.add_theme_stylebox_override("panel",make_style(Color(0.04,0.10,0.17,0.70),Color("#365e71"),16))
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	label("SHADOW  /  AGENCY", 235, 25, 270, 18, Color("#79f2fa"))
	wallet = label("", 445, 25, 155, 17, Color("#ffe083"))
	var heading = label("OPERATIONS", 235, 71, 350, 26, Color.WHITE)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info = label("", 235, 110, 350, 14, Color("#b7d3df"))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var agent = make_button("CHANGE
AGENT", 235, 150, 226, 82, Color("#087f91"), Color("#72eaf2"), 20)
	agent.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/login.tscn"))
	var icon = TextureRect.new()
	icon.position = Vector2(373, 158)
	icon.size = Vector2(72, 70)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var image_path = "res://assets/sprites/" + Global.suit + "_0.png" if Global.suit.begins_with("hero_") else "res://assets/sprites/" + Global.suit + ".png"
	if ResourceLoader.exists(image_path):
		icon.texture = load(image_path)
	else:
		var image = Image.load_from_file(ProjectSettings.globalize_path(image_path))
		if image: icon.texture = ImageTexture.create_from_image(image)
	add_child(icon)
	var armor = make_button("ARMOR
+30 HP", 474, 150, 122, 82, Color("#9b5e11"), Color("#ffd269"), 17)
	armor.pressed.connect(buy_armor)
	var speed = make_button("UPGRADE SPEED", 235, 244, 361, 52, Color("#24415b"), Color("#668ba2"))
	speed.pressed.connect(buy_speed)
	var mission = make_button("", 235, 309, 361, 58, Color("#283d55"), Color("#628498"))
	mission.text = "CURRENT MISSION                  %d / 100" % Global.mission
	mission.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	var hints = label("ELIMINATE THE GUARDS  •  FIND THE EXIT", 246, 382, 340, 13, Color("#cde8ed"))
	hints.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var play = make_button("START MISSION  %d  ▶" % Global.mission, 254, 435, 322, 67, Color("#bd7414"), Color("#ffe082"), 23)
	play.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	var test = make_button("♪ SOUND TEST", 308, 517, 216, 30, Color("#1c3448"), Color("#4e7185"), 13)
	test.pressed.connect(test_sound)
	snd = AudioStreamPlayer.new()
	var path = "res://assets/sfx/gem_pickup.wav"
	if ResourceLoader.exists(path): snd.stream = load(path)
	elif FileAccess.file_exists(ProjectSettings.globalize_path(path)): snd.stream = AudioStreamWAV.load_from_file(ProjectSettings.globalize_path(path))
	add_child(snd)
	refresh()
	for child in get_children():
		if child is Control and child != bg and child != dark:
			child.position.y += 420

func refresh() -> void:
	wallet.text = "◇ %d" % Global.gems
	info.text = "%s    •    ARMOR %d    •    SPEED %d" % [Global.agent_name.to_upper(), Global.hp_lvl, Global.spd_lvl]

func buy_armor() -> void:
	if Global.hp_lvl >= 5:
		info.text = "ARMOR FULLY UPGRADED"
	elif Global.gems < 25:
		info.text = "ARMOR UPGRADE REQUIRES 25 GEMS"
	else:
		Global.gems -= 25
		Global.hp_lvl += 1
		Global.save_data()
		refresh()
		test_sound()

func buy_speed() -> void:
	if Global.spd_lvl >= 5:
		info.text = "SPEED FULLY UPGRADED"
	elif Global.gems < 25:
		info.text = "SPEED UPGRADE REQUIRES 25 GEMS"
	else:
		Global.gems -= 25
		Global.spd_lvl += 1
		Global.save_data()
		refresh()
		test_sound()

func test_sound() -> void:
	if snd.stream:
		snd.play()
	else:
		info.text = "SOUND FILE NOT FOUND"
