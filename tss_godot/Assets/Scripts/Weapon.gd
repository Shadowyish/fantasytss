extends Node2D
class_name Weapon
signal attack_finished

func attack():
	push_error("Attack not implemented in: " + str(self))
