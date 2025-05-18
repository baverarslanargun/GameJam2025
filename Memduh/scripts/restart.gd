extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.001).timeout  # 0.2 saniye bekle
	if Global.previous_scene_path != "":
		get_tree().change_scene_to_file(Global.previous_scene_path)
