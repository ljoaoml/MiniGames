extends Node

# Valores de venda/custo/XP vindos de Tabelas.md (N1-N4).
# growth_time está em SEGUNDOS para facilitar teste manual — os tempos reais
# da tabela (entre parênteses) entram quando o balanceamento for revisado.
const CROPS := {
	"alface": {"name": "Alface", "cost": 5, "sell_value": 13, "xp": 1, "growth_time": 10.0}, # real: 45 min
	"morango": {"name": "Morango", "cost": 15, "sell_value": 35, "xp": 2, "growth_time": 15.0}, # real: 4h
	"tomate": {"name": "Tomate", "cost": 25, "sell_value": 58, "xp": 2, "growth_time": 20.0}, # real: 8h
	"trigo": {"name": "Trigo", "cost": 35, "sell_value": 75, "xp": 3, "growth_time": 25.0}, # real: 12h
	"abobora": {"name": "Abóbora", "cost": 85, "sell_value": 215, "xp": 5, "growth_time": 35.0}, # real: 48h
	"milho": {"name": "Milho", "cost": 100, "sell_value": 260, "xp": 7, "growth_time": 45.0}, # real: 72h
}
