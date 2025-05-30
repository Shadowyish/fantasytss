extends Weapon

@export var damage: int
@export var swing_speed: float  # Speed of the swing
@export var swing_radius: float # Distance from player
@export var swing_duration: float # Total duration of the swing
@export var special_regen_amount: int # amount special should heal each tick
@export var special_regen_time: float # How long should the special last
@export var special_regen_tick: float # time between ticks

var is_swinging = false
var swing_timer: float #used internally to see how long we've been swinging
var swing_start: Vector2 #used to store orginal position during swing, for angle and return
var swing_angle: float # Angle offset for the swing

@onready var hp_regen_timer: Timer = Timer.new()
@onready var hp_regen_ticker: Timer = Timer.new()
@onready var heal_effect: CPUParticles2D = $HealParticles #holds particle effect for special

func attack():
	if is_swinging:
		return  # Prevent multiple swings
	swing_start = position
	is_swinging = true
	swing_timer = 0.0
	
func special():
	if hp_regen_timer.is_stopped():
		hp_regen_ticker.start(special_regen_tick)
		hp_regen_timer.start(special_regen_time)
		#move heal particles to player
		remove_child(heal_effect)
		GameManager.player.add_child(heal_effect)
		heal_effect.global_position = GameManager.player.global_position
		heal_effect.emitting = true
	else:
		hp_regen_timer.start(hp_regen_timer.time_left + special_regen_time)
	emit_signal("attack_finished")
	
func end_special():
	hp_regen_ticker.stop()
	heal_effect.emitting = false
	GameManager.player.remove_child(heal_effect)
	add_child(heal_effect)
	
func _process(delta):
	if is_swinging and has_player:
		swing_timer += delta
		var progress = swing_timer / swing_duration
		if progress >= 1.0:
			is_swinging = false
			position = swing_start  # Reset sword position
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
	
	# timer hookups
	add_child(hp_regen_timer)
	hp_regen_timer.one_shot = true
	hp_regen_timer.connect("timeout", end_special)
	
	add_child(hp_regen_ticker)
	hp_regen_ticker.connect("timeout", GameManager.player.heal.bind(special_regen_amount))
	
func _on_body_entered(body):
	if has_player:
		if !body.is_in_group("Player"):
			body.take_damage(damage)
	elif body.is_in_group("Player"):
		GameManager.player.pickup_weapon(self)
