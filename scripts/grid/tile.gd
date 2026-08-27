extends Node2D

enum State { EMPTY, TILLED, PLANTED, READY, WITHERED, INFERTILE }

const COLOR_EMPTY := Color(0.4, 0.7, 0.3)
const COLOR_TILLED := Color(0.55, 0.35, 0.15)
const COLOR_INFERTILE := Color(0.42, 0.38, 0.32)
const COLOR_PLANT_GROWING := Color(0.55, 0.75, 0.25)
const COLOR_PLANT_READY := Color(0.9, 0.85, 0.15)
const COLOR_PLANT_WITHERED := Color(0.35, 0.3, 0.25)
const COLOR_TREE_GROWING := Color(0.25, 0.5, 0.2)
const COLOR_TREE_READY := Color(0.85, 0.45, 0.15)

var state: State = State.EMPTY
var crop_id: String = ""
var is_tree: bool = false
# Horário real (Unix time) de quando o estado atual (PLANTED/READY) começou.
# Usar horário real em vez de um contador permite calcular crescimento
# mesmo com o jogo fechado, ao salvar/carregar.
var state_started_at: float = 0.0

@onready var polygon: Polygon2D = $Polygon2D
@onready var area: Area2D = $Area2D
@onready var plant: Polygon2D = $Plant

func _ready() -> void:
	area.input_event.connect(_on_area_input_event)
	_update_visual()

func _process(_delta: float) -> void:
	match state:
		State.PLANTED:
			if _elapsed() >= _growth_time():
				state = State.READY
				state_started_at += _growth_time()
			_update_visual()
		State.READY:
			if not is_tree and _elapsed() >= _growth_time():
				# Mesmo tempo de maturação como prazo pra colher antes de murchar
				# (regra descrita em Descricao do jogo.md). Árvores não murcham.
				state = State.WITHERED
				_update_visual()

func _elapsed() -> float:
	return Time.get_unix_time_from_system() - state_started_at

func _growth_time() -> float:
	if crop_id == "":
		return 0.0
	return (Trees.TREES[crop_id] if is_tree else Crops.CROPS[crop_id]).growth_time

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_apply_tool()

func _apply_tool() -> void:
	# Colher não exige ferramenta selecionada — funciona sempre que o bloco estiver pronto.
	if state == State.READY:
		_use_harvest()
		return
	match Economy.selected_tool:
		"hoe":
			_use_hoe()
		"plant":
			_use_plant()
		"plant_tree":
			_use_plant_tree()
		_:
			pass # "Mão livre": clique não faz nada, mouse fica livre pra navegar

func _use_hoe() -> void:
	if state == State.EMPTY or state == State.INFERTILE or state == State.WITHERED:
		crop_id = ""
		state = State.TILLED
		_update_visual()

func _use_plant() -> void:
	if state != State.TILLED:
		return
	var selected: String = Economy.selected_crop
	if Economy.seed_inventory.get(selected, 0) <= 0:
		Economy.emit_status("Sem sementes de %s. Compre na loja." % Crops.CROPS[selected].name)
		return
	Economy.consume_seed(selected)
	crop_id = selected
	is_tree = false
	state_started_at = Time.get_unix_time_from_system()
	state = State.PLANTED
	_update_visual()

func _use_plant_tree() -> void:
	if state != State.EMPTY:
		return
	var selected: String = Economy.selected_tree
	if Economy.tree_inventory.get(selected, 0) <= 0:
		Economy.emit_status("Sem mudas de %s. Compre na loja." % Trees.TREES[selected].name)
		return
	Economy.consume_tree(selected)
	crop_id = selected
	is_tree = true
	state_started_at = Time.get_unix_time_from_system()
	state = State.PLANTED
	_update_visual()

func _use_harvest() -> void:
	if state != State.READY:
		return
	var data: Dictionary = Trees.TREES[crop_id] if is_tree else Crops.CROPS[crop_id]
	Economy.add_harvest(data.sell_value, data.xp)
	Economy.emit_status("Colheita de %s! (+R$ %d, +%d XP)" % [data.name, data.sell_value, data.xp])
	if is_tree:
		# Árvore continua no lugar e volta a produzir depois de um tempo.
		state = State.PLANTED
		state_started_at = Time.get_unix_time_from_system()
	else:
		NpcBoard.register_harvest(crop_id)
		crop_id = ""
		# Terreno usado não volta a virar grama: fica infértil até arar de novo.
		state = State.INFERTILE
	_update_visual()

func force_till() -> void:
	state = State.TILLED
	_update_visual()

func get_save_data() -> Dictionary:
	return {
		"state": state,
		"crop_id": crop_id,
		"is_tree": is_tree,
		"state_started_at": state_started_at,
	}

func load_save_data(data: Dictionary) -> void:
	state = int(data.get("state", State.EMPTY))
	crop_id = data.get("crop_id", "")
	is_tree = data.get("is_tree", false)
	state_started_at = float(data.get("state_started_at", 0.0))
	_update_visual()

func _update_visual() -> void:
	if is_tree:
		polygon.color = COLOR_EMPTY # árvore fica plantada sobre a grama
	elif state == State.EMPTY:
		polygon.color = COLOR_EMPTY
	elif state == State.INFERTILE:
		polygon.color = COLOR_INFERTILE
	else:
		polygon.color = COLOR_TILLED

	plant.visible = state == State.PLANTED or state == State.READY or state == State.WITHERED
	match state:
		State.PLANTED:
			var progress: float = clampf(_elapsed() / _growth_time(), 0.0, 1.0)
			if is_tree:
				plant.scale = Vector2.ONE * lerp(0.3, 1.4, progress)
				plant.color = COLOR_TREE_GROWING
			else:
				plant.scale = Vector2.ONE * lerp(0.2, 1.0, progress)
				plant.color = COLOR_PLANT_GROWING
		State.READY:
			if is_tree:
				plant.scale = Vector2.ONE * 1.4
				plant.color = COLOR_TREE_READY
			else:
				plant.scale = Vector2.ONE
				plant.color = COLOR_PLANT_READY
		State.WITHERED:
			plant.scale = Vector2.ONE * 0.8
			plant.color = COLOR_PLANT_WITHERED
