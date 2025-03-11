extends CharacterBody2D

@export var speed = 100.0
@export var rotation_speed = 60.0
@export var health = 100
@export var attack_speed = 10
@export var mana = 20
var cur_health = health
var aim_direction = Vector2.RIGHT


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	# Get movement input then normalize to prevent speed boost
	input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_vector * speed * delta
	move_and_slide()

	# Get rotation input
	if GameManager.game_manager.input_type == GameManager.ControlType.MOUSE_KEYBOARD:
		aim_direction = (get_global_mouse_position() - global_position).normalized()
	elif GameManager.game_manager.input_type == GameManager.ControlType.GAMEPAD:
		var right_stick = Vector2(
			Input.get_axis("right_stick_left", "right_stick_right"),
			Input.get_axis("right_stick_up", "right_stick_down")
		).normalized()
	rotation = lerp(rotation, aim_direction.angle(), rotation_speed * delta)
func take_damage(damage: int):
	cur_health -= damage
