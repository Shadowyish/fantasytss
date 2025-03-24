extends CharacterBody2D

@export var speed: float
@export var health: int
@export var attack_speed: int
@export var mana: int
@export var cur_weapon: Node


var cur_health: int = health
var aim_direction = Vector2.RIGHT
var iframe_time: float = 0.67
var is_invunerable = false
var is_dead = false
var is_hit = false
var is_facing_right = true
var is_attacking = false

signal player_died

#Using a timer for iframes to make it unblocking
@onready var iframe_timer = Timer.new()
@onready var anim = $Animator

func _ready():
	# timer hookups
	add_child(iframe_timer)
	iframe_timer.one_shot = true
	iframe_timer.connect("timeout", _on_iframe_timeout)
	
	# hit animation hookup
	anim.animation_finished.connect(_on_animation_finished)
	
	# Subscribe to weapon listener
	cur_weapon.attack_finished.connect(_on_attack_done)
	
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
	
	# Get rotation direction
	if GameManager.game_manager.input_type == GameManager.ControlType.MOUSE_KEYBOARD:
		aim_direction = (get_global_mouse_position() - global_position).normalized()
	elif GameManager.game_manager.input_type == GameManager.ControlType.GAMEPAD:
		aim_direction = Vector2(
			Input.get_axis("right_stick_left", "right_stick_right"),
			Input.get_axis("right_stick_up", "right_stick_down")
		).normalized()
	
	play_cur_animation()

func take_damage(damage: int):
	if is_dead:
		return # no need to calc death again, lol
	cur_health -= damage
	if cur_health <= 0:
		die()
	else: # start iframes
		is_invunerable = true
		is_hit = true
		anim.play("hit_right" if is_facing_right else "hit_left")
		#start timer
		iframe_timer.start(iframe_time)

func use_weapon():
	if is_attacking:
		return
	is_attacking = true
	cur_weapon.attack()

func _on_attack_done():
	is_attacking = false

func die():
	emit_signal("player_died")
	await(anim.play("death_right" if is_facing_right else "death_left"))
	#TODO: Trigger GameOver/Score Screen

func _on_iframe_timeout():
	is_invunerable = false

func _on_animation_finished():
	if is_hit:
		is_hit = false
		play_cur_animation()

#Play Correct animation based on facing
func play_cur_animation():
	if not is_hit: #Don't change animation if playing hit animation
		#determine direction
		is_facing_right = aim_direction.x >= 0
		
		if velocity.length() == 0:
			anim.play("idle_right" if is_facing_right else "idle_left")
		else:
			anim.play("run_right" if is_facing_right else "run_left")
