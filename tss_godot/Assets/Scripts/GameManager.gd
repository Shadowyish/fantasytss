extends Node

enum ControlType { MOUSE_KEYBOARD, GAMEPAD }
var input_type = ControlType.MOUSE_KEYBOARD  # Default to keyboard & mouse
var player: CharacterBody2D
var game_score: int = 0

func increase_score(score: int):
	game_score += score
	push_warning("Score added: " + str(score))
	push_warning("Score now totals: " + str(game_score))
