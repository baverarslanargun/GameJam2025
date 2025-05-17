extends Area2D

func _ready():
	# h*ook the signal properly
	add_to_group("coins")
	connect("body_entered", Callable(self, "_on_body_entered"))
	# or if your script is on the Area2D itself, this also works:
	# connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/Game/GameManager").add_coin()
		queue_free()
