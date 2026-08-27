extends Node

signal coins_changed(coins: int)
signal xp_changed(xp: int)
signal inventory_changed(crop_id: String, count: int)
signal tree_inventory_changed(tree_id: String, count: int)
signal selected_crop_changed(crop_id: String)
signal selected_tree_changed(tree_id: String)
signal tool_changed(tool_id: String)
signal status_message(text: String)

var coins: int = 100
var xp: int = 0
var seed_inventory: Dictionary = {}
var tree_inventory: Dictionary = {}
var selected_crop: String = "alface"
var selected_tree: String = "macieira"
var selected_tool: String = "none" # "none", "hoe", "plant", "plant_tree"

func _ready() -> void:
	for crop_id in Crops.CROPS.keys():
		seed_inventory[crop_id] = 0
	for tree_id in Trees.TREES.keys():
		tree_inventory[tree_id] = 0

func buy_seeds(crop_id: String, quantity: int) -> bool:
	var data: Dictionary = Crops.CROPS[crop_id]
	var total_cost: int = data.cost * quantity
	if coins < total_cost:
		return false
	coins -= total_cost
	seed_inventory[crop_id] += quantity
	coins_changed.emit(coins)
	inventory_changed.emit(crop_id, seed_inventory[crop_id])
	select_crop(crop_id)
	return true

func consume_seed(crop_id: String) -> void:
	seed_inventory[crop_id] -= 1
	inventory_changed.emit(crop_id, seed_inventory[crop_id])

func select_crop(crop_id: String) -> void:
	selected_crop = crop_id
	selected_crop_changed.emit(crop_id)
	select_tool("plant")

func buy_trees(tree_id: String, quantity: int) -> bool:
	var data: Dictionary = Trees.TREES[tree_id]
	var total_cost: int = data.cost * quantity
	if coins < total_cost:
		return false
	coins -= total_cost
	tree_inventory[tree_id] += quantity
	coins_changed.emit(coins)
	tree_inventory_changed.emit(tree_id, tree_inventory[tree_id])
	select_tree(tree_id)
	return true

func consume_tree(tree_id: String) -> void:
	tree_inventory[tree_id] -= 1
	tree_inventory_changed.emit(tree_id, tree_inventory[tree_id])

func select_tree(tree_id: String) -> void:
	selected_tree = tree_id
	selected_tree_changed.emit(tree_id)
	select_tool("plant_tree")

func add_harvest(sell_value: int, xp_gain: int) -> void:
	coins += sell_value
	xp += xp_gain
	coins_changed.emit(coins)
	xp_changed.emit(xp)

func select_tool(tool_id: String) -> void:
	selected_tool = tool_id
	tool_changed.emit(tool_id)

func emit_status(text: String) -> void:
	status_message.emit(text)
