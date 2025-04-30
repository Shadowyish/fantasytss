extends CharacterBody2D

@export var speed: float
@export var health: int
@export var mana: int
@export var cur_weapon: Node

var cur_mana: int
var cur_health: int
var aim_direction = Vector2.RIGHT
var iframe_time: float = 0.67
var is_invunerable = false
var is_dead = false
var is_hit = false
var is_facing_right = true
var is_attacking = false
var controller_deadzone = .2

signal player_died

#Using a timer for iframes to make it unblocking
@onready var iframe_timer = Timer.new()
@onready var anim = $Animator

func _ready():
	cur_health = health
	cur_mana = mana
	
	# timer hookups
	add_child(iframe_timer)
	iframe_timer.one_shot = true
	iframe_timer.connect("timeout", _on_iframe_timeout)
	
	# hit animation hookup
	anim.animation_finished.connect(_on_animation_finished)
	
	# Subscribe to weapon listener
	cur_weapon.connect("attack_finished", _on_attack_done)
	
	GameManager.player = self

func _physics_process(delta):
	if is_dead or GameManager.game_mode == GameManager.GameMode.Pause:
		return
	var input_vector = Vector2.ZERO
	# Get movement input then normalize to prevent speed boost
	input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_vector * speed * delta
	var collision = move_and_collide(velocity)
	if collision:
		#TODO Implement character hit logic
		pass
	
	# Get rotation direction
	if GameManager.input_type == GameManager.ControlType.MOUSE_KEYBOARD:
		aim_direction = (get_global_mouse_position() - global_position).normalized()
	elif GameManager.input_type == GameManager.ControlType.GAMEPAD:
		var stick_input = Input.get_vector("right_stick_left", "right_stick_right",
				"right_stick_up", "right_stick_down", .2)
		if stick_input.length() > controller_deadzone:
			aim_direction = stick_input.normalized()
	
	#move weapon to face aim direction when it's not in use
	if not is_attacking:
		cur_weapon.position = aim_direction * cur_weapon.pixels_from_player 
		cur_weapon.rotation = aim_direction.angle()
	
	play_cur_animation()

func _process(_delta):
	if is_dead or GameManager.game_mode == GameManager.GameMode.Pause:
		return
	if Input.is_action_pressed("attack"):
		use_weapon()
	if Input.is_action_just_pressed("special"):
		use_weapon_special()

func take_damage(damage: int):
	if is_dead or is_invunerable:
		return # no need to calc death or deal damage again lol
	cur_health -= damage
	
	if cur_health <= 0:
		die()
	else: # start iframes
		is_invunerable = true
		is_hit = true
		anim.play("hit_right" if is_facing_right else "hit_left")
		#start timer
		iframe_timer.start(iframe_time)

func heal(hp: int):
	cur_health = clampi(cur_health + hp, 0, health)

func gain_mana(m: int):
	cur_mana = clampi(cur_mana + m, 0, mana)

func use_weapon():
	if is_attacking:
		return
	is_attacking = true
	cur_weapon.attack()

func _on_attack_done():
	is_attacking = false

func die():
	is_dead = true
	emit_signal("player_died")
	anim.play("death_right" if is_facing_right else "death_left")
	await(anim.animation_finished)
	#TODO: Trigger GameOver/Score Screen
	cur_weapon.queue_free()

func _on_iframe_timeout():
	is_invunerable = false

func _on_animation_finished():
	if is_hit:
		is_hit = false
		play_cur_animation()

#Play Correct animation based on facing
func play_cur_animation():
	if is_hit or is_dead: #Don't change animation if playing another animation
		return
	#determine direction
	is_facing_right = aim_direction.x >= 0
	
	if velocity.length() == 0:
		anim.play("idle_right" if is_facing_right else "idle_left")
	else:
		anim.play("run_right" if is_facing_right else "run_left")

func use_weapon_special():
	if is_attacking or cur_mana < cur_weapon.mana_cost:
		return
	is_attacking = true
	cur_mana -= cur_weapon.mana_cost
	cur_weapon.special()
	
func pickup_weapon(weapon: Node):
	var trash = cur_weapon
	remove_child(trash)
	trash.queue_free() 
	weapon.reparent(self)
	cur_weapon = weapon
	weapon.global_position = global_position
	weapon.has_player = true
	weapon.connect("attack_finished", _on_attack_done)
