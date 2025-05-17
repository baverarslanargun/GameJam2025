extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$AnimatedSprite2D.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("push"):
		visible = true
		$AnimatedSprite2D.play("push")
		$AnimatedSprite2D.visible = true
	elif Input.is_action_pressed("pull"):
		visible = true
		$AnimatedSprite2D.play("pull")
		$AnimatedSprite2D.visible = true
	else:
		visible = false
		$AnimatedSprite2D.visible = false
