extends Node2D

enum State { EMPTY, TILLED }

const COLOR_EMPTY := Color(0.4, 0.7, 0.3)
const COLOR_TILLED := Color(0.55, 0.35, 0.15)

var state: State = State.EMPTY

@onready var polygon: Polygon2D = $Polygon2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.input_event.connect(_on_area_input_event)
	_update_visual()

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_state()

func _toggle_state() -> void:
	state = State.TILLED if state == State.EMPTY else State.EMPTY
	_update_visual()

func _update_visual() -> void:
	polygon.color = COLOR_TILLED if state == State.TILLED else COLOR_EMPTY
