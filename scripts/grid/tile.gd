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
const COLOR_ANIMAL_GROWING := Color(0.6, 0.4, 0.2)
const COLOR_ANIMAL_READY := Color(0.95, 0.7, 0.3)

# Reembolso ao remover árvore/animal com a ferramenta "Remover" (% do custo).
const REMOVE_REFUND_RATIO := 0.25

var state: State = State.EMPTY
var crop_id: String = ""
var plant_kind: String = "crop" # "crop", "tree", "animal"
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
			if plant_kind == "crop" and _elapsed() >= _growth_time():
				# Mesmo tempo de maturação como prazo pra colher antes de murchar
				# (regra descrita em Descricao do jogo.md). Árvores e animais não murcham.
				state = State.WITHERED
				_update_visual()

func _elapsed() -> float:
	return Time.get_unix_time_from_system() - state_started_at

func _data() -> Dictionary:
	if crop_id == "":
		return {}
	match plant_kind:
		"tree":
			return Trees.TREES[crop_id]
		"animal":
			return Animals.ANIMALS[crop_id]
		_:
			return Crops.CROPS[crop_id]

func _growth_time() -> float:
	var data: Dictionary = _data()
	return data.growth_time if not data.is_empty() else 0.0

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
		"plant_animal":
			_use_plant_animal()
		"remove":
			_use_remove()
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
	plant_kind = "crop"
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
	plant_kind = "tree"
	state_started_at = Time.get_unix_time_from_system()
	state = State.PLANTED
	_update_visual()

func _use_plant_animal() -> void:
	if state != State.EMPTY:
		return
	var selected: String = Economy.selected_animal
	if Economy.animal_inventory.get(selected, 0) <= 0:
		Economy.emit_status("Sem filhotes de %s. Compre na loja." % Animals.ANIMALS[selected].name)
		return
	Economy.consume_animal(selected)
	crop_id = selected
	plant_kind = "animal"
	state_started_at = Time.get_unix_time_from_system()
	state = State.PLANTED
	_update_visual()

func _use_harvest() -> void:
	if state != State.READY:
		return
	var data: Dictionary = _data()
	Economy.add_harvest(data.sell_value, data.xp)
	Economy.emit_status("Colheita de %s! (+R$ %d, +%d XP)" % [data.name, data.sell_value, data.xp])
	if plant_kind == "tree" or plant_kind == "animal":
		# Árvore/animal continua no lugar e volta a produzir depois de um tempo.
		NpcBoard.register_harvest(crop_id)
		state = State.PLANTED
		state_started_at = Time.get_unix_time_from_system()
	else:
		NpcBoard.register_harvest(crop_id)
		crop_id = ""
		# Terreno usado não volta a virar grama: fica infértil até arar de novo.
		state = State.INFERTILE
	_update_visual()

func _use_remove() -> void:
	if plant_kind == "crop" or (state != State.PLANTED and state != State.READY):
		return
	var data: Dictionary = _data()
	var refund: int = int(data.cost * REMOVE_REFUND_RATIO)
	Economy.refund(refund)
	Economy.emit_status("%s removido(a). +R$ %d de reembolso." % [data.name, refund])
	crop_id = ""
	plant_kind = "crop"
	state = State.EMPTY
	_update_visual()

func force_till() -> void:
	state = State.TILLED
	_update_visual()

func get_save_data() -> Dictionary:
	return {
		"state": state,
		"crop_id": crop_id,
		"plant_kind": plant_kind,
		"state_started_at": state_started_at,
	}

func load_save_data(data: Dictionary) -> void:
	state = int(data.get("state", State.EMPTY))
	crop_id = data.get("crop_id", "")
	plant_kind = data.get("plant_kind", "crop")
	state_started_at = float(data.get("state_started_at", 0.0))
	_update_visual()

func _update_visual() -> void:
	if plant_kind == "tree" or plant_kind == "animal":
		polygon.color = COLOR_EMPTY # árvore/animal fica sobre a grama
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
			match plant_kind:
				"tree":
					plant.scale = Vector2.ONE * lerp(0.3, 1.4, progress)
					plant.color = COLOR_TREE_GROWING
				"animal":
					plant.scale = Vector2.ONE * lerp(0.3, 1.2, progress)
					plant.color = COLOR_ANIMAL_GROWING
				_:
					plant.scale = Vector2.ONE * lerp(0.2, 1.0, progress)
					plant.color = COLOR_PLANT_GROWING
		State.READY:
			match plant_kind:
				"tree":
					plant.scale = Vector2.ONE * 1.4
					plant.color = COLOR_TREE_READY
				"animal":
					plant.scale = Vector2.ONE * 1.2
					plant.color = COLOR_ANIMAL_READY
				_:
					plant.scale = Vector2.ONE
					plant.color = COLOR_PLANT_READY
		State.WITHERED:
			plant.scale = Vector2.ONE * 0.8
			plant.color = COLOR_PLANT_WITHERED
