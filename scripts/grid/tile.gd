extends Node2D

enum State { EMPTY, TILLED, PLANTED, READY, WITHERED, INFERTILE }

const COLOR_EMPTY := Color(0.4, 0.7, 0.3)
const COLOR_TILLED := Color(0.55, 0.35, 0.15)
const COLOR_INFERTILE := Color(0.42, 0.38, 0.32)
const COLOR_PLANT_GROWING := Color(0.55, 0.75, 0.25)
const COLOR_PLANT_READY := Color(0.9, 0.85, 0.15)
const COLOR_PLANT_WITHERED := Color(0.35, 0.3, 0.25)

var state: State = State.EMPTY
var crop_id: String = ""
var growth_timer: float = 0.0

@onready var polygon: Polygon2D = $Polygon2D
@onready var area: Area2D = $Area2D
@onready var plant: Polygon2D = $Plant

func _ready() -> void:
	area.input_event.connect(_on_area_input_event)
	_update_visual()

func _process(delta: float) -> void:
	match state:
		State.PLANTED:
			growth_timer += delta
			if growth_timer >= _growth_time():
				growth_timer = 0.0
				state = State.READY
			_update_visual()
		State.READY:
			# Regra do design: mesmo tempo de maturação como prazo pra colher
			# antes de murchar (Descricao do jogo.md).
			growth_timer += delta
			if growth_timer >= _growth_time():
				state = State.WITHERED
				_update_visual()

func _growth_time() -> float:
	return Crops.CROPS[crop_id].growth_time if crop_id != "" else 0.0

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

func _handle_click() -> void:
	match state:
		State.EMPTY:
			state = State.TILLED
		State.TILLED:
			_try_plant()
		State.PLANTED:
			pass # ainda crescendo, clique não faz nada
		State.READY:
			_harvest()
		State.WITHERED:
			crop_id = ""
			state = State.INFERTILE
		State.INFERTILE:
			state = State.TILLED
	_update_visual()

func _try_plant() -> void:
	var selected: String = Economy.selected_crop
	if Economy.seed_inventory.get(selected, 0) <= 0:
		print("Sem sementes de %s. Compre na loja." % selected)
		return
	Economy.consume_seed(selected)
	crop_id = selected
	growth_timer = 0.0
	state = State.PLANTED

func _harvest() -> void:
	var data: Dictionary = Crops.CROPS[crop_id]
	Economy.add_harvest(data.sell_value, data.xp)
	print("Colheita de %s! (+R$ %d, +%d XP)" % [data.name, data.sell_value, data.xp])
	crop_id = ""
	# Terreno usado não volta a virar grama: fica infértil até arar de novo.
	state = State.INFERTILE

func _update_visual() -> void:
	if state == State.EMPTY:
		polygon.color = COLOR_EMPTY
	elif state == State.INFERTILE:
		polygon.color = COLOR_INFERTILE
	else:
		polygon.color = COLOR_TILLED

	plant.visible = state == State.PLANTED or state == State.READY or state == State.WITHERED
	match state:
		State.PLANTED:
			var progress: float = growth_timer / _growth_time()
			plant.scale = Vector2.ONE * lerp(0.2, 1.0, progress)
			plant.color = COLOR_PLANT_GROWING
		State.READY:
			plant.scale = Vector2.ONE
			plant.color = COLOR_PLANT_READY
		State.WITHERED:
			plant.scale = Vector2.ONE * 0.8
			plant.color = COLOR_PLANT_WITHERED
