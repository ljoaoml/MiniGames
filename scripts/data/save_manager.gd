extends Node

const SAVE_PATH := "user://savegame.json"
const AUTOSAVE_INTERVAL := 10.0

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = AUTOSAVE_INTERVAL
	timer.autostart = true
	timer.timeout.connect(save_game)
	add_child(timer)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

func save_game() -> void:
	if World.farm_grid == null:
		return
	var data: Dictionary = {
		"coins": Economy.coins,
		"xp": Economy.xp,
		"seed_inventory": Economy.seed_inventory,
		"tree_inventory": Economy.tree_inventory,
		"grid": World.farm_grid.get_save_data(),
		"npc_board": NpcBoard.get_save_data(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	Economy.coins = int(parsed.get("coins", 100))
	Economy.xp = int(parsed.get("xp", 0))

	var seed_inv: Dictionary = parsed.get("seed_inventory", {})
	for crop_id in Crops.CROPS.keys():
		Economy.seed_inventory[crop_id] = int(seed_inv.get(crop_id, 0))

	var tree_inv: Dictionary = parsed.get("tree_inventory", {})
	for tree_id in Trees.TREES.keys():
		Economy.tree_inventory[tree_id] = int(tree_inv.get(tree_id, 0))

	World.farm_grid.load_save_data(parsed.get("grid", {}))
	NpcBoard.load_save_data(parsed.get("npc_board", {}))
	return true
