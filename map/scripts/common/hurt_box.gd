extends Area2D

signal dead2

@onready var timer = $Timer

func _ready():
	print("Connecting timer...")
	$Timer.timeout.connect(_on_timer_timeout)
	
func _on_body_entered(body):
	if body.name == "Player":
		dead2.emit()
		Engine.time_scale = 0.5
		timer.start(1.0)
		
func _on_timer_timeout():
	print("Reloading scene")
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
