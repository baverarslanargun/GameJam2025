extends Area2D

func _physics_process(delta: float) -> void:
	if len(get_overlapping_bodies()) > 0:
		queue_free()
