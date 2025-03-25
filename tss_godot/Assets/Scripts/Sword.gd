extends Weapon

@export var damage: int = 10

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func attack():
	var start_position = position
	var arc_end_position = start_position + Vector2(100, 0).rotated(rotation)  # End position of the arc
	var arc_mid_position = start_position + Vector2(50, 50).rotated(rotation)  # Midway point of the arc
	
	# Animate the sword to swing in an arc, using tweening.
	var tween = create_tween()
	# 1st phase: moving towards the midway point
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", arc_mid_position, 0.25)
	
	# 2nd phase: moving towards the end of the arc
	tween.tween_property(self, "position", arc_end_position, 0.5)

	# 3rd phase: returning the sword to the original position
	tween.tween_property(self, "position", start_position, 0.25)
	
	#Rotate the sword slightly simletaneously while swinging
	tween.set_parallel()
	tween.tween_property(self, "rotation", rotation + 0.5, 0.5)
	tween.tween_property(self, "rotation", rotation - 0.5, 0.5)
	await(tween.finished)
	emit_signal("attack_finished")

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		body.take_damage(damage)
