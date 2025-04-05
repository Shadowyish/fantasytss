extends Control

@onready var starting_menu_panel = $VBoxContainer
@onready var character_select_panel = $CharacterSelectPanel

func _ready():
	# Connect button signals
	$VBoxContainer/StartButton.pressed.connect(_on_start_game_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$CharacterSelectPanel/VBoxContainer/Warrior.pressed.connect(_on_warrior_pressed)
	$CharacterSelectPanel/VBoxContainer/Archer.pressed.connect(_on_archer_pressed)
	$CharacterSelectPanel/VBoxContainer/Mage.pressed.connect(_on_mage_pressed)

func _on_start_game_pressed():
	starting_menu_panel.visible = false
	character_select_panel.visible = true

func _on_options_pressed():
	#TODO:Implement Options?
	print("Options Menu - To Be Implemented")

func _on_quit_pressed():
	get_tree().quit()  # Closes the game

func _on_warrior_pressed():
	GameManager.launch_game("OvalForest.tscn", "Warrior.tscn")

func _on_archer_pressed():
	GameManager.launch_game("OvalForest.tscn", "Archer.tscn")

func _on_mage_pressed():
	GameManager.launch_game("OvalForest.tscn", "Mage.tscn")
