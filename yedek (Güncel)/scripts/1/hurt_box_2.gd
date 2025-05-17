extends Area2D

signal dead

func _on_body_entered(body):
	print("test2")
	if body.name == "Player":
		dead.emit()
