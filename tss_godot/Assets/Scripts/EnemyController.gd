extends CharacterBody2D

@export var speed: float = 100.0
@export var damage: int = 10  # Damage dealt when colliding with the player
@export var hp: int = 10

var player = null

@onready var detection_area = $CollisionArea

func _ready():
	#get player reference
	player = GameManager.player
	# Connect the Area2D signals for when the player enters the area
	detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
	#Just in case, here is how to track the exit of player from area...
	#detection_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		# Move towards the player
		velocity = direction * speed
		move_and_slide()
	else:
		push_error("Enemy could not find player. Make sure GameManager has valid player instance.")

func _on_body_entered(body):
	if body.is_in_group("players"):
		player.take_damage(damage)

func take_damage(dmg: int):
	hp -= dmg
	if hp <= 0:
		die()

func die():
	#TODO: Implement Enemy Death
	pass

