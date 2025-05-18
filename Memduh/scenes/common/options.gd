extends TextureButton


func _ready() -> void:
	pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/common/options.tscn")
