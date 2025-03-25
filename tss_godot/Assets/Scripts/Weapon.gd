extends Node2D
class_name Weapon
signal attack_finished

@export var pixels_from_player: int

func attack():
	push_error("Attack not implemented in: " + str(self))
