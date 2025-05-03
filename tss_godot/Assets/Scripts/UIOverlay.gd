extends Control

@onready var hp_label = $CanvasLayer/ColorRect/HP
@onready var mana_label = $CanvasLayer/ColorRect/Mana
@onready var score_label = $CanvasLayer/ColorRect/Score
@onready var difficulty_threshold_label = $CanvasLayer/ColorRect/Difficulty
@onready var pause_panel = $CanvasLayer/PausePanel
@onready var resume_button = $CanvasLayer/PausePanel/VBoxContainer/ResumeButton
@onready var quit_button = $CanvasLayer/PausePanel/VBoxContainer/QuitButton
@onready var death_button = $CanvasLayer/DeathPanel/Button
@onready var control_display = $CanvasLayer/ControlPanel

var mouse_control_text = "Move: WASD \nAim: Mouse \nAttack: LMB \nSpecial: RMB"
var controller_control_text = "Move: Left Stick \nAim: Right Stick \nAttack: RB \nSpecial: LB"

func _ready():
	resume_button.pressed.connect(_on_resume_button)
	quit_button.pressed.connect(_on_quit_button)
	death_button.pressed.connect(_on_quit_button)
	$CanvasLayer/ControlPanel/Controls.text =  mouse_control_text if GameManager.input_type == GameManager.ControlType.MOUSE_KEYBOARD else controller_control_text
	
func _process(_delta):
	hp_label.text =  "HP: " + (str(GameManager.player.cur_health) + "/" + str(GameManager.player.health)) if GameManager.player.cur_health > 0 else "HP: DEAD"
	mana_label.text = "Mana: " + str(GameManager.player.cur_mana) + "/" + str(GameManager.player.mana)
	score_label.text = "Current Score: " + str(GameManager.game_score)
	difficulty_threshold_label.text = "Next Difficulty Threshold: " + str(GameManager.next_threshold_cap)
	#TODO: Change to a signal put out by the GameManager
	
func _on_resume_button():
	pause_panel.visible = false
	GameManager.resume_game()
	
func _on_quit_button():
	GameManager.quit_game()
	
func _on_pause():
	pause_panel.visible = true
	$CanvasLayer/PausePanel/Controls.text =  mouse_control_text if GameManager.input_type == GameManager.ControlType.MOUSE_KEYBOARD else controller_control_text
	resume_button.grab_focus()
	
func _on_display_timeout():
	control_display.visible = false

func _on_player_death():
	$CanvasLayer/DeathPanel.visible = true
	death_button.grab_focus()
