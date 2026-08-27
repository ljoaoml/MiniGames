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
	area.mouse_entered.connect(_on_mouse_entered)
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
			# Mesmo tempo de maturação como prazo pra colher antes de murchar
			# (regra descrita em Descricao do jogo.md).
			growth_timer += delta
			if growth_timer >= _growth_time():
				state = State.WITHERED
				_update_visual()

func _growth_time() -> float:
	return Crops.CROPS[crop_id].growth_time if crop_id != "" else 0.0

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_apply_tool()

func _on_mouse_entered() -> void:
	# Permite "arrastar" a ferramenta selecionada por vários blocos seguidos.
	if Economy.selected_tool != "none" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_apply_tool()

func _apply_tool() -> void:
	match Economy.selected_tool:
		"hoe":
			_use_hoe()
		"plant":
			_use_plant()
		"harvest":
			_use_harvest()
		_:
			pass # "Mão livre": clique não faz nada, mouse fica livre pra navegar

func _use_hoe() -> void:
	if state == State.EMPTY or state == State.INFERTILE or state == State.WITHERED:
		crop_id = ""
		growth_timer = 0.0
		state = State.TILLED
		_update_visual()

func _use_plant() -> void:
	if state != State.TILLED:
		return
	var selected: String = Economy.selected_crop
	if Economy.seed_inventory.get(selected, 0) <= 0:
		print("Sem sementes de %s. Compre na loja." % selected)
		return
	Economy.consume_seed(selected)
	crop_id = selected
	growth_timer = 0.0
	state = State.PLANTED
	_update_visual()

func _use_harvest() -> void:
	if state != State.READY:
		return
	var data: Dictionary = Crops.CROPS[crop_id]
	Economy.add_harvest(data.sell_value, data.xp)
	print("Colheita de %s! (+R$ %d, +%d XP)" % [data.name, data.sell_value, data.xp])
	crop_id = ""
	# Terreno usado não volta a virar grama: fica infértil até arar de novo.
	state = State.INFERTILE
	_update_visual()

func force_till() -> void:
	state = State.TILLED
	_update_visual()

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
