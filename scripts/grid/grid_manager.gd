extends Node2D

const GRID_SIZE := 10
const TILE_WIDTH := 64.0
const TILE_HEIGHT := 32.0

@export var tile_scene: PackedScene

func _ready() -> void:
	_generate_grid()

func _generate_grid() -> void:
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var tile := tile_scene.instantiate()
			add_child(tile)
			tile.position = _grid_to_iso(col, row)

func _grid_to_iso(col: int, row: int) -> Vector2:
	var x := (col - row) * (TILE_WIDTH / 2.0)
	var y := (col + row) * (TILE_HEIGHT / 2.0)
	return Vector2(x, y)
