extends CanvasLayer

@onready var coins_label: Label = $TopBar/Margin/HBox/CoinsLabel
@onready var level_label: Label = $TopBar/Margin/HBox/LevelLabel
@onready var xp_label: Label = $TopBar/Margin/HBox/XPLabel
@onready var area_label: Label = $TopBar/Margin/HBox/AreaLabel
@onready var expand_button: Button = $TopBar/Margin/HBox/ExpandButton
@onready var save_button: Button = $TopBar/Margin/HBox/SaveButton

@onready var request_label: Label = $InfoBar/Margin/VBox/RequestLabel
@onready var status_label: Label = $InfoBar/Margin/VBox/StatusLabel

@onready var tools_panel: PanelContainer = $ToolsPanel
@onready var shop_panel: PanelContainer = $ShopPanel
@onready var inventory_panel: PanelContainer = $InventoryPanel
@onready var tools_toggle: Button = $BottomBar/Margin/HBox/ToolsToggle
@onready var shop_toggle: Button = $BottomBar/Margin/HBox/ShopToggle
@onready var inventory_toggle: Button = $BottomBar/Margin/HBox/InventoryToggle

@onready var quantity_spin: SpinBox = $ShopPanel/Margin/VBox/QuantityRow/QuantitySpin
@onready var shop_crops_grid: GridContainer = $ShopPanel/Margin/VBox/ShopTabs/Sementes
@onready var shop_trees_grid: GridContainer = $ShopPanel/Margin/VBox/ShopTabs/Árvores
@onready var shop_animals_grid: GridContainer = $ShopPanel/Margin/VBox/ShopTabs/Animais

@onready var selected_label: Label = $InventoryPanel/Margin/VBox/SelectedLabel
@onready var inv_crops_grid: GridContainer = $InventoryPanel/Margin/VBox/InvTabs/Sementes
@onready var inv_trees_grid: GridContainer = $InventoryPanel/Margin/VBox/InvTabs/Árvores
@onready var inv_animals_grid: GridContainer = $InventoryPanel/Margin/VBox/InvTabs/Animais

@onready var tool_buttons: Dictionary = {
	"none": $ToolsPanel/Margin/Grid/NoneButton,
	"hoe": $ToolsPanel/Margin/Grid/HoeButton,
	"plant": $ToolsPanel/Margin/Grid/PlantButton,
	"plant_tree": $ToolsPanel/Margin/Grid/PlantTreeButton,
	"plant_animal": $ToolsPanel/Margin/Grid/PlantAnimalButton,
	"remove": $ToolsPanel/Margin/Grid/RemoveButton,
}

var shop_crop_buttons: Dictionary = {}
var shop_tree_buttons: Dictionary = {}
var shop_animal_buttons: Dictionary = {}
var inv_crop_buttons: Dictionary = {}
var inv_tree_buttons: Dictionary = {}
var inv_animal_buttons: Dictionary = {}

var open_panel: String = ""

func _ready() -> void:
	Economy.coins_changed.connect(_on_coins_changed)
	Economy.xp_changed.connect(_on_xp_changed)
	Economy.inventory_changed.connect(func(id, _c): _update_crop_buttons(id))
	Economy.tree_inventory_changed.connect(func(id, _c): _update_tree_buttons(id))
	Economy.animal_inventory_changed.connect(func(id, _c): _update_animal_buttons(id))
	Economy.selected_crop_changed.connect(func(_id): _update_selected_label())
	Economy.selected_tree_changed.connect(func(_id): _update_selected_label())
	Economy.selected_animal_changed.connect(func(_id): _update_selected_label())
	Economy.tool_changed.connect(_on_tool_changed)
	Economy.status_message.connect(_on_status_message)
	NpcBoard.request_changed.connect(_on_request_changed)
	NpcBoard.request_completed.connect(_on_request_completed)

	for crop_id in Crops.CROPS.keys():
		shop_crop_buttons[crop_id] = _make_button(shop_crops_grid, _on_buy_crop_pressed.bind(crop_id))
		inv_crop_buttons[crop_id] = _make_button(inv_crops_grid, _on_select_crop_pressed.bind(crop_id), false)
		_update_crop_buttons(crop_id)

	for tree_id in Trees.TREES.keys():
		shop_tree_buttons[tree_id] = _make_button(shop_trees_grid, _on_buy_tree_pressed.bind(tree_id))
		inv_tree_buttons[tree_id] = _make_button(inv_trees_grid, _on_select_tree_pressed.bind(tree_id), false)
		_update_tree_buttons(tree_id)

	for animal_id in Animals.ANIMALS.keys():
		shop_animal_buttons[animal_id] = _make_button(shop_animals_grid, _on_buy_animal_pressed.bind(animal_id))
		inv_animal_buttons[animal_id] = _make_button(inv_animals_grid, _on_select_animal_pressed.bind(animal_id), false)
		_update_animal_buttons(animal_id)

	for tool_id in tool_buttons.keys():
		tool_buttons[tool_id].pressed.connect(_on_tool_pressed.bind(tool_id))

	tools_toggle.pressed.connect(_on_panel_toggle.bind("tools"))
	shop_toggle.pressed.connect(_on_panel_toggle.bind("shop"))
	inventory_toggle.pressed.connect(_on_panel_toggle.bind("inventory"))

	expand_button.pressed.connect(_on_expand_pressed)
	save_button.pressed.connect(_on_save_pressed)
	World.farm_grid.expanded.connect(_on_expanded)

	_on_coins_changed(Economy.coins)
	_on_xp_changed(Economy.xp)
	_update_selected_label()
	_on_tool_changed(Economy.selected_tool)
	_on_request_changed()
	_update_area_label()
	_update_panels()

func _make_button(parent: GridContainer, callback: Callable, visible_by_default: bool = true) -> Button:
	var button := Button.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.visible = visible_by_default
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

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

func _on_buy_animal_pressed(animal_id: String) -> void:
	if not Economy.buy_animals(animal_id, _quantity()):
		var data: Dictionary = Animals.ANIMALS[animal_id]
		_on_status_message("Moedas insuficientes para comprar %dx %s (R$ %d cada)." % [_quantity(), data.name, data.cost])

func _on_select_crop_pressed(crop_id: String) -> void:
	Economy.select_crop(crop_id)

func _on_select_tree_pressed(tree_id: String) -> void:
	Economy.select_tree(tree_id)

func _on_select_animal_pressed(animal_id: String) -> void:
	Economy.select_animal(animal_id)

func _on_tool_pressed(tool_id: String) -> void:
	Economy.select_tool(tool_id)

func _on_panel_toggle(panel_name: String) -> void:
	open_panel = "" if open_panel == panel_name else panel_name
	_update_panels()

func _update_panels() -> void:
	tools_panel.visible = open_panel == "tools"
	shop_panel.visible = open_panel == "shop"
	inventory_panel.visible = open_panel == "inventory"
	tools_toggle.button_pressed = open_panel == "tools"
	shop_toggle.button_pressed = open_panel == "shop"
	inventory_toggle.button_pressed = open_panel == "inventory"

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

func _on_tool_changed(tool_id: String) -> void:
	for id in tool_buttons.keys():
		tool_buttons[id].button_pressed = id == tool_id
	_update_selected_label()

func _on_status_message(text: String) -> void:
	status_label.text = text

func _on_request_changed() -> void:
	if NpcBoard.current_request.is_empty():
		request_label.text = "Pedido: nenhum no momento."
		return
	var parts: Array = []
	for item_id in NpcBoard.current_request.keys():
		var item: Dictionary = NpcBoard.current_request[item_id]
		parts.append("%s %d/%d" % [item.name, item.have, item.needed])
	request_label.text = "Pedido: %s — Recompensa: R$ %d, +%d XP" % [", ".join(parts), NpcBoard.reward_coins, NpcBoard.reward_xp]

func _on_request_completed(reward_coins: int, reward_xp: int) -> void:
	_on_status_message("Pedido completo! +R$ %d, +%d XP" % [reward_coins, reward_xp])

func _update_selected_label() -> void:
	match Economy.selected_tool:
		"plant":
			selected_label.text = "Selecionado: %s (semente)" % Crops.CROPS[Economy.selected_crop].name
		"plant_tree":
			selected_label.text = "Selecionado: %s (árvore)" % Trees.TREES[Economy.selected_tree].name
		"plant_animal":
			selected_label.text = "Selecionado: %s (animal)" % Animals.ANIMALS[Economy.selected_animal].name
		_:
			selected_label.text = "Selecionado: -"

func _update_crop_buttons(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	var count: int = Economy.seed_inventory.get(crop_id, 0)
	shop_crop_buttons[crop_id].text = "%s R$%d" % [data.name, data.cost]
	var inv_button: Button = inv_crop_buttons[crop_id]
	inv_button.visible = count > 0
	inv_button.text = "%s (%d)" % [data.name, count]

func _update_tree_buttons(tree_id: String) -> void:
	var data: Dictionary = Trees.TREES[tree_id]
	var count: int = Economy.tree_inventory.get(tree_id, 0)
	shop_tree_buttons[tree_id].text = "%s R$%d" % [data.name, data.cost]
	var inv_button: Button = inv_tree_buttons[tree_id]
	inv_button.visible = count > 0
	inv_button.text = "%s (%d)" % [data.name, count]

func _update_animal_buttons(animal_id: String) -> void:
	var data: Dictionary = Animals.ANIMALS[animal_id]
	var count: int = Economy.animal_inventory.get(animal_id, 0)
	shop_animal_buttons[animal_id].text = "%s R$%d" % [data.name, data.cost]
	var inv_button: Button = inv_animal_buttons[animal_id]
	inv_button.visible = count > 0
	inv_button.text = "%s (%d)" % [data.name, count]

func _update_area_label() -> void:
	var size: int = World.farm_grid.current_size
	area_label.text = "Área: %dx%d" % [size, size]
	var info: Dictionary = World.farm_grid.get_next_expansion_info()
	if info.is_empty():
		expand_button.text = "Expandir (máximo)"
		expand_button.disabled = true
	else:
		expand_button.text = "Expandir p/ %dx%d (Nv %d, R$ %d)" % [info.size, info.size, info.level, info.cost]
		expand_button.disabled = false
