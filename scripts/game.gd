extends Node2D

const TILE = 64
const COLS = 13
const ROWS = 9

const MAPS = [
	[
		"#############",
		"#.....#.....#",
		"#.###.#.###.#",
		"#.#.......#.#",
		"#...##.##...#",
		"#.#.......#.#",
		"#.###.#.###.#",
		"#.....#.....#",
		"#############"
	],
	[
		"#############",
		"#...#...#...#",
		"#.#.#.#.#.#.#",
		"#.#...#...#.#",
		"#...#####...#",
		"#.#.......#.#",
		"#.#.##.##.#.#",
		"#.....#.....#",
		"#############"
	],
	[
		"#############",
		"#...........#",
		"#.##.###.##.#",
		"#.##.....##.#",
		"#....###....#",
		"#.##.....##.#",
		"#.##.###.##.#",
		"#...........#",
		"#############"
	]
]

var grid: Array = []
var anim_time: float = 0.0
var attack_timer: float = 0.0
var guard_walk_time: float = 0.0
var player: CharacterBody2D
var player_path: Array[Vector2] = []
var player_hp: float = 100.0
var player_max_hp: float = 100.0
var cloak_timer: float = 0.0

var guards: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var darts: Array[Dictionary] = []
var gems: Array[Node2D] = []
var keycard_node: Node2D = null
var has_keycard: bool = true
var exit_pos: Vector2 = Vector2(736, 96)
var exit_ring: Polygon2D

var hud_label: Label
var status_label: Label
var active: bool = true

var tex_cache: Dictionary = {}
var sfx_players: Dictionary = {}

func get_tex(fname: String) -> Texture2D:
	if not tex_cache.has(fname):
		var full = ProjectSettings.globalize_path("res://assets/sprites/" + fname)
		if FileAccess.file_exists(full):
			var img = Image.load_from_file(full)
			tex_cache[fname] = ImageTexture.create_from_image(img)
		else:
			tex_cache[fname] = load("res://assets/sprites/" + fname)
	return tex_cache[fname]

func setup_sfx() -> void:
	for s in ["slash_takedown", "gem_pickup", "guard_alert", "gunshot", "smoke_bomb", "mission_clear"]:
		var p = AudioStreamPlayer.new()
		var res_p = "res://assets/sfx/" + s + ".wav"
		var full_p = ProjectSettings.globalize_path(res_p)
		if ResourceLoader.exists(res_p):
			p.stream = load(res_p)
		elif FileAccess.file_exists(full_p):
			p.stream = AudioStreamWAV.load_from_file(full_p)
		add_child(p)
		sfx_players[s] = p

func play_sfx(s: String) -> void:
	if sfx_players.has(s) and sfx_players[s].stream:
		sfx_players[s].play()

func _ready() -> void:
	setup_sfx()
	build_level(Global.mission)

func build_level(m_num: int) -> void:
	grid = MAPS[(m_num - 1) % MAPS.size()]
	var dark = CanvasModulate.new()
	dark.color = Color("#3a4668")
	add_child(dark)

	var floors: Array[Vector2] = []
	for r in range(ROWS):
		for c in range(COLS):
			var pos = Vector2(c * TILE + 32, r * TILE + 32)
			if grid[r][c] == "#":
				var wall = StaticBody2D.new()
				wall.collision_layer = 3
				wall.position = pos
				var spr = Sprite2D.new()
				spr.texture = get_tex("wall_tile.png")
				wall.add_child(spr)
				var col = CollisionShape2D.new()
				var rect = RectangleShape2D.new()
				rect.size = Vector2(TILE, TILE)
				col.shape = rect
				wall.add_child(col)
				var occ = LightOccluder2D.new()
				var poly = OccluderPolygon2D.new()
				poly.polygon = PackedVector2Array([Vector2(-32,-32), Vector2(32,-32), Vector2(32,32), Vector2(-32,32)])
				occ.occluder = poly
				wall.add_child(occ)
				add_child(wall)
			else:
				var fl = Sprite2D.new()
				fl.texture = get_tex("floor_tile.png")
				fl.position = pos
				add_child(fl)
				floors.append(pos)

	exit_pos = floors[floors.size() - 1]
	exit_ring = Polygon2D.new()
	var pts: PackedVector2Array = []
	for i in range(20):
		var a = i * TAU / 20.0
		pts.append(Vector2(cos(a), sin(a)) * 24.0)
	exit_ring.polygon = pts
	exit_ring.position = exit_pos
	exit_ring.color = Color(0.4, 0.5, 0.6, 0.45)
	add_child(exit_ring)

	player_max_hp = 100.0 + (Global.hp_lvl - 1) * 30.0
	player_hp = player_max_hp
	player = CharacterBody2D.new()
	player.position = floors[0]
	var pspr = Sprite2D.new()
	pspr.name = "AgentArt"
	if Global.suit.begins_with("hero_"):
		pspr.texture = get_tex(Global.suit + "_0.png")
		pspr.scale = Vector2(0.46, 0.46)
	else:
		pspr.texture = get_tex(Global.suit + ".png")
		pspr.scale = Vector2(0.75, 0.75)
	player.add_child(pspr)
	var pcol = CollisionShape2D.new()
	var pcir = CircleShape2D.new()
	pcir.radius = 15.0
	pcol.shape = pcir
	player.add_child(pcol)
	var pglow = PointLight2D.new()
	pglow.texture = get_tex("soft_glow.png")
	pglow.color = Color("#00e5ff")
	pglow.energy = 0.85
	pglow.texture_scale = 1.6
	player.add_child(pglow)
	add_child(player)

	var far_tiles = floors.filter(func(p): return p.distance_to(floors[0]) > 210.0)
	far_tiles.shuffle()
	if m_num >= 2 and m_num % 2 == 0 and far_tiles.size() > 2:
		has_keycard = false
		keycard_node = Sprite2D.new()
		keycard_node.texture = get_tex("gold_keycard.png")
		keycard_node.position = far_tiles.pop_back()
		add_child(keycard_node)

	var is_boss_lvl = (m_num % 5 == 0)
	var g_count = mini(7, 2 + int(m_num / 2))
	for i in range(g_count):
		if far_tiles.is_empty():
			break
		var gpos = far_tiles.pop_back()
		var wp2 = floors[randi() % floors.size()]
		var sniper = (m_num >= 3 and i % 3 == 1)
		spawn_guard(gpos, wp2, false, sniper, 1, 68.0 + mini(55, m_num * 2.5))

	if is_boss_lvl and not far_tiles.is_empty():
		var b_hp = 3 + int(m_num / 10)
		spawn_guard(far_tiles.pop_back(), Vector2(416, 288), true, false, b_hp, 78.0 + m_num)

	build_hud()

func spawn_guard(pos: Vector2, wp2: Vector2, is_boss: bool, is_sniper: bool, hp_val: int, spd: float) -> void:
	var g = CharacterBody2D.new()
	g.position = pos
	var spr = Sprite2D.new()
	spr.texture = get_tex("boss_commander.png" if is_boss else ("guard_sniper.png" if is_sniper else "guard_standard.png"))
	spr.scale = Vector2(0.72, 0.72) if is_boss else Vector2(0.75, 0.75)
	g.add_child(spr)

	var gcol = CollisionShape2D.new()
	var gcir = CircleShape2D.new()
	gcir.radius = 16.0
	gcol.shape = gcir
	g.add_child(gcol)

	var cone = PointLight2D.new()
	cone.texture = get_tex("flashlight_cone.png")
	cone.shadow_enabled = true
	cone.color = Color("#ffea00") if not is_sniper else Color("#e040fb")
	cone.energy = 1.45
	cone.texture_scale = 2.1 if is_sniper else 1.65
	g.add_child(cone)
	add_child(g)

	guards.append({
		"node": g, "light": cone, "is_boss": is_boss, "is_sniper": is_sniper,
		"hp": hp_val, "wps": [pos, wp2], "wp_i": 1, "path": [],
		"speed": spd, "vision": 250.0 if is_sniper else 185.0,
		"fov": 0.36 if is_sniper else 0.54, "shoot_cd": 0.0, "stun": 0.0, "alerted": false
	})

func build_hud() -> void:
	var cl = CanvasLayer.new()
	add_child(cl)

	var top = PanelContainer.new()
	top.position = Vector2(12, 10)
	cl.add_child(top)
	hud_label = Label.new()
	hud_label.add_theme_font_size_override("font_size", 14)
	top.add_child(hud_label)

	status_label = Label.new()
	status_label.position = Vector2(220, 48)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#ffd54f"))
	cl.add_child(status_label)

	var btn_smoke = Button.new()
	btn_smoke.text = "SMOKE (Space)"
	btn_smoke.position = Vector2(560, 520)
	btn_smoke.custom_minimum_size = Vector2(120, 42)
	btn_smoke.pressed.connect(use_smoke)
	cl.add_child(btn_smoke)

	var btn_dart = Button.new()
	btn_dart.text = "SHURIKEN (F)"
	btn_dart.position = Vector2(692, 520)
	btn_dart.custom_minimum_size = Vector2(124, 42)
	btn_dart.pressed.connect(fire_dart)
	cl.add_child(btn_dart)

	update_hud()

func update_hud() -> void:
	var task = "Step on GREEN EXIT PAD!"
	if not has_keycard:
		task = "Grab GOLD KEYCARD first!"
	elif guards.size() > 0:
		task = "Ambush %d Guard(s)!" % guards.size()
	hud_label.text = " AGENT: %s | MISSION %d/100 | HP: %d | Gems: %d | Smoke: %d | Darts: %d | %s " % [
		Global.agent_name.to_upper(), Global.mission, int(player_hp), Global.gems, Global.smokes, Global.darts, task
	]

func find_grid_path(from_p: Vector2, to_p: Vector2) -> Array[Vector2]:
	var sc = Vector2i(int(from_p.x / TILE), int(from_p.y / TILE))
	var tc = Vector2i(int(to_p.x / TILE), int(to_p.y / TILE))
	if tc.x < 0 or tc.x >= COLS or tc.y < 0 or tc.y >= ROWS or grid[tc.y][tc.x] == "#":
		return []
	var q: Array[Vector2i] = [sc]
	var came = {sc: null}
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	while not q.is_empty():
		var cur = q.pop_front()
		if cur == tc:
			break
		for d in dirs:
			var nx = cur + d
			if nx.x >= 0 and nx.x < COLS and nx.y >= 0 and nx.y < ROWS and grid[nx.y][nx.x] != "#" and not came.has(nx):
				came[nx] = cur
				q.append(nx)
	if not came.has(tc):
		return []
	var res: Array[Vector2] = []
	var step: Variant = tc
	while step != null and step != sc:
		res.push_front(Vector2(step.x * TILE + 32, step.y * TILE + 32))
		step = came[step]
	if not res.is_empty():
		res[res.size() - 1] = to_p
	return res

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		player_path = find_grid_path(player.global_position, get_global_mouse_position())
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_E:
			use_smoke()
		elif event.keycode == KEY_F:
			fire_dart()

func use_smoke() -> void:
	if not active or cloak_timer > 0.0 or Global.smokes <= 0:
		return
	Global.smokes -= 1
	Global.save_data()
	cloak_timer = 3.6
	play_sfx("smoke_bomb")
	status_label.text = "SMOKE CLOAK ACTIVE (3.6s INVISIBLE)!"
	update_hud()

func fire_dart() -> void:
	if not active or Global.darts <= 0 or guards.is_empty():
		return
	var best_g = guards[0]
	var best_d = 99999.0
	for g in guards:
		var d = g["node"].global_position.distance_to(player.global_position)
		if d < best_d:
			best_d = d
			best_g = g
	Global.darts -= 1
	Global.save_data()
	var dir = (best_g["node"].global_position - player.global_position).normalized()
	var spr = Sprite2D.new()
	spr.texture = get_tex("gem_diamond.png")
	spr.scale = Vector2(0.45, 0.45)
	spr.position = player.global_position
	add_child(spr)
	darts.append({"node": spr, "vel": dir * 460.0})
	play_sfx("slash_takedown")
	update_hud()

func has_los(a: Vector2, b: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var q = PhysicsRayQueryParameters2D.create(a, b, 2)
	var hit = space.intersect_ray(q)
	return hit.is_empty()

func _physics_process(delta: float) -> void:
	if not active:
		return

	if cloak_timer > 0.0:
		cloak_timer -= delta
		player.modulate.a = 0.4
		if cloak_timer <= 0.0:
			player.modulate.a = 1.0
			status_label.text = ""

	var spd = 190.0 + (Global.spd_lvl - 1) * 20.0
	var kb = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if kb.length() > 0.1:
		player_path.clear()
		player.velocity = kb * spd
		player.rotation = kb.angle()
		player.move_and_slide()
	elif not player_path.is_empty():
		var wp = player_path[0]
		var diff = wp - player.global_position
		if diff.length() < 9.0:
			player_path.pop_front()
		else:
			player.velocity = diff.normalized() * spd
			player.rotation = diff.angle()
			player.move_and_slide()

	if Global.suit.begins_with("hero_"):
		anim_time += delta
		attack_timer = maxf(0.0, attack_timer - delta)
		var frame: int = 0
		if attack_timer > 0.0:
			frame = 3
		elif kb.length() > 0.1 or not player_path.is_empty():
			frame = 1 + (int(anim_time * 7.0) % 2)
		var art = player.get_node_or_null("AgentArt") as Sprite2D
		if art:
			art.texture = get_tex(Global.suit + "_" + str(frame) + ".png")

	if not has_keycard and keycard_node and player.global_position.distance_to(keycard_node.global_position) < 30.0:
		has_keycard = true
		keycard_node.queue_free()
		keycard_node = null
		play_sfx("gem_pickup")
		status_label.text = "GOLD KEYCARD COLLECTED!"
		update_hud()

	guard_walk_time += delta
	for i in range(guards.size() - 1, -1, -1):
		var g = guards[i]
		var gnode: CharacterBody2D = g["node"]
		if g["stun"] > 0.0:
			g["stun"] -= delta
			continue

		var to_p = player.global_position - gnode.global_position
		var sees = false
		if cloak_timer <= 0.0 and to_p.length() < g["vision"]:
			var ang_diff = abs(angle_difference(gnode.rotation, to_p.angle()))
			if ang_diff <= g["fov"] and has_los(gnode.global_position, player.global_position):
				sees = true

		if not g.has("pursue_time"):
			g["pursue_time"] = 0.0
			g["chase_update"] = 0.0
			g["last_seen"] = player.global_position
		if sees:
			g["pursue_time"] = 4.0
			g["last_seen"] = player.global_position
		else:
			g["pursue_time"] = maxf(0.0, g["pursue_time"] - delta)
		if sees:
			if not g["alerted"]:
				g["alerted"] = true
				play_sfx("guard_alert")
			g["light"].color = Color("#ff1744")
			gnode.rotation = lerp_angle(gnode.rotation, to_p.angle(), 9.0 * delta)
			if to_p.length() > 100.0:
				gnode.velocity = to_p.normalized() * g["speed"]
				gnode.move_and_slide()
			g["shoot_cd"] -= delta
			if g["shoot_cd"] <= 0.0:
				g["shoot_cd"] = 0.42 if g["is_boss"] else 0.65
				play_sfx("gunshot")
				var b = Polygon2D.new()
				b.polygon = PackedVector2Array([Vector2(-4,-4), Vector2(4,-4), Vector2(4,4), Vector2(-4,4)])
				b.color = Color("#ffeb3b")
				b.position = gnode.global_position + Vector2.RIGHT.rotated(gnode.rotation) * 20.0
				add_child(b)
				bullets.append({"node": b, "vel": Vector2.RIGHT.rotated(gnode.rotation) * 360.0, "dmg": 20.0 if g["is_boss"] else 15.0})
		elif g["pursue_time"] > 0.0:
			g["light"].color = Color("#ff1744")
			g["chase_update"] -= delta
			if g["chase_update"] <= 0.0:
				g["chase_update"] = 0.4
				g["path"] = find_grid_path(gnode.global_position, g["last_seen"])
			var chase_path = g["path"]
			if not chase_path.is_empty():
				var chase_dir: Vector2 = chase_path[0] - gnode.global_position
				if chase_dir.length() < 9.0:
					chase_path.pop_front()
				else:
					gnode.rotation = lerp_angle(gnode.rotation, chase_dir.angle(), 8.0 * delta)
					gnode.velocity = chase_dir.normalized() * g["speed"] * 1.2
					gnode.move_and_slide()
		else:
			g["alerted"] = false
			g["light"].color = Color("#e040fb") if g["is_sniper"] else Color("#ffea00")
			var gp = g["path"]
			if gp.is_empty():
				var goal = g["wps"][g["wp_i"]]
				g["path"] = find_grid_path(gnode.global_position, goal)
				g["wp_i"] = (g["wp_i"] + 1) % g["wps"].size()
				# If the selected waypoint cannot be reached, patrol a nearby open tile instead.
				if g["path"].is_empty():
					var cell = Vector2i(int(gnode.global_position.x / TILE), int(gnode.global_position.y / TILE))
					var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
					directions.shuffle()
					for direction in directions:
						var neighbor: Vector2i = cell + direction
						if neighbor.x >= 0 and neighbor.x < COLS and neighbor.y >= 0 and neighbor.y < ROWS and grid[neighbor.y][neighbor.x] != "#":
							var nearby: Vector2 = Vector2(neighbor.x * TILE + 32, neighbor.y * TILE + 32)
							g["path"] = find_grid_path(gnode.global_position, nearby)
							if not g["path"].is_empty():
								break
			else:
				var d = gp[0] - gnode.global_position
				if d.length() < 9.0:
					gp.pop_front()
				else:
					gnode.rotation = lerp_angle(gnode.rotation, d.angle(), 6.0 * delta)
					gnode.velocity = d.normalized() * g["speed"]
					gnode.move_and_slide()

		# A small animated bob when walking; this is not yet full sprite animation.
		var guard_art = gnode.get_child(0) as Sprite2D
		if guard_art:
			var base_scale: float = 0.72 if g["is_boss"] else 0.75
			if not sees and not g["path"].is_empty():
				guard_art.scale = Vector2(base_scale, base_scale * (1.0 + 0.07 * sin(guard_walk_time * 10.0 + i)))
			else:
				guard_art.scale = Vector2(base_scale, base_scale)

		if player.global_position.distance_to(gnode.global_position) < (38.0 if g["is_boss"] else 32.0):
			var front_hit = g["is_boss"] and cloak_timer <= 0.0 and abs(angle_difference(gnode.rotation, to_p.angle())) < 0.8
			if front_hit:
				player_hp -= 12.0
				player.global_position += to_p.normalized() * 36.0
				status_label.text = "BOSS FRONT SHIELD! Flank BEHIND his back!"
				update_hud()
				if player_hp <= 0.0:
					finish_mission(false)
					return
			else:
				damage_guard(i)

	for i in range(darts.size() - 1, -1, -1):
		var d = darts[i]
		d["node"].position += d["vel"] * delta
		d["node"].rotation += 15.0 * delta
		var p = d["node"].position
		var gc = int(p.x / TILE)
		var gr = int(p.y / TILE)
		if gc < 0 or gc >= COLS or gr < 0 or gr >= ROWS or grid[gr][gc] == "#":
			d["node"].queue_free()
			darts.remove_at(i)
			continue
		for j in range(guards.size() - 1, -1, -1):
			if p.distance_to(guards[j]["node"].global_position) < 28.0:
				damage_guard(j)
				d["node"].queue_free()
				darts.remove_at(i)
				break

	for i in range(bullets.size() - 1, -1, -1):
		var b = bullets[i]
		b["node"].position += b["vel"] * delta
		var p = b["node"].position
		var gc = int(p.x / TILE)
		var gr = int(p.y / TILE)
		if gc < 0 or gc >= COLS or gr < 0 or gr >= ROWS or grid[gr][gc] == "#":
			b["node"].queue_free()
			bullets.remove_at(i)
			continue
		if cloak_timer <= 0.0 and p.distance_to(player.global_position) < 17.0:
			player_hp -= b["dmg"]
			b["node"].queue_free()
			bullets.remove_at(i)
			update_hud()
			if player_hp <= 0.0:
				finish_mission(false)
				return

	for i in range(gems.size() - 1, -1, -1):
		if gems[i].global_position.distance_to(player.global_position) < 32.0:
			Global.gems += 2
			Global.save_data()
			play_sfx("gem_pickup")
			gems[i].queue_free()
			gems.remove_at(i)
			update_hud()

	var open_now = guards.is_empty() and has_keycard
	exit_ring.color = Color("#00e676") if open_now else Color(0.4, 0.5, 0.6, 0.45)
	if open_now and player.global_position.distance_to(exit_pos) < 30.0:
		finish_mission(true)

func damage_guard(idx: int) -> void:
	attack_timer = 0.20
	var g = guards[idx]
	g["hp"] -= 1
	g["stun"] = 1.0
	play_sfx("slash_takedown")
	if g["hp"] <= 0:
		var pos = g["node"].global_position
		for k in range(4 if g["is_boss"] else 2):
			var gm = Sprite2D.new()
			gm.texture = get_tex("gem_diamond.png")
			gm.scale = Vector2(0.6, 0.6)
			gm.position = pos + Vector2(randf_range(-18, 18), randf_range(-18, 18))
			add_child(gm)
			gems.append(gm)
		g["node"].queue_free()
		guards.remove_at(idx)
		status_label.text = "SILENT TAKEDOWN!"
	else:
		status_label.text = "BOSS ARMOR HIT! (%d HP LEFT)" % g["hp"]
	update_hud()

func finish_mission(won: bool) -> void:
	active = false
	if won:
		play_sfx("mission_clear")
		Global.gems += 10 + Global.mission * 2
		Global.mission = mini(100, Global.mission + 1)
		Global.save_data()

	var cl = CanvasLayer.new()
	add_child(cl)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 320)
	panel.position = Vector2(206, 128)
	cl.add_child(panel)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)

	var t = Label.new()
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 22)
	t.text = ("MISSION CLEARED! -> LVL %d" % Global.mission) if won else "SPOTTED! MISSION FAILED"
	t.add_theme_color_override("font_color", Color("#00e676") if won else Color("#ff5252"))
	vb.add_child(t)

	var wallet = Label.new()
	wallet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(wallet)

	var refresh_wallet = func():
		wallet.text = "Gems Wallet: %d  |  Armor Lv.%d  |  Speed Lv.%d" % [Global.gems, Global.hp_lvl, Global.spd_lvl]
	refresh_wallet.call()

	var b_hp = Button.new()
	b_hp.text = "Upgrade Armor (+30 HP) — Cost: 25 Gems"
	b_hp.pressed.connect(func():
		if Global.gems >= 25 and Global.hp_lvl < 5:
			Global.gems -= 25; Global.hp_lvl += 1; Global.save_data(); refresh_wallet.call()
	)
	vb.add_child(b_hp)

	var b_spd = Button.new()
	b_spd.text = "Upgrade Boots (+Speed) — Cost: 25 Gems"
	b_spd.pressed.connect(func():
		if Global.gems >= 25 and Global.spd_lvl < 5:
			Global.gems -= 25; Global.spd_lvl += 1; Global.save_data(); refresh_wallet.call()
	)
	vb.add_child(b_spd)

	var b_items = Button.new()
	b_items.text = "Buy +1 Smoke & +2 Shurikens — Cost: 15 Gems"
	b_items.pressed.connect(func():
		if Global.gems >= 15:
			Global.gems -= 15; Global.smokes += 1; Global.darts += 2; Global.save_data(); refresh_wallet.call()
	)
	vb.add_child(b_items)

	var b_next = Button.new()
	b_next.custom_minimum_size = Vector2(0, 44)
	b_next.text = ("START MISSION %d ▶" % Global.mission) if won else "RETRY MISSION ▶"
	b_next.pressed.connect(func(): get_tree().reload_current_scene())
	vb.add_child(b_next)
