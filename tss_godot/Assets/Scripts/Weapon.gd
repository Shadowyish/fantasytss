extends Node2D
class_name Weapon
signal attack_finished

@export var pixels_from_player: int

func attack():
	push_error("Attack not implemented in: " + str(self))
	
func special():
	push_error("Special not implemented in: " + str(self))
