extends Node

var login_id: String = "agent01@shadowhq.in"
var agent_name: String = "Aryan"
var suit: String = "agent_cyan"
var mission: int = 1
var gems: int = 25
var hp_lvl: int = 1
var spd_lvl: int = 1
var smokes: int = 2
var darts: int = 3

const SAVE_FILE = "user://shadow_agent_save.json"

func _ready() -> void:
	load_data()

func save_data() -> void:
	var f = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"login_id": login_id, "agent_name": agent_name, "suit": suit,
			"mission": mission, "gems": gems, "hp_lvl": hp_lvl,
			"spd_lvl": spd_lvl, "smokes": smokes, "darts": darts
		}))

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var f = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text())
	if typeof(d) == TYPE_DICTIONARY:
		login_id = d.get("login_id", login_id)
		agent_name = d.get("agent_name", agent_name)
		suit = d.get("suit", suit)
		mission = int(d.get("mission", 1))
		gems = int(d.get("gems", 25))
		hp_lvl = int(d.get("hp_lvl", 1))
		spd_lvl = int(d.get("spd_lvl", 1))
		smokes = int(d.get("smokes", 2))
		darts = int(d.get("darts", 3))
