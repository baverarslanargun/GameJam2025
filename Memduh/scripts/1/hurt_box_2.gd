extends Area2D

signal dead

func _on_body_entered(body):
	if body.name == "Player":
		dead.emit()
