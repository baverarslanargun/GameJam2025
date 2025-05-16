extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("push ") or Input.is_action_pressed("pull"):
		visible = true
	else:
		visible = false
