extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "CharacterBody2D":  # ya da Player node'unun adı neyse
		get_node("/root/Game/GameManager").add_coin()
		queue_free()
