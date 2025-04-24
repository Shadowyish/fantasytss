extends Control

@onready var starting_menu_panel = $VBoxContainer
@onready var character_select_panel = $CharacterSelectPanel
@onready var name_input_panel = $NameInputPanel
@onready var leaderboard_panel = $LeaderboardPanel
@onready var leaderboard_list = $LeaderboardPanel/ScrollContainer/LeaderboardList

func _ready():
	# Connect button signals to their proper functions
	$VBoxContainer/StartButton.pressed.connect(_on_start_game_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_leaderboard_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$CharacterSelectPanel/VBoxContainer/Warrior.pressed.connect(_on_warrior_pressed)
	$CharacterSelectPanel/VBoxContainer/Archer.pressed.connect(_on_archer_pressed)
	$CharacterSelectPanel/VBoxContainer/Mage.pressed.connect(_on_mage_pressed)
	$CharacterSelectPanel/VBoxContainer/Back.pressed.connect(_on_charselect_back_pressed)
	$NameInputPanel/SubmitButton.pressed.connect(_on_name_input)
	$NameInputPanel/Back.pressed.connect(_on_nameinput_back_pressed)
	$LeaderboardPanel/Back.pressed.connect(_on_leaderboard_back_pressed)
	$NameInputPanel/LineEdit.text_submitted.connect(_on_name_input_submitted)
	# have first option grab focus, so controller input will work
	$VBoxContainer/StartButton.grab_focus()

func _on_start_game_pressed():
	starting_menu_panel.visible = false
	name_input_panel.visible = true
	$NameInputPanel/Back.grab_focus()

func _on_charselect_back_pressed():
	character_select_panel.visible = false
	name_input_panel.visible = true
	$NameInputPanel/Back.grab_focus()

func _on_nameinput_back_pressed():
	starting_menu_panel.visible = true
	name_input_panel.visible = false
	$VBoxContainer/StartButton.grab_focus()

func _on_name_input():
	character_select_panel.visible = true
	name_input_panel.visible = false
	GameManager.player_name = $NameInputPanel/LineEdit.text
	$CharacterSelectPanel/VBoxContainer/Warrior.grab_focus()

#Used for the LineEdit signal that is emitted on pressing Enter
#Named it this, because apparently I can't overload the method :(
func _on_name_input_submitted(name_: String):
	character_select_panel.visible = true
	name_input_panel.visible = false
	GameManager.player_name = name
	$CharacterSelectPanel/VBoxContainer/Warrior.grab_focus()

func _on_leaderboard_pressed():
	starting_menu_panel.visible = false
	leaderboard_panel.visible = true
	update_leaderboard()
	$LeaderboardPanel/Back.grab_focus()

func _on_leaderboard_back_pressed():
	break_down_leaderboard()
	leaderboard_panel.visible = false
	starting_menu_panel.visible = true
	$VBoxContainer/StartButton.grab_focus()

func _on_quit_pressed():
	get_tree().quit()  # Closes the game

func _on_warrior_pressed():
	GameManager.launch_game("OvalForest.tscn", "Warrior.tscn")

func _on_archer_pressed():
	GameManager.launch_game("OvalForest.tscn", "Archer.tscn")

func _on_mage_pressed():
	GameManager.launch_game("OvalForest.tscn", "Mage.tscn")

func update_leaderboard():
	for entry in SaveManager.score_list:
		var score_listing = load("res://Assets/Prefabs/LeaderboardEntry.tscn").instantiate()
		score_listing.text = entry.name_ + ":" + str(entry.score)
		leaderboard_list.add_child(score_listing)

func break_down_leaderboard():
	for child in leaderboard_list.get_children():
		leaderboard_list.remove_child(child)
		child.queue_free()
