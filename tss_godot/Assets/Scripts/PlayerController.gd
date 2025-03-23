extends CharacterBody2D

@export var speed: float = 100.0
@export var rotation_speed: float = 60.0
@export var health: int = 100
@export var attack_speed: int = 10
@export var mana: int = 20
@export var cur_weapon: Node

var is_dead = false
var cur_health: int = health
var aim_direction = Vector2.RIGHT
var iframe_time: float = 0.67
var is_invunerable = false

signal player_died

@onready var iframe_timer = Timer.new()

func _ready():
	# timer hookups
	add_child(iframe_timer)
	iframe_timer.one_shot = true
	iframe_timer.connect("timeout", _on_iframe_timeout)
	
	GameManager.player = self

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	# Get movement input then normalize to prevent speed boost
	input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	velocity = input_vector * speed * delta
	move_and_slide()

	# Get rotation input and rotate char
	if GameManager.game_manager.input_type == GameManager.ControlType.MOUSE_KEYBOARD:
		aim_direction = (get_global_mouse_position() - global_position).normalized()
	elif GameManager.game_manager.input_type == GameManager.ControlType.GAMEPAD:
		var right_stick = Vector2(
			Input.get_axis("right_stick_left", "right_stick_right"),
			Input.get_axis("right_stick_up", "right_stick_down")
		).normalized()
	rotation = lerp(rotation, aim_direction.angle(), rotation_speed * delta)

func take_damage(damage: int):
	if is_dead:
		return # do nothing if player is already dead
	cur_health -= damage
	if cur_health <= 0:
		die()
	else: # start iframes
		is_invunerable = true
		#TODO: give some indication of iframes
		#start timer
		iframe_timer.start(iframe_time)

func use_weapon():
	cur_weapon.attack()

func die():
	emit_signal("player_died")
	play_death_animation()
	await(get_tree().create_timer(2.0))
	#TODO: Trigger GameOver/Score Screen

func play_death_animation():
	#TODO: Play Death Animation?
	pass

func _on_iframe_timeout():
	is_invunerable = false
	#TODO: remove visuals
