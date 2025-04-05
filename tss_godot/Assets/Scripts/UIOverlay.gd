extends Control

@onready var hp_label = $CanvasLayer/ColorRect/HP
@onready var score_label = $CanvasLayer/ColorRect/Score
@onready var difficulty_threshold_label = $CanvasLayer/ColorRect/Difficulty
@onready var pause_panel = $CanvasLayer/PausePanel
@onready var resume_button = $CanvasLayer/PausePanel/VBoxContainer/ResumeButton
@onready var quit_button = $CanvasLayer/PausePanel/VBoxContainer/QuitButton

func _ready():
	resume_button.pressed.connect(_on_resume_button)
	quit_button.pressed.connect(_on_quit_button)

func _process(_delta):
	hp_label.text =  "HP: " + str(GameManager.player.cur_health) if GameManager.player.cur_health > 0 else "HP: DEAD"
	score_label.text = "Current Score: " + str(GameManager.game_score)
	difficulty_threshold_label.text = "Next Difficulty Threshold: " + str(GameManager.next_threshold_cap)
	if GameManager.game_mode == GameManager.GameMode.Pause:
		pause_panel.visible = true
	
func _on_resume_button():
	pause_panel.visible = false
	GameManager.resume_game()
	
func _on_quit_button():
	GameManager.quit_game()
