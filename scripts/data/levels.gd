extends Node

# Curva de XP por nível: placeholder (quadrática) até termos dados reais de
# balanceamento em Tabelas.md. Nível N exige LEVEL_XP_FACTOR * (N-1)^2 XP total.
const LEVEL_XP_FACTOR := 50

func get_level(xp: int) -> int:
	var level := 1
	while xp >= xp_for_level(level + 1):
		level += 1
	return level

func xp_for_level(level: int) -> int:
	return LEVEL_XP_FACTOR * (level - 1) * (level - 1)

func xp_progress_text(xp: int) -> String:
	var level := get_level(xp)
	var next_threshold := xp_for_level(level + 1)
	return "XP: %d / %d" % [xp, next_threshold]
