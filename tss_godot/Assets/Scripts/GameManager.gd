extends Node

enum ControlType { MOUSE_KEYBOARD, GAMEPAD }
enum GameMode {Game, Menu, Pause}
var input_type = ControlType.MOUSE_KEYBOARD  # Default to keyboard & mouse
var game_mode = GameMode.Menu
var player: Node2D #Spawn into scene instead of natively in scene
var camera: Camera2D #Spawn into scene instead of natively in scene
var follow_speed: float = 5.0
var time_passed: float = 0.0
var game_score: int = 0
var score_per_second: int = 5
var enemy_count: int = 0
var enemy_max: int = 10 # Max enemies at one time, difficulty increases this
var spawn_offset: int = -100 # How many pixels offset from the camera border spawns for enemies should occur
var next_threshold_cap: int = 1000 # the score at which the game first increases difficulty
var zombie_threshold: int = 2000 # Second threshold, used to control what score zombies can spawn
var wraith_threshold: int = 5750 # Fourth threshold, used to control what score wraiths can spawn
var is_playing = false

func _process(delta):
	if(game_mode == GameMode.Game):
		# camera panning: Smooth follows player
		camera.position = camera.position.lerp(GameManager.player.position, follow_speed * delta)
		if enemy_count < enemy_max:
			for i in randi_range(1, enemy_max - enemy_count):
				spawn_enemies()
		if player.cur_health > 0:
			time_passed += delta
			while(time_passed > 1.0):
				time_passed -= 1
				increase_score(score_per_second)
		if game_score > next_threshold_cap:
			increase_difficulty()
		if Input.is_action_just_pressed("pause"):
			Engine.time_scale = 0.0
			game_mode = GameMode.Pause
	
func launch_game(map: String, character: String):
	get_tree().change_scene_to_file("res://Assets/Scenes/"+ map)
	# TODO: Add Logic for player Classes
	await get_tree().process_frame
	
	player = load("res://Assets/Prefabs/" + character).instantiate()
	camera = load("res://Assets/Prefabs/MainCamera.tscn").instantiate()
	get_tree().current_scene.add_child(player)
	get_tree().current_scene.add_child(camera)
	game_mode = GameMode.Game
	
func spawn_enemies():
	var edge = randi() % 4
	var viewport_size = camera.get_viewport_rect().size
	var spawn_position = Vector2.ZERO
	# Logic for calculations - random range is along the edge of the veiwport that we are not offsetting to
	# Example: Top, Rand range for width, fixed offset for height
	match edge:
		0: #Top
			spawn_position = Vector2(randf_range(camera.global_position.x - viewport_size.x / 2, camera.global_position.x + viewport_size.x / 2), 
									 camera.global_position.y - viewport_size.y / 2 - spawn_offset)
		1: # Left
			spawn_position = Vector2(camera.global_position.x - viewport_size.x / 2 - spawn_offset, 
									 randf_range(camera.global_position.y - viewport_size.y / 2, camera.global_position.y + viewport_size.y / 2))
		2: # Right
			spawn_position = Vector2(camera.global_position.x + viewport_size.x / 2 + spawn_offset, 
									 randf_range(camera.global_position.y - viewport_size.y / 2, camera.global_position.y + viewport_size.y / 2))
		3: #Bottom
			spawn_position = Vector2(randf_range(camera.global_position.x - viewport_size.x / 2, camera.global_position.x + viewport_size.x / 2), 
									 camera.global_position.y + viewport_size.y / 2 + spawn_offset)
	var enemy = get_next_enemy()
	enemy.position = spawn_position
	get_tree().current_scene.add_child(enemy)
	enemy_count += 1
	
func increase_score(score: int):
	game_score += score
	
func increase_difficulty():
	enemy_max += 5
	score_per_second += 5
	next_threshold_cap += next_threshold_cap * .5 + 500
	
func get_next_enemy():
	#Spawn only skeletons at the start
	if next_threshold_cap <= 2000:
		return load("res://Assets/Prefabs/Skeleton.tscn").instantiate()
	#Once first threshold reached you can spawn zombies too
	elif next_threshold_cap <= 5750:
		var enemy_rand = randi() % 2
		match enemy_rand:
			0:
				return load("res://Assets/Prefabs/Zombie.tscn").instantiate()
			1: 
				return load("res://Assets/Prefabs/Skeleton.tscn").instantiate()
	#Once past second threshold we can spawn all three
	else:
		var enemy_rand = randi() % 3
		match enemy_rand:
			0:
				return load("res://Assets/Prefabs/Zombie.tscn").instantiate()
			1: 
				return load("res://Assets/Prefabs/Skeleton.tscn").instantiate()
			2:
				return load("res://Assets/Prefabs/Wraith.tscn").instantiate()
	
func resume_game():
	game_mode = GameMode.Game
	Engine.time_scale = 1.0

func quit_game():
	#TODO: Handle Save Data Logic
	game_mode = GameMode.Menu
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")
