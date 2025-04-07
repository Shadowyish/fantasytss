extends Weapon
@export var special_time: float #amount of time the special lasts

@onready var anim = $Animator
@onready var special_timer: Timer = Timer.new()

func _ready():
	add_child(special_timer)
	special_timer.one_shot = true
	special_timer.connect("timeout", end_special)
	
func attack():
	anim.play("attack")
	await(anim.animation_finished)
	
	var arrow = load("res://Assets/Prefabs/Arrow.tscn").instantiate()
	arrow.global_position = global_position
	arrow.fired_angle = rotation
	get_tree().current_scene.add_child(arrow)
	emit_signal("attack_finished")
	
func special():
	GameManager.player.speed *= 2
	special_timer.start(special_time)
	
func end_special():
	GameManager.player.speed /=2
	emit_signal("attack_finished")
