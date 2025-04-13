extends Node

@export var mana: int

func _ready():
	$PickupRange.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.gain_mana(mana)
		GameManager.mana_pickup_count -= 1
		queue_free()
