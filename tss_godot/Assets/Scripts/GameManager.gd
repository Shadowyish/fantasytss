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
var enemy_count: int = 0
var spawn_offset: int = 100 # How many pixels offset from the camera border spawns for enemies should occur
var is_playing = false

func _process(delta):
	if(game_mode == GameMode.Game):
		# camera panning: Smooth follows player
		camera.position = camera.position.lerp(GameManager.player.position, follow_speed * delta)
		if enemy_count < 10:
			spawn_enemies()
		if player.cur_health > 0:
			time_passed += delta
			while(time_passed > 1.0):
				time_passed -= 1
				increase_score(5)
	
func launch_game(map: String):
	get_tree().change_scene_to_file("res://Assets/Scenes/"+ map)
	# TODO: Add Logic for player Classes
	await get_tree().process_frame
	
	player = load("res://Assets/Prefabs/Warrior.tscn").instantiate()
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
	
	#Temp Logic for spawning a skelton or zombie
	# TODO: Build proper list of spawns, that way we can have more than two
	var enemy_rand = randi() % 6
	var enemy = null
	if enemy_count % 7 >= 7 - enemy_rand:
		enemy = load("res://Assets/Prefabs/Zombie.tscn").instantiate()
	else:
		enemy = load("res://Assets/Prefabs/Skeleton.tscn").instantiate()
	enemy.position = spawn_position
	get_tree().current_scene.add_child(enemy)
	enemy_count += 1
	
func increase_score(score: int):
	game_score += score
	push_warning("Score added: " + str(score))
	push_warning("Score now totals: " + str(game_score))
