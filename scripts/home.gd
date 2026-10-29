extends Control
var balance: Label
var progress: Array[Label] = []
var claims: Array[Label] = []
var feedback: Label
const DARK = Color("#112c4c")

func cover(x: float,y: float,w: float,h: float,color: Color = DARK) -> ColorRect:
	var c = ColorRect.new()
	c.position = Vector2(x,y)
	c.size = Vector2(w,h)
	c.color = color
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	return c
func label_at(x: float,y: float,w: float,h: float,sz: int) -> Label:
	var l = Label.new()
	l.position = Vector2(x,y)
	l.size = Vector2(w,h)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size",sz)
	l.add_theme_color_override("font_color",Color.WHITE)
	l.add_theme_color_override("font_outline_color",Color("#06121e"))
	l.add_theme_constant_override("outline_size",4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l
func touch(x: float,y: float,w: float,h: float,call: Callable) -> void:
	var b = Button.new()
	b.position = Vector2(x,y)
	b.size = Vector2(w,h)
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.modulate = Color(1,1,1,0.001)
	b.pressed.connect(call)
	add_child(b)
func _ready() -> void:
	var backdrop = ColorRect.new()
	backdrop.color = Color("#071b38")
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var image = TextureRect.new()
	image.texture = load("res://assets/selected_home.png")
	image.set_anchors_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(image)
	# Replace the mock-up's printed currency/progress with live save data.
	cover(115,66,135,47,Color("#0a1931"))
	balance = label_at(115,61,135,55,30)
	for y in [764, 932, 1100]:
		cover(236,y,290,38,Color("#09213d"))
		progress.append(label_at(236,y-6,290,48,23))
	for y in [710, 879, 1048]:
		cover(635,y,132,60,Color("#20466e"))
		claims.append(label_at(635,y,132,60,24))
	# The mock-up's mail and shop buttons don't represent implemented features.
	cover(698,35,110,103,Color("#0b2040"))
	feedback = label_at(36,1206,760,42,19)
	touch(30,427,500,230,func(): get_tree().change_scene_to_file("res://scenes/login.tscn"))
	touch(548,427,248,230,upgrade_armor)
	touch(581,703,201,100,func(): claim(0))
	touch(581,872,201,100,func(): claim(1))
	touch(581,1041,201,100,func(): claim(2))
	touch(31,1013,525,120,upgrade_speed)
	touch(54,1215,725,202,func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	touch(285,49,71,83,func(): feedback.text = "GEMS ARE EARNED IN MISSIONS")
	touch(577,49,102,84,toggle_sound)
	refresh()
func refresh() -> void:
	balance.text = str(Global.gems)
	progress[0].text = "%d / 30" % mini(Global.guards_defeated,30)
	progress[1].text = "%d / 1" % mini(maxi(Global.mission-1,0),1)
	progress[2].text = "%d / 1" % mini(maxi(Global.spd_lvl-1,0),1)
	for i in range(3):
		claims[i].text = "CLAIMED" if Global.objective_claimed[i] else "◇ 150"
func claim(i: int) -> void:
	var ready = [Global.guards_defeated >= 30, Global.mission > 1, Global.spd_lvl > 1]
	if Global.objective_claimed[i]:
		feedback.text = "REWARD ALREADY CLAIMED"
	elif not ready[i]:
		feedback.text = "COMPLETE THIS OBJECTIVE TO CLAIM"
	else:
		Global.objective_claimed[i] = true
		Global.gems += 150
		Global.save_data()
		feedback.text = "REWARD CLAIMED: 150 GEMS"
		refresh()
func upgrade_armor() -> void:
	if Global.hp_lvl >= 5:
		feedback.text = "ARMOR MAXED"
	elif Global.gems < 25:
		feedback.text = "ARMOR UPGRADE COSTS 25 GEMS"
	else:
		Global.gems -= 25
		Global.hp_lvl += 1
		Global.save_data()
		feedback.text = "ARMOR UPGRADED"
		refresh()
func upgrade_speed() -> void:
	if Global.spd_lvl >= 5:
		feedback.text = "SPEED MAXED"
	elif Global.gems < 25:
		feedback.text = "SPEED UPGRADE COSTS 25 GEMS"
	else:
		Global.gems -= 25
		Global.spd_lvl += 1
		Global.save_data()
		feedback.text = "SPEED UPGRADED — CLAIM REWARD!"
		refresh()
func toggle_sound() -> void:
	var master = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master, not AudioServer.is_bus_mute(master))
	feedback.text = "SOUND MUTED" if AudioServer.is_bus_mute(master) else "SOUND ON"
