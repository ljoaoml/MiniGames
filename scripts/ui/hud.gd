extends CanvasLayer

@onready var coins_label: Label = $Margin/VBox/CoinsLabel
@onready var level_label: Label = $Margin/VBox/LevelLabel
@onready var xp_label: Label = $Margin/VBox/XPLabel
@onready var area_label: Label = $Margin/VBox/AreaLabel
@onready var expand_button: Button = $Margin/VBox/ExpandButton
@onready var selected_crop_label: Label = $Margin/VBox/SelectedCropLabel
@onready var shop_row: HBoxContainer = $Margin/VBox/ShopRow
@onready var tool_buttons: Dictionary = {
	"none": $Margin/VBox/ToolsRow/NoneButton,
	"hoe": $Margin/VBox/ToolsRow/HoeButton,
	"plant": $Margin/VBox/ToolsRow/PlantButton,
	"harvest": $Margin/VBox/ToolsRow/HarvestButton,
}

var crop_buttons: Dictionary = {}

func _ready() -> void:
	Economy.coins_changed.connect(_on_coins_changed)
	Economy.xp_changed.connect(_on_xp_changed)
	Economy.inventory_changed.connect(_on_inventory_changed)
	Economy.selected_crop_changed.connect(_on_selected_crop_changed)
	Economy.tool_changed.connect(_on_tool_changed)

	for crop_id in Crops.CROPS.keys():
		var button := Button.new()
		button.pressed.connect(_on_buy_pressed.bind(crop_id))
		shop_row.add_child(button)
		crop_buttons[crop_id] = button
		_update_crop_button(crop_id)

	for tool_id in tool_buttons.keys():
		tool_buttons[tool_id].pressed.connect(_on_tool_pressed.bind(tool_id))

	expand_button.pressed.connect(_on_expand_pressed)
	World.farm_grid.expanded.connect(_on_expanded)

	_on_coins_changed(Economy.coins)
	_on_xp_changed(Economy.xp)
	_on_selected_crop_changed(Economy.selected_crop)
	_on_tool_changed(Economy.selected_tool)
	_update_area_label()

func _on_buy_pressed(crop_id: String) -> void:
	if not Economy.buy_seed(crop_id):
		print("Moedas insuficientes para comprar semente de %s." % crop_id)

func _on_tool_pressed(tool_id: String) -> void:
	Economy.select_tool(tool_id)

func _on_expand_pressed() -> void:
	var result: Dictionary = World.farm_grid.try_expand()
	if not result.success:
		print(result.reason)
	_update_area_label()

func _on_expanded(_new_size: int) -> void:
	_update_area_label()

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Moedas: R$ %d" % coins

func _on_xp_changed(xp: int) -> void:
	level_label.text = "Nível: %d" % Levels.get_level(xp)
	xp_label.text = Levels.xp_progress_text(xp)
	_update_area_label() # subir de nível pode ter liberado uma expansão

func _on_inventory_changed(crop_id: String, _count: int) -> void:
	_update_crop_button(crop_id)

func _on_selected_crop_changed(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	selected_crop_label.text = "Semente selecionada: %s" % data.name

func _on_tool_changed(tool_id: String) -> void:
	for id in tool_buttons.keys():
		tool_buttons[id].button_pressed = id == tool_id

func _update_crop_button(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	var count: int = Economy.seed_inventory.get(crop_id, 0)
	var button: Button = crop_buttons[crop_id]
	button.text = "%s (R$ %d) - Estoque: %d" % [data.name, data.cost, count]

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
