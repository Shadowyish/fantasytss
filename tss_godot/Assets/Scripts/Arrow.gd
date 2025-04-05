extends Node2D

@export var arrow_speed: float
@export var pierce_limit: int
@export var damage: int
@export var destroy_time: float #the amount of time till the arrow should be destroyed

var fired_angle: float # angle for arrow to travel

@onready var destroy_timer = Timer.new()

func _ready():
	#Timer intialization
	add_child(destroy_timer)
	destroy_timer.one_shot = true
	destroy_timer.connect("timeout", _on_arrow_timeout)
	
	destroy_timer.start(destroy_time)
	$Area2D.body_entered.connect(_on_body_entered)
	rotation = fired_angle + (PI/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += Vector2.RIGHT.rotated(fired_angle) * arrow_speed * delta

func _on_arrow_timeout():
	queue_free()

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		body.take_damage(damage)
		pierce_limit -= 1
		if pierce_limit <= 0:
			queue_free()
