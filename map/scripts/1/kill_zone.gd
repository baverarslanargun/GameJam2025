extends Area2D

func _on_body_entered(body):
	if body == "CharacterBody2D":
		print("You died") # Replace with function body.
