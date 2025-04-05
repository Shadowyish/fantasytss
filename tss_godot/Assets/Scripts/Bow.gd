extends Weapon

@onready var anim = $Animator

func _ready():
	pixels_from_player = 10
	
func attack():
	anim.play("attack")
	await(anim.animation_finished)
	
	var arrow = load("res://Assets/Prefabs/Arrow.tscn").instantiate()
	arrow.global_position = global_position
	arrow.fired_angle = rotation
	get_tree().current_scene.add_child(arrow)
	emit_signal("attack_finished")
