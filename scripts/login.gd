extends Control
var cards: Array[Button] = []
var chosen: String = "hero_h0"
var names = ["VANGUARD", "VALKYRIE", "GLACIER", "ECHO", "RANGER", "MARSHAL", "MYSTIC", "PHANTOM", "SOLAR", "NOVA"]

func style(bg: Color, border: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

func _ready() -> void:
	if Global.suit.begins_with("hero_"):
		chosen = Global.suit
	var bg = ColorRect.new()
	bg.color = Color("#10172d")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root = VBoxContainer.new()
	root.position = Vector2(28, 80)
	root.size = Vector2(776, 1300)
	root.add_theme_constant_override("separation", 8)
	add_child(root)
	var heading = Label.new()
	heading.text = "AGENCY   /   SELECT YOUR AGENT"
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", Color("#67ebff"))
	root.add_child(heading)
	var info = Label.new()
	info.text = "Choose a character • New agents unlock as you progress • Mission %d" % Global.mission
	root.add_child(info)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	for i in range(10):
		var button = Button.new()
		var unlocked = Global.mission >= 1 + (i / 2) * 5
		button.custom_minimum_size = Vector2(352, 102)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = not unlocked
		button.add_theme_stylebox_override("normal", style(Color("#25344b"), Color("#50667d")))
		button.add_theme_stylebox_override("hover", style(Color("#30526b"), Color("#75ebff")))
		button.add_theme_stylebox_override("pressed", style(Color("#3b6371"), Color("#f5cb5c")))
		button.add_theme_stylebox_override("disabled", style(Color("#202533"), Color("#4a5060")))
		button.text = names[i] + ("   • SELECT" if unlocked else "   • MISSION %d" % (1 + (i / 2) * 5))
		button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var imgpath = "res://assets/sprites/hero_h%d_0.png" % i
		# load() reads Godot's imported texture in an exported APK as well as the editor.
		if ResourceLoader.exists(imgpath):
			button.icon = load(imgpath)
		else:
			var image = Image.load_from_file(ProjectSettings.globalize_path(imgpath))
			if image:
				button.icon = ImageTexture.create_from_image(image)
		button.expand_icon = true
		var code = "hero_h%d" % i
		button.pressed.connect(func():
			chosen = code
			_refresh_cards()
		)
		grid.add_child(button)
		cards.append(button)
	var deploy = Button.new()
	deploy.text = "CONFIRM AGENT  ▶"
	deploy.custom_minimum_size = Vector2(0, 48)
	deploy.add_theme_stylebox_override("normal", style(Color("#007d91"), Color("#65f2ff")))
	deploy.pressed.connect(_on_start)
	root.add_child(deploy)
	_refresh_cards()

func _refresh_cards() -> void:
	for i in range(cards.size()):
		var unlocked = Global.mission >= 1 + (i / 2) * 5
		if unlocked:
			cards[i].text = names[i] + ("   • SELECTED" if chosen == "hero_h%d" % i else "   • SELECT")

func _on_start() -> void:
	Global.suit = chosen
	Global.save_data()
	get_tree().change_scene_to_file("res://scenes/home.tscn")
