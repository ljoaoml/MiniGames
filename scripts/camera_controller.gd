extends Camera2D

const ZOOM_STEP := 0.1
const ZOOM_MIN := 0.5
const ZOOM_MAX := 2.0

var _dragging: bool = false
var _drag_start_mouse: Vector2
var _drag_start_cam: Vector2

func _ready() -> void:
	make_current()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
			if _dragging:
				_drag_start_mouse = event.position
				_drag_start_cam = position
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-ZOOM_STEP)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(ZOOM_STEP)
	elif event is InputEventMouseMotion and _dragging:
		var delta: Vector2 = event.position - _drag_start_mouse
		position = _drag_start_cam - delta / zoom

func _zoom(amount: float) -> void:
	var new_zoom: float = clamp(zoom.x + amount, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(new_zoom, new_zoom)
