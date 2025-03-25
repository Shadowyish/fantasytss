extends CharacterBody2D

@export var speed: float = 1.0
@export var damage: int = 10  # Damage dealt when colliding with the player
@export var hp: int = 10
@export var score: int = 10

var player = null
var is_dead = false

@onready var detection_area = $CollisionShape2D

func _ready():
	#get player reference
	player = GameManager.player
	
func _physics_process(delta):
	if not player:
		push_error("Enemy could not find player. Make sure GameManager has valid player instance.")
		return
	if is_dead:
		return
	
	var direction = (player.global_position - global_position).normalized()
	# Move towards the player
	velocity = direction * speed * delta
	var collision = move_and_collide(velocity)
	
	#Do damage if we collided with the player
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			body.take_damage(damage)

func take_damage(dmg: int):
	if is_dead:
		# Do nothing if enemy is already dead
		# In case if still in death animations
		return
	
	hp -= dmg
	if hp <= 0:
		die()

func die():
	is_dead = true
	play_death_animation()
	GameManager.increase_score(score)
	
	await(get_tree().create_timer(.25).timeout)
	queue_free() #Remove from scene

func play_death_animation():
	# TODO: Play Death Animation/Effect
	pass
