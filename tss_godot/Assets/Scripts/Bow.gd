extends Weapon
@export var special_time: float #amount of time the special lasts
@export var pierce_count: int # num of enemies arrow should pierce through, should be atleast 1

@onready var anim = $Animator
@onready var aoe_effect: CPUParticles2D = $AOEParticles
@onready var special_timer: Timer = Timer.new()

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	
	add_child(special_timer)
	special_timer.one_shot = true
	special_timer.connect("timeout", end_special)
	
func attack():
	anim.play("attack")
	await(anim.animation_finished)
	
	var arrow = load("res://Assets/Prefabs/Arrow.tscn").instantiate()
	arrow.global_position = global_position
	arrow.fired_angle = rotation
	arrow.pierce_limit = pierce_count
	get_tree().current_scene.add_child(arrow)
	emit_signal("attack_finished")
	
func special():
	if special_timer.is_stopped():
		GameManager.player.speed *= 2
		special_timer.start(special_time)
	else:
		special_timer.start(special_timer.time_left + special_time)
	for body in $SpecialArea.get_overlapping_bodies():
		if !body.is_in_group("Player"):
			body.take_damage(15)
	emit_signal("attack_finished")
	
func end_special():
	GameManager.player.speed /=2

func _on_body_entered(body):
	if body.is_in_group("Player") and !has_player:
		GameManager.player.pickup_weapon()
