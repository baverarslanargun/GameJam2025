extends Area2D

signal dead2

func _on_body_entered(body):
	if body.name == "Player":
		dead2.emit()
