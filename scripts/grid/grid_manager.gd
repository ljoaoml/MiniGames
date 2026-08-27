extends Node2D

const TILE_WIDTH := 64.0
const TILE_HEIGHT := 32.0

# Passos de expansão de Descricao do jogo.md (10 -> 12 -> 16 -> 20 -> 24 -> 30).
const SIZE_STEPS := [10, 12, 16, 20, 24, 30]

# Nível/custo por expansão: placeholder até termos balanceamento real
# (Tabelas.md ainda não cobre isso).
const EXPANSION_REQUIREMENTS := {
	12: {"level": 2, "cost": 300},
	16: {"level": 4, "cost": 800},
	20: {"level": 6, "cost": 1800},
	24: {"level": 8, "cost": 3200},
	30: {"level": 10, "cost": 5000},
}

# Canteiros pré-arados no centro no início (6 a 9, conforme design doc).
const PRETILLED_OFFSETS := [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]

signal expanded(new_size: int)

@export var tile_scene: PackedScene

var current_size: int = 10
var tiles: Dictionary = {}

func _ready() -> void:
	World.farm_grid = self
	_generate_initial_grid()

func _generate_initial_grid() -> void:
	var half := current_size / 2
	for row in range(-half, half):
		for col in range(-half, half):
			_create_tile(col, row)
	for offset in PRETILLED_OFFSETS:
		var tile: Node = tiles.get(offset)
		if tile:
			tile.force_till()

func _create_tile(col: int, row: int) -> void:
	var tile := tile_scene.instantiate()
	add_child(tile)
	tile.position = _grid_to_iso(col, row)
	tiles[Vector2i(col, row)] = tile

func _grid_to_iso(col: int, row: int) -> Vector2:
	var x := (col - row) * (TILE_WIDTH / 2.0)
	var y := (col + row) * (TILE_HEIGHT / 2.0)
	return Vector2(x, y)

func get_next_expansion_info() -> Dictionary:
	var idx := SIZE_STEPS.find(current_size)
	if idx == -1 or idx + 1 >= SIZE_STEPS.size():
		return {}
	var next_size: int = SIZE_STEPS[idx + 1]
	var req: Dictionary = EXPANSION_REQUIREMENTS[next_size]
	return {"size": next_size, "level": req.level, "cost": req.cost}

func try_expand() -> Dictionary:
	var info := get_next_expansion_info()
	if info.is_empty():
		return {"success": false, "reason": "Área já está no tamanho máximo (30x30)."}
	var level: int = Levels.get_level(Economy.xp)
	if level < info.level:
		return {"success": false, "reason": "Precisa ser nível %d (você é nível %d)." % [info.level, level]}
	if Economy.coins < info.cost:
		return {"success": false, "reason": "Precisa de R$ %d (você tem R$ %d)." % [info.cost, Economy.coins]}
	Economy.coins -= info.cost
	Economy.coins_changed.emit(Economy.coins)
	_expand_to(info.size)
	return {"success": true, "reason": ""}

func _expand_to(new_size: int) -> void:
	var half := new_size / 2
	for row in range(-half, half):
		for col in range(-half, half):
			if not tiles.has(Vector2i(col, row)):
				_create_tile(col, row)
	current_size = new_size
	expanded.emit(new_size)
