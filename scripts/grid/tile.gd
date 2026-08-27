extends Node2D

enum State { EMPTY, TILLED, PLANTED, READY }

const COLOR_EMPTY := Color(0.4, 0.7, 0.3)
const COLOR_TILLED := Color(0.55, 0.35, 0.15)
const COLOR_PLANT_GROWING := Color(0.55, 0.75, 0.25)
const COLOR_PLANT_READY := Color(0.9, 0.85, 0.15)

# Tempo de crescimento da Alface: valor real na Tabelas.md é 45 min.
# Usando 10s aqui só para testar o ciclo de plantio/colheita mais rápido.
const GROWTH_TIME := 10.0

var state: State = State.EMPTY
var growth_timer: float = 0.0

@onready var polygon: Polygon2D = $Polygon2D
@onready var area: Area2D = $Area2D
@onready var plant: Polygon2D = $Plant

func _ready() -> void:
	area.input_event.connect(_on_area_input_event)
	_update_visual()

func _process(delta: float) -> void:
	if state == State.PLANTED:
		growth_timer += delta
		if growth_timer >= GROWTH_TIME:
			growth_timer = GROWTH_TIME
			state = State.READY
		_update_visual()

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

func _handle_click() -> void:
	match state:
		State.EMPTY:
			state = State.TILLED
		State.TILLED:
			state = State.PLANTED
			growth_timer = 0.0
		State.PLANTED:
			pass # ainda crescendo, clique não faz nada
		State.READY:
			_harvest()
	_update_visual()

func _harvest() -> void:
	print("Colheita de Alface! (+R$ 13, +1 XP)")
	state = State.TILLED
	growth_timer = 0.0

func _update_visual() -> void:
	polygon.color = COLOR_TILLED if state != State.EMPTY else COLOR_EMPTY

	plant.visible = state == State.PLANTED or state == State.READY
	if state == State.PLANTED:
		var progress := growth_timer / GROWTH_TIME
		plant.scale = Vector2.ONE * lerp(0.2, 1.0, progress)
		plant.color = COLOR_PLANT_GROWING
	elif state == State.READY:
		plant.scale = Vector2.ONE
		plant.color = COLOR_PLANT_READY
