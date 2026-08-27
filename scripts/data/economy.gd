extends Node

signal coins_changed(coins: int)
signal xp_changed(xp: int)
signal inventory_changed(crop_id: String, count: int)
signal selected_crop_changed(crop_id: String)

var coins: int = 100
var xp: int = 0
var seed_inventory: Dictionary = {}
var selected_crop: String = "alface"

func _ready() -> void:
	for crop_id in Crops.CROPS.keys():
		seed_inventory[crop_id] = 0

func buy_seed(crop_id: String) -> bool:
	var data: Dictionary = Crops.CROPS[crop_id]
	if coins < data.cost:
		return false
	coins -= data.cost
	seed_inventory[crop_id] += 1
	selected_crop = crop_id
	coins_changed.emit(coins)
	inventory_changed.emit(crop_id, seed_inventory[crop_id])
	selected_crop_changed.emit(crop_id)
	return true

func consume_seed(crop_id: String) -> void:
	seed_inventory[crop_id] -= 1
	inventory_changed.emit(crop_id, seed_inventory[crop_id])

func add_harvest(sell_value: int, xp_gain: int) -> void:
	coins += sell_value
	xp += xp_gain
	coins_changed.emit(coins)
	xp_changed.emit(xp)
