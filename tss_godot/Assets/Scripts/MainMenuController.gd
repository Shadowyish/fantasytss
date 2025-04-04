extends Control

func _ready():
	size = get_viewport_rect().size
	# Connect button signals
	$VBoxContainer/StartButton.pressed.connect(_on_start_game_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_game_pressed():
	# Pass loading logic to the Game Manager
	GameManager.launch_game("OvalForest.tscn")

func _on_options_pressed():
	#TODO:Implement Options?
	print("Options Menu - To Be Implemented")

func _on_quit_pressed():
	get_tree().quit()  # Closes the game
