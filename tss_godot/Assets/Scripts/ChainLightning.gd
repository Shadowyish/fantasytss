extends Node2D

@export var speed: float
@export var damage: int
@export var destroy_time: float #the amount of time till the bolt should be destroyed
@export var max_jumps: int

var fired_angle: float # angle for bolt to travel
var has_hit = false
var hit_targets: Array

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
	if !has_hit:
		position += Vector2.RIGHT.rotated(fired_angle) * speed * delta

func _on_bolt_timeout():
	queue_free()

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		destroy_timer.stop()
		hit_targets = [body]
		has_hit = true
		anim.visible = false
		chain()

func chain():
	for i in range(max_jumps):
		var last_target = hit_targets[-1]
		var new_target = find_closest_enemy_not_in(hit_targets, last_target.global_position)
		if new_target:
			hit_targets.append(new_target)
			new_target.take_damage(damage)
			animate_lightning(last_target, new_target)
		else:
			break
	queue_free()
	
func find_closest_enemy_not_in(targets_to_ignore: Array, starting_position: Vector2)-> CharacterBody2D: 
	var closest_body: CharacterBody2D
	for body in max_radius.get_overlapping_bodies():
		if body.has_method("take_damage") and not body in targets_to_ignore:
			if not closest_body:
				closest_body = body
			else:
				if starting_position.distance_to(closest_body.global_position) > starting_position.distance_to(body):
					closest_body = body
	return closest_body
	
func animate_lightning(start_position: Vector2, end_position: Vector2):
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color.WHITE
	line.position = Vector2.ZERO
	get_tree().current_scene.add_child(line)

	var points = []
	var segment_count = 8
	for i in range(segment_count + 1):
		var t = i / segment_count
		var pos = start_position.lerp(end_position, t)
		if i != 0 and i != segment_count:
			pos += Vector2(randf() - 0.5, randf() - 0.5) * 20  # Random jagged offset
		points.append(pos)
	line.points = points
	global_position = end_position

	# Remove after short delay
	await get_tree().create_timer(0.15).timeout
	line.queue_free()
