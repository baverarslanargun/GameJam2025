extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var facingRight = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		$AnimatedSprite2D.play("Walk")
		velocity.x = direction * SPEED
		if direction < 0 and facingRight:
			scale.x *= -1
			facingRight = false
		elif direction > 0 and not facingRight:
			scale.x *= -1
			facingRight = true
	else:
		$AnimatedSprite2D.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
