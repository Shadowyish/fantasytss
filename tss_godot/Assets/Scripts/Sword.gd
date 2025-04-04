extends Weapon

@export var damage: int = 10
@export var swing_angle = 0.0  # Angle offset for the swing
@export var swing_speed = 20.0  # Speed of the swing
@export var swing_radius = 30  # Distance from player
@export var swing_duration = 0.5  # Total duration of the swing

var swinging = false
var swing_timer = 0.0
var swing_start: Vector2

func attack():
	if swinging:
		return  # Prevent multiple swings
	swing_start = position
	swinging = true
	swing_timer = 0.0
	
func _process(delta):
	if swinging:
		swing_timer += delta
		var progress = swing_timer / swing_duration
		if progress >= 1.0:
			swinging = false
			position = Vector2.ZERO  # Reset sword position
			emit_signal("attack_finished")
			return
		# Swing from -45° to +45°
		swing_angle = lerp(-PI / 3 + swing_start.angle(), PI / 3 + swing_start.angle(), progress)
		#Actually Swing
		position =  Vector2(swing_radius, 0).rotated(swing_angle)
		# Rotate sword to match movement
		rotation = swing_angle
	
func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if not body.is_in_group("Player"):
		body.take_damage(damage)
