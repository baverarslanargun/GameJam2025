extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_scaled_up = false
var base_scale = Vector2.ONE


func _ready() -> void:
	base_scale = scale
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("main"):
		Global.previous_scene_path = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file("res://scenes/common/splash.tscn")
	if Input.is_action_just_pressed("restart"):
		Global.previous_scene_path = get_tree().current_scene.scene_file_path
		get_tree().change_scene_to_file(Global.previous_scene_path)
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if is_on_floor():
			$AnimatedSprite2D.play("Walk")
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			$AnimatedSprite2D.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if not is_on_floor():
		$AnimatedSprite2D.play("Jump")

	move_and_slide()
	
func perform_growth_effect():
	is_scaled_up = true
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale * 2, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base_scale * 3, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func shrink_character():
	is_scaled_up = false
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale * 0.5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_portal_bescaled() -> void:
	var tween = create_tween()
	if is_scaled_up:
		tween.tween_property(self, "scale", base_scale * 2, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", base_scale * 3, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "scale", base_scale * 0.5, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
