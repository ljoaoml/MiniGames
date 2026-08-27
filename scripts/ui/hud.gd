extends CanvasLayer

const VBOX_PATH := "Panel/Scroll/Margin/VBox"

@onready var coins_label: Label = get_node(VBOX_PATH + "/CoinsLabel")
@onready var level_label: Label = get_node(VBOX_PATH + "/LevelLabel")
@onready var xp_label: Label = get_node(VBOX_PATH + "/XPLabel")
@onready var area_label: Label = get_node(VBOX_PATH + "/AreaLabel")
@onready var expand_button: Button = get_node(VBOX_PATH + "/ExpandButton")
@onready var save_button: Button = get_node(VBOX_PATH + "/SaveButton")
@onready var quantity_spin: SpinBox = get_node(VBOX_PATH + "/QuantityRow/QuantitySpin")
@onready var selected_crop_label: Label = get_node(VBOX_PATH + "/SelectedCropLabel")
@onready var selected_tree_label: Label = get_node(VBOX_PATH + "/SelectedTreeLabel")
@onready var shop_crops_grid: GridContainer = get_node(VBOX_PATH + "/ShopCropsGrid")
@onready var shop_trees_grid: GridContainer = get_node(VBOX_PATH + "/ShopTreesGrid")
@onready var inventory_crops_grid: GridContainer = get_node(VBOX_PATH + "/InventoryCropsGrid")
@onready var inventory_trees_grid: GridContainer = get_node(VBOX_PATH + "/InventoryTreesGrid")
@onready var request_body: Label = get_node(VBOX_PATH + "/RequestBody")
@onready var status_label: Label = get_node(VBOX_PATH + "/StatusLabel")
@onready var tool_buttons: Dictionary = {
	"none": get_node(VBOX_PATH + "/ToolsRow/NoneButton"),
	"hoe": get_node(VBOX_PATH + "/ToolsRow/HoeButton"),
	"plant": get_node(VBOX_PATH + "/ToolsRow/PlantButton"),
	"plant_tree": get_node(VBOX_PATH + "/ToolsRow/PlantTreeButton"),
}

var shop_crop_buttons: Dictionary = {}
var shop_tree_buttons: Dictionary = {}
var inventory_crop_buttons: Dictionary = {}
var inventory_tree_buttons: Dictionary = {}

func _ready() -> void:
	Economy.coins_changed.connect(_on_coins_changed)
	Economy.xp_changed.connect(_on_xp_changed)
	Economy.inventory_changed.connect(_on_inventory_changed)
	Economy.tree_inventory_changed.connect(_on_tree_inventory_changed)
	Economy.selected_crop_changed.connect(_on_selected_crop_changed)
	Economy.selected_tree_changed.connect(_on_selected_tree_changed)
	Economy.tool_changed.connect(_on_tool_changed)
	Economy.status_message.connect(_on_status_message)
	NpcBoard.request_changed.connect(_on_request_changed)
	NpcBoard.request_completed.connect(_on_request_completed)

	for crop_id in Crops.CROPS.keys():
		var buy_button := Button.new()
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_button.pressed.connect(_on_buy_crop_pressed.bind(crop_id))
		shop_crops_grid.add_child(buy_button)
		shop_crop_buttons[crop_id] = buy_button

		var inv_button := Button.new()
		inv_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inv_button.visible = false
		inv_button.pressed.connect(_on_select_crop_pressed.bind(crop_id))
		inventory_crops_grid.add_child(inv_button)
		inventory_crop_buttons[crop_id] = inv_button

		_update_crop_buttons(crop_id)

	for tree_id in Trees.TREES.keys():
		var buy_button := Button.new()
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_button.pressed.connect(_on_buy_tree_pressed.bind(tree_id))
		shop_trees_grid.add_child(buy_button)
		shop_tree_buttons[tree_id] = buy_button

		var inv_button := Button.new()
		inv_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inv_button.visible = false
		inv_button.pressed.connect(_on_select_tree_pressed.bind(tree_id))
		inventory_trees_grid.add_child(inv_button)
		inventory_tree_buttons[tree_id] = inv_button

		_update_tree_buttons(tree_id)

	for tool_id in tool_buttons.keys():
		tool_buttons[tool_id].pressed.connect(_on_tool_pressed.bind(tool_id))

	expand_button.pressed.connect(_on_expand_pressed)
	save_button.pressed.connect(_on_save_pressed)
	World.farm_grid.expanded.connect(_on_expanded)

	_on_coins_changed(Economy.coins)
	_on_xp_changed(Economy.xp)
	_on_selected_crop_changed(Economy.selected_crop)
	_on_selected_tree_changed(Economy.selected_tree)
	_on_tool_changed(Economy.selected_tool)
	_on_request_changed()
	_update_area_label()

func _quantity() -> int:
	return int(quantity_spin.value)

func _on_buy_crop_pressed(crop_id: String) -> void:
	if not Economy.buy_seeds(crop_id, _quantity()):
		var data: Dictionary = Crops.CROPS[crop_id]
		_on_status_message("Moedas insuficientes para comprar %dx %s (R$ %d cada)." % [_quantity(), data.name, data.cost])

func _on_buy_tree_pressed(tree_id: String) -> void:
	if not Economy.buy_trees(tree_id, _quantity()):
		var data: Dictionary = Trees.TREES[tree_id]
		_on_status_message("Moedas insuficientes para comprar %dx %s (R$ %d cada)." % [_quantity(), data.name, data.cost])

func _on_select_crop_pressed(crop_id: String) -> void:
	Economy.select_crop(crop_id)

func _on_select_tree_pressed(tree_id: String) -> void:
	Economy.select_tree(tree_id)

func _on_tool_pressed(tool_id: String) -> void:
	Economy.select_tool(tool_id)

func _on_expand_pressed() -> void:
	var result: Dictionary = World.farm_grid.try_expand()
	if not result.success:
		_on_status_message(result.reason)
	else:
		_on_status_message("Área expandida!")
	_update_area_label()

func _on_expanded(_new_size: int) -> void:
	_update_area_label()

func _on_save_pressed() -> void:
	SaveManager.save_game()
	_on_status_message("Jogo salvo!")

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Moedas: R$ %d" % coins

func _on_xp_changed(xp: int) -> void:
	level_label.text = "Nível: %d" % Levels.get_level(xp)
	xp_label.text = Levels.xp_progress_text(xp)
	_update_area_label() # subir de nível pode ter liberado uma expansão

func _on_inventory_changed(crop_id: String, _count: int) -> void:
	_update_crop_buttons(crop_id)

func _on_tree_inventory_changed(tree_id: String, _count: int) -> void:
	_update_tree_buttons(tree_id)

func _on_selected_crop_changed(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	selected_crop_label.text = "Semente selecionada: %s" % data.name

func _on_selected_tree_changed(tree_id: String) -> void:
	var data: Dictionary = Trees.TREES[tree_id]
	selected_tree_label.text = "Árvore selecionada: %s" % data.name

func _on_tool_changed(tool_id: String) -> void:
	for id in tool_buttons.keys():
		tool_buttons[id].button_pressed = id == tool_id

func _on_status_message(text: String) -> void:
	status_label.text = text

func _on_request_changed() -> void:
	if NpcBoard.current_request.is_empty():
		request_body.text = "Nenhum pedido no momento."
		return
	var lines: Array = []
	for crop_id in NpcBoard.current_request.keys():
		var item: Dictionary = NpcBoard.current_request[crop_id]
		var crop_name: String = Crops.CROPS[crop_id].name
		lines.append("%s: %d/%d" % [crop_name, item.have, item.needed])
	lines.append("Recompensa: R$ %d, +%d XP" % [NpcBoard.reward_coins, NpcBoard.reward_xp])
	request_body.text = "\n".join(lines)

func _on_request_completed(reward_coins: int, reward_xp: int) -> void:
	_on_status_message("Pedido completo! +R$ %d, +%d XP" % [reward_coins, reward_xp])

func _update_crop_buttons(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	var count: int = Economy.seed_inventory.get(crop_id, 0)
	shop_crop_buttons[crop_id].text = "%s R$%d" % [data.name, data.cost]
	var inv_button: Button = inventory_crop_buttons[crop_id]
	inv_button.visible = count > 0
	inv_button.text = "%s (%d)" % [data.name, count]

func _update_tree_buttons(tree_id: String) -> void:
	var data: Dictionary = Trees.TREES[tree_id]
	var count: int = Economy.tree_inventory.get(tree_id, 0)
	shop_tree_buttons[tree_id].text = "%s R$%d" % [data.name, data.cost]
	var inv_button: Button = inventory_tree_buttons[tree_id]
	inv_button.visible = count > 0
	inv_button.text = "%s (%d)" % [data.name, count]

func _update_area_label() -> void:
	var size: int = World.farm_grid.current_size
	area_label.text = "Área: %dx%d" % [size, size]
	var info: Dictionary = World.farm_grid.get_next_expansion_info()
	if info.is_empty():
		expand_button.text = "Expandir (tamanho máximo)"
		expand_button.disabled = true
	else:
		expand_button.text = "Expandir para %dx%d (Nível %d, R$ %d)" % [info.size, info.size, info.level, info.cost]
		expand_button.disabled = false
