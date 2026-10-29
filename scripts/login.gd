extends Control
var id_input: LineEdit
var name_input: LineEdit
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
	root.position = Vector2(28, 18)
	root.size = Vector2(776, 540)
	root.add_theme_constant_override("separation", 8)
	add_child(root)
	var heading = Label.new()
	heading.text = "AGENCY   /   SELECT YOUR AGENT"
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", Color("#67ebff"))
	root.add_child(heading)
	var fields = HBoxContainer.new()
	fields.add_theme_constant_override("separation", 10)
	root.add_child(fields)
	id_input = LineEdit.new()
	id_input.placeholder_text = "Agency ID (local profile)"
	id_input.text = Global.login_id
	id_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fields.add_child(id_input)
	name_input = LineEdit.new()
	name_input.placeholder_text = "Agent codename"
	name_input.text = Global.agent_name
	name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fields.add_child(name_input)
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
		var img = Image.load_from_file(imgpath)
		if img:
			button.icon = ImageTexture.create_from_image(img)
			button.expand_icon = true
		var code = "hero_h%d" % i
		button.pressed.connect(func():
			chosen = code
			_refresh_cards()
		)
		grid.add_child(button)
		cards.append(button)
	var deploy = Button.new()
	deploy.text = "DEPLOY  /  MISSION %d  ▶" % Global.mission
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
	if id_input.text.strip_edges() != "": Global.login_id = id_input.text.strip_edges()
	if name_input.text.strip_edges() != "": Global.agent_name = name_input.text.strip_edges()
	Global.suit = chosen
	Global.save_data()
	get_tree().change_scene_to_file("res://scenes/home.tscn")
