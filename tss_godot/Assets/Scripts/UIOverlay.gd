extends Control

@onready var hp_label = $CanvasLayer/ColorRect/HP
@onready var score_label = $CanvasLayer/ColorRect/Score

func _process(delta):
	hp_label.text = "HP: " + str(GameManager.player.cur_health)
	score_label.text = "Current Score: " + str(GameManager.game_score)
