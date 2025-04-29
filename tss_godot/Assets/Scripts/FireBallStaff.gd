extends Weapon

@export var damage: int
@export var swing_speed: float  # Speed of the swing
@export var swing_radius: float # Distance from player
@export var swing_duration: float # Total duration of the swing

var is_swinging = false
var swing_timer = 0.0
var swing_start: Vector2
var swing_angle: float # Angle offset for the swing

func attack():
	if is_swinging:
		return  # Prevent multiple swings
	swing_start = position
	is_swinging = true
	swing_timer = 0.0
	
func _process(delta):
	if is_swinging:
		swing_timer += delta
		var progress = swing_timer / swing_duration
		if progress >= 1.0:
			is_swinging = false
			position = Vector2.ZERO  # Reset sword position
			emit_signal("attack_finished")
			return
		# Swing from -45° to +45°
		swing_angle = lerp(-PI / 2 + swing_start.angle(), PI / 2 + swing_start.angle(), progress)
		#Actually Swing
		position =  Vector2(swing_radius, 0).rotated(swing_angle)
		# Rotate sword to match movement
		rotation = swing_angle
	
func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if not body.is_in_group("Player"):
		body.take_damage(damage)
	elif !has_player:
		GameManager.player.pickup_weapon()

func special():
	var fireball = load("res://Assets/Prefabs/Fireball.tscn").instantiate()
	fireball.global_position = global_position
	fireball.fired_angle = rotation
	get_tree().current_scene.add_child(fireball)
	emit_signal("attack_finished")
