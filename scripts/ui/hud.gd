extends CanvasLayer

@onready var coins_label: Label = $Margin/VBox/CoinsLabel
@onready var xp_label: Label = $Margin/VBox/XPLabel
@onready var selected_label: Label = $Margin/VBox/SelectedLabel
@onready var buttons: Dictionary = {
	"alface": $Margin/VBox/Shop/AlfaceButton,
	"morango": $Margin/VBox/Shop/MorangoButton,
	"trigo": $Margin/VBox/Shop/TrigoButton,
}

func _ready() -> void:
	Economy.coins_changed.connect(_on_coins_changed)
	Economy.xp_changed.connect(_on_xp_changed)
	Economy.inventory_changed.connect(_on_inventory_changed)
	Economy.selected_crop_changed.connect(_on_selected_crop_changed)

	for crop_id in buttons.keys():
		buttons[crop_id].pressed.connect(_on_buy_pressed.bind(crop_id))
		_update_button_text(crop_id)

	_on_coins_changed(Economy.coins)
	_on_xp_changed(Economy.xp)
	_on_selected_crop_changed(Economy.selected_crop)

func _on_buy_pressed(crop_id: String) -> void:
	if not Economy.buy_seed(crop_id):
		print("Moedas insuficientes para comprar semente de %s." % crop_id)

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Moedas: R$ %d" % coins

func _on_xp_changed(xp: int) -> void:
	xp_label.text = "XP: %d" % xp

func _on_inventory_changed(crop_id: String, _count: int) -> void:
	_update_button_text(crop_id)

func _on_selected_crop_changed(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	selected_label.text = "Plantando: %s" % data.name

func _update_button_text(crop_id: String) -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	var count: int = Economy.seed_inventory.get(crop_id, 0)
	buttons[crop_id].text = "%s (R$ %d) - Estoque: %d" % [data.name, data.cost, count]
