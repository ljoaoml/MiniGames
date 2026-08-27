extends Node

# Quadro de pedidos (Implementacoes extras.md): um pedido ativo por vez,
# enche sozinho conforme o jogador colhe as culturas pedidas, dá bônus ao
# completar. Recompensa é placeholder (metade do valor de venda dos itens
# pedidos) até termos balanceamento real.

signal request_changed()
signal request_completed(reward_coins: int, reward_xp: int)

var current_request: Dictionary = {}
var reward_coins: int = 0
var reward_xp: int = 0

func _ready() -> void:
	_generate_new_request()

func register_harvest(crop_id: String) -> void:
	if not current_request.has(crop_id):
		return
	current_request[crop_id].have += 1
	request_changed.emit()
	_check_completion()

func get_save_data() -> Dictionary:
	return {"current_request": current_request, "reward_coins": reward_coins, "reward_xp": reward_xp}

func load_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	current_request = data.get("current_request", {})
	reward_coins = int(data.get("reward_coins", 0))
	reward_xp = int(data.get("reward_xp", 0))
	request_changed.emit()

func _check_completion() -> void:
	for crop_id in current_request.keys():
		if current_request[crop_id].have < current_request[crop_id].needed:
			return
	Economy.coins += reward_coins
	Economy.xp += reward_xp
	Economy.coins_changed.emit(Economy.coins)
	Economy.xp_changed.emit(Economy.xp)
	request_completed.emit(reward_coins, reward_xp)
	_generate_new_request()

func _generate_new_request() -> void:
	current_request = {}
	var crop_ids: Array = Crops.CROPS.keys()
	crop_ids.shuffle()
	var num_items: int = randi_range(1, 2)
	reward_coins = 0
	for i in range(min(num_items, crop_ids.size())):
		var crop_id: String = crop_ids[i]
		var needed: int = randi_range(3, 10)
		current_request[crop_id] = {"needed": needed, "have": 0}
		reward_coins += int(Crops.CROPS[crop_id].sell_value * needed / 2.0)
	reward_xp = current_request.size() * 5
	request_changed.emit()
