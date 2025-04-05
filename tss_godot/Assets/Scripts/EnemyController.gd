extends CharacterBody2D

@export var speed: float
@export var damage: int  # Damage dealt when colliding with the player
@export var hp: int
@export var score: int

var player = null
var is_dead = false
var is_hit = false
var is_spawning = true
var is_facing_right = true
var direction = Vector2.RIGHT

@onready var detection_area = $CollisionShape2D
@onready var anim = $Animator

func _ready():
	#get player reference
	player = GameManager.player
	
func _physics_process(delta):
	if not player:
		push_error("Enemy could not find player. Make sure GameManager has valid player instance.")
		return
	if is_dead:
		return
	if is_spawning:
		await(anim.animation_finished)
		is_spawning = false
		return
	
	direction = (player.global_position - global_position).normalized()
	# Move towards the player
	velocity = direction * speed * delta
	var collision = move_and_collide(velocity)
	
	#Do damage if we collided with the player
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			body.take_damage(damage)
	
	play_cur_animation()

func take_damage(dmg: int):
	if is_dead:
		# Do nothing if enemy is already dead
		# In case if still in death animations
		return
	
	hp -= dmg
	if hp <= 0:
		die()
		return
	is_hit = true
	anim.play("hit_right" if is_facing_right else "hit_left")
	await(anim.animation_finished)
	is_hit = false

func die():
	is_dead = true
	GameManager.increase_score(score)
	GameManager.enemy_count -= 1
	anim.play("death_right" if is_facing_right else "death_left")
	await(anim.animation_finished)
	queue_free() #Remove from scene

func play_cur_animation():
	if is_hit or is_dead: #Don't change animation if playing another animation
		return
	#determine direction
	is_facing_right = direction.x >= 0
	
	anim.play("run_right" if is_facing_right else "run_left")
