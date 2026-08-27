extends Node

# Valores de Tabelas.md ("Arvores Frutiferas", N1/N3/N5).
# growth_time (segundos, valor de teste) representa o tempo ENTRE colheitas —
# diferente de plantação, a árvore continua no lugar e produz de novo depois
# desse tempo, em vez de precisar replantar. Valor real em horas nos comentários.
const TREES := {
	"macieira": {"name": "Macieira", "cost": 350, "sell_value": 60, "xp": 4, "growth_time": 30.0}, # real: 48h
	"laranjeira": {"name": "Laranjeira", "cost": 500, "sell_value": 85, "xp": 5, "growth_time": 35.0}, # real: 48h
	"bananeira": {"name": "Bananeira", "cost": 650, "sell_value": 130, "xp": 7, "growth_time": 45.0}, # real: 72h
}
