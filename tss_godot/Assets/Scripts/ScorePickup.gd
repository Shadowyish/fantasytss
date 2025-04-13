extends Node

@export var score: int

func _ready():
	$PickupRange.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.increase_score(score)
		GameManager.score_pickup_count -= 1
		queue_free()
