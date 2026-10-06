extends Node

var rounds: int = 10
var current_round: int = 1
var enemies_per_round: int = 10
var enemies_this_round: int = enemies_per_round
var enemies_multiplier: float = 1.2
var enemies_alive: int = 0

func update_round():
	if enemies_alive > 0:
		return
	
	current_round += 1
	enemies_this_round = roundi(enemies_per_round * enemies_multiplier)
