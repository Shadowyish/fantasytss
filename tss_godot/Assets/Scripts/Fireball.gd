extends Node2D

@export var speed: float
@export var damage: int
@export var destroy_time: float #the amount of time till the fireball should be destroyed

var fired_angle: float # angle for fireball to travel
var has_hit = false

@onready var destroy_timer = Timer.new()
@onready var explosion_radius = $Explosion
@onready var anim = $Animator

func _ready():
	#Timer intialization
	add_child(destroy_timer)
	destroy_timer.one_shot = true
	destroy_timer.connect("timeout", _on_fireball_timeout)
	
	destroy_timer.start(destroy_time)
	$Hitbox.body_entered.connect(_on_body_entered)
	rotation = fired_angle + (PI/2)

func _physics_process(delta):
	if not has_hit: 
		position += Vector2.RIGHT.rotated(fired_angle) * speed * delta

func _on_fireball_timeout():
	explode()

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		destroy_timer.stop()
		has_hit = true
		explode()

func explode():
	scale = Vector2(3,3)
	for body in explosion_radius.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
	anim.play("explode")
	await(anim.animation_finished)
	queue_free()
