extends Node2D

@export var speed: float
@export var damage: int
@export var destroy_time: float #the amount of time till the bolt should be destroyed
@export var max_jumps: int

var fired_angle: float # angle for bolt to travel
var has_hit = false
var hit_targets: Array
var next_target: CharacterBody2D

@onready var destroy_timer = Timer.new()
@onready var max_radius = $Radius
@onready var anim = $Animator

func _ready():
	#Timer intialization
	add_child(destroy_timer)
	destroy_timer.one_shot = true
	destroy_timer.connect("timeout", _on_bolt_timeout)
	
	destroy_timer.start(destroy_time)
	$Hitbox.body_entered.connect(_on_body_entered)
	rotation = fired_angle + (PI/2)

func _physics_process(delta):
	if has_hit: 
		if is_instance_valid(next_target):
			fired_angle = (next_target.global_position - global_position).normalized().angle()
	position += Vector2.RIGHT.rotated(fired_angle) * speed * delta 

func _on_bolt_timeout():
	queue_free()

func _on_body_entered(body):
	if !body.is_in_group("Player") and !(body in hit_targets):
		if !has_hit:
			destroy_timer.stop()
			hit_targets = [body]
			has_hit = true
			$LightningTrail.emitting = true
			$LightningSparks.emitting = true
		else: 
			hit_targets.append(body)
			$LightningSparks.restart()
		body.take_damage(damage)
		max_jumps -= 1
		if max_jumps <= 1:
			queue_free()
		damage = max(damage/2, 1)
		next_target = chain()

func chain():
	var new_target = find_closest_enemy_not_in(hit_targets, global_position)
	if new_target:
		return new_target
	else:
		queue_free()
	
func find_closest_enemy_not_in(targets_to_ignore: Array, start_pos: Vector2)-> CharacterBody2D: 
	var closest_body: CharacterBody2D
	for body in max_radius.get_overlapping_bodies():
		if body.is_in_group("Player"):
			continue
		if body.has_method("take_damage") and not body in targets_to_ignore:
			if not closest_body:
				closest_body = body
			else:
				if start_pos.distance_to(closest_body.global_position) > start_pos.distance_to(body.global_position):
					closest_body = body
	return closest_body
