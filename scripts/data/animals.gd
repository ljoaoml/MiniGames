extends Node

# Valores de Tabelas.md ("Animais e Produtos", N1/N2/N4).
# growth_time (segundos, valor de teste) é o tempo ENTRE colheitas — igual
# árvore, o animal continua no lugar e produz de novo, não morre/murcha.
const ANIMALS := {
	"galinha": {"name": "Galinha Comum", "cost": 150, "sell_value": 25, "xp": 3, "growth_time": 24.0}, # real: 1 dia
	"coelho": {"name": "Coelho Branco", "cost": 250, "sell_value": 45, "xp": 4, "growth_time": 30.0}, # real: 2 dias
	"vaca": {"name": "Vaca Holandesa", "cost": 400, "sell_value": 70, "xp": 5, "growth_time": 24.0}, # real: 1 dia
}
