extends Node2D
class_name Weapon
signal attack_finished

@export var pixels_from_player: int
@export var mana_cost: int #amount of mana the special costs

func attack():
	push_error("Attack not implemented in: " + str(self))
	
func special():
	push_error("Special not implemented in: " + str(self))
