extends Node

# Valores de venda/custo/XP vindos de Tabelas.md (N1: Alface, Morango, Trigo).
# growth_time está em SEGUNDOS para facilitar teste manual — os valores reais
# da tabela (45 min / 4h / 12h) entram quando o balanceamento for revisado.
const CROPS := {
	"alface": {"name": "Alface", "cost": 5, "sell_value": 13, "xp": 1, "growth_time": 10.0},
	"morango": {"name": "Morango", "cost": 15, "sell_value": 35, "xp": 2, "growth_time": 15.0},
	"trigo": {"name": "Trigo", "cost": 35, "sell_value": 75, "xp": 3, "growth_time": 20.0},
}
