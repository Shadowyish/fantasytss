extends Node

enum ControlType { MOUSE_KEYBOARD, GAMEPAD }
enum GameMode {Game, Menu, Pause}
var input_type = ControlType.MOUSE_KEYBOARD  # Default to keyboard & mouse
var game_mode = GameMode.Menu
var player: Node #Spawn into scene instead of natively in scene
var camera: Camera2D #Spawn into scene instead of natively in scene
var ui: Control #Holds in game UI Component, for pausing, etc.
var player_name: String = "test"
var follow_speed: float = 5.0
var time_passed: float = 0.0
var pickup_time: float = 10.0
var control_display_time: float = 3.0 #controls how long the tooltip for controls lasts on game start
var game_score: int = 0
var score_per_second: int = 5
var enemy_count: int = 0
var mana_pickup_count: int = 0
var score_pickup_count: int = 0
var enemy_max: int = 10 # Max enemies at one time, difficulty increases this
var spawn_offset: int = -100 # How many pixels offset from the camera border spawns for enemies should occur
var next_threshold_cap: int = 1000 # the score at which the game first increases difficulty
var diff_threshold_level: int = 1 # levels of difficulty
var zombie_threshold: int = 2000 # Second threshold, used to control what score zombies can spawn
var wraith_threshold: int = 5750 # Fourth threshold, used to control what score wraiths can spawn
var max_camera_threshold: float = 256.0
var min_camera_threshold: float = -256.0
var camera_size: Vector2
var pickup_timer: Timer
var control_timer: Timer 

func _process(delta):
	if(game_mode == GameMode.Game):
		# camera panning: Smooth follows player
		camera.position = camera.position.lerp(GameManager.player.position, follow_speed * delta)
		camera.position.x = clamp(camera.position.x, min_camera_threshold, max_camera_threshold)
		camera.position.y = clamp(camera.position.y, min_camera_threshold, max_camera_threshold)
		player.global_position.x = clamp(player.global_position.x, min_camera_threshold - (camera_size.x/4), max_camera_threshold + (camera_size.x/4))
		player.global_position.y = clamp(player.global_position.y, min_camera_threshold - (camera_size.y/4), max_camera_threshold + (camera_size.y/4))
		# handle game logic
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
		# pause
		if Input.is_action_just_pressed("pause"):
			Engine.time_scale = 0.0
			game_mode = GameMode.Pause
			ui._on_pause()

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_type = ControlType.GAMEPAD
	elif event is InputEventKey or event is InputEventMouse:
		input_type = ControlType.MOUSE_KEYBOARD

func _on_pickup_timeout():
	if mana_pickup_count < 10:
		for i in randi_range(1, 10 - mana_pickup_count):
			spawn_mana_pickups()
	if score_pickup_count < 5:
		for i in randi_range(1, 5 - score_pickup_count):
			spawn_score_pickups()

func launch_game(map: String, character: String):
	#Load Map for Game
	get_tree().change_scene_to_file("res://Assets/Scenes/"+ map)
	await get_tree().process_frame
	
	#Load player and camera
	player = load("res://Assets/Prefabs/" + character).instantiate()
	camera = load("res://Assets/Prefabs/MainCamera.tscn").instantiate()
	get_tree().current_scene.add_child(player)
	get_tree().current_scene.add_child(camera)
	
	#ensure the game is set up properly
	#reset game stats to defaults
	ui = get_tree().current_scene.find_child("GameUI")
	Engine.time_scale = 1.0
	diff_threshold_level = 1
	game_score = 0
	enemy_count = 0
	score_per_second = 5
	next_threshold_cap = 1000
	enemy_max = 10
	mana_pickup_count = 0
	score_pickup_count = 0
	game_mode = GameMode.Game
	pickup_timer = Timer.new()
	control_timer = Timer.new()
	camera_size = camera.get_viewport_rect().size
	get_tree().current_scene.add_child(pickup_timer)
	pickup_timer.connect("timeout", _on_pickup_timeout)
	get_tree().current_scene.add_child(control_timer)
	control_timer.one_shot = true
	control_timer.connect("timeout", ui._on_display_timeout)
	pickup_timer.start(pickup_time)
	control_timer.start(control_display_time)
	player.connect("player_died", ui._on_player_death)

func spawn_mana_pickups():
	var viewport_size = camera.get_viewport_rect().size
	var spawn_position = Vector2.ZERO
	# generate somewhere on the screen!
	spawn_position = Vector2(randf_range(camera.global_position.x - viewport_size.x / 2,
	 		camera.global_position.x + viewport_size.x / 2), 
			randf_range(camera.global_position.y - viewport_size.y / 2,
			camera.global_position.y + viewport_size.y / 2))
	var mana_crystal = load("res://Assets/Prefabs/ManaCrystal.tscn").instantiate()
	# make sure pickups don't get locked behind the camera lock
	spawn_position.x = clamp(spawn_position.x, min_camera_threshold, max_camera_threshold)
	spawn_position.y = clamp(spawn_position.y, min_camera_threshold, max_camera_threshold)
	mana_crystal.position = spawn_position
	get_tree().current_scene.add_child(mana_crystal)
	mana_pickup_count += 1
	
func spawn_score_pickups():
	var viewport_size = camera.get_viewport_rect().size
	var spawn_position = Vector2.ZERO
	# generate somewhere on the screen!
	spawn_position = Vector2(randf_range(camera.global_position.x - viewport_size.x / 2,
			camera.global_position.x + viewport_size.x / 2), 
			randf_range(camera.global_position.y - viewport_size.y / 2,
			camera.global_position.y + viewport_size.y / 2))
	var pickup = load("res://Assets/Prefabs/ScorePickup.tscn").instantiate()
	# make sure pickups don't get locked behind the camera lock
	spawn_position.x = clamp(spawn_position.x, min_camera_threshold, max_camera_threshold)
	spawn_position.y = clamp(spawn_position.y, min_camera_threshold, max_camera_threshold)
	pickup.position = spawn_position
	get_tree().current_scene.add_child(pickup)
	score_pickup_count += 1

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
	diff_threshold_level += 1
	next_threshold_cap = int(next_threshold_cap * 1.5 + 500)
	spawn_weapon_pickup()
	player.cur_health = player.health
	player.cur_mana = player.mana
	
func get_next_enemy() -> Node2D:
	#Spawn only skeletons at the start
	if diff_threshold_level <= 2:
		return spawn_skele()
	#Once first threshold reached you can spawn zombies too
	elif diff_threshold_level <= 4:
		var enemy_rand = randi() % 2
		match enemy_rand:
			0:
				return spawn_zombie()
			1: 
				return spawn_skele()
			_: 
				push_error("Something wrong with enemy spawning, random number mismatch")
				return null
	#Once past second threshold we can spawn all three
	else:
		var enemy_rand = randi() % 3
		match enemy_rand:
			0:
				return spawn_zombie()
			1: 
				return spawn_skele()
			2:
				return spawn_wraith()
			_:
				push_error("Something wrong with enemy spawning, random number mismatch")
				return null
	
func spawn_skele() -> Node2D:
	var skele = load("res://Assets/Prefabs/Skeleton.tscn").instantiate()
	var stats = skele.get_node("CharacterBody2D")
	stats.hp *= pow(1.25, diff_threshold_level / 5.0)
	stats.damage *= pow(1.5, diff_threshold_level / 5.0)
	stats.speed *= pow(1.25, diff_threshold_level / 5.0)
	return skele
	
func spawn_zombie() -> Node2D:
	#subtracting 2 cause that's when zombies start spawning
	var zom = load("res://Assets/Prefabs/Zombie.tscn").instantiate()
	var stats = zom.get_node("CharacterBody2D")
	stats.hp *= pow(2, diff_threshold_level -2 / 5.0)
	stats.damage *= pow(1.5, diff_threshold_level -2 / 5.0)
	stats.speed *= pow(1.25, diff_threshold_level -2 / 5.0)
	return zom
	
func spawn_wraith() -> Node2D:
	var wraith = load("res://Assets/Prefabs/Wraith.tscn").instantiate()
	#subtracting 4 cause that's when wraiths start spawning
	var stats = wraith.get_node("CharacterBody2D")
	stats.hp *= pow(1.25, diff_threshold_level -4 / 5.0)
	stats.damage *= pow(2, diff_threshold_level -4 / 5.0)
	stats.speed *= pow(1.5, diff_threshold_level -4 / 5.0)
	return wraith
	
func spawn_weapon_pickup():
	var viewport_size = camera.get_viewport_rect().size
	var spawn_position = Vector2.ZERO
	# generate somewhere on the screen!
	spawn_position = Vector2(randf_range(camera.global_position.x - viewport_size.x / 2,
			camera.global_position.x + viewport_size.x / 2), 
			randf_range(camera.global_position.y - viewport_size.y / 2,
			camera.global_position.y + viewport_size.y / 2))
	var pickup = pick_weapon_spawn()
	# make sure pickups don't get locked behind the camera lock
	spawn_position.x = clamp(spawn_position.x, min_camera_threshold, max_camera_threshold)
	spawn_position.y = clamp(spawn_position.y, min_camera_threshold, max_camera_threshold)
	pickup.position = spawn_position
	get_tree().current_scene.add_child(pickup)
	get_tree().create_timer(30.0).connect("timeout", on_weapon_pickup_timeout.bind(pickup))
	
func pick_weapon_spawn():
	var weapon_rand = randi() % 6
	match weapon_rand:
		0:
			return load("res://Assets/Prefabs/Bow.tscn").instantiate()
		1:
			return load("res://Assets/Prefabs/LightningStaff.tscn").instantiate()
		2:
			return load("res://Assets/Prefabs/FireBallStaff.tscn").instantiate()
		3:
			return load("res://Assets/Prefabs/ShortBow.tscn").instantiate()
		4:
			return load("res://Assets/Prefabs/Dagger.tscn").instantiate()
		5:
			return load("res://Assets/Prefabs/Sword.tscn").instantiate()
		_:
			push_error("issue with weapon spawning, issue with random number mismatch")
			return null
	
func resume_game():
	game_mode = GameMode.Game
	Engine.time_scale = 1.0
	
func on_weapon_pickup_timeout(pickup: Node2D):
	if pickup.has_player != true:
		pickup.call_deferred("queue_free");
	
func quit_game():
	SaveManager.save(game_score, player_name)
	game_mode = GameMode.Menu
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")
