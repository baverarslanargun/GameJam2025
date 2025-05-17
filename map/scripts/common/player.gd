extends CharacterBody2D

@onready var health1 = get_node("/root/Game/CanvasLayer/HBoxContainer2/TextureRect");
@onready var health2 = get_node("/root/Game/CanvasLayer/HBoxContainer2/TextureRect2");
@onready var health3 = get_node("/root/Game/CanvasLayer/HBoxContainer2/TextureRect3");

signal death



func _ready():
	if is_inside_tree():
		death.connect(get_node("/root/Game")._on_player_death)

const SPEED = 300.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 980.0  # Added explicit gravity constant

var facingRight = true
var health = 3
var knockback_timer := 0.0
var knockback_strength := 300.0  # Make this configurable

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle knockback with priority
	if knockback_timer > 0:
		knockback_timer -= delta
		# Don't let player control during knockback
		move_and_slide()
		return  # Exit early to prevent player control
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
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

func apply_knockback(from_position: Vector2) -> void:
	var direction = (global_position - from_position).normalized()
	
	# More powerful knockback with vertical component
	velocity.x = direction.x * knockback_strength
	velocity.y = min(velocity.y, -knockback_strength * 0.5)  # Add upward force
	
	# Set knockback timer - make player unable to control for this duration
	knockback_timer = 0.3
	
	# Log for debugging
	print("Player knockback applied! Direction:", direction, " Velocity:", velocity)
	
	# Visual feedback
	modulate = Color(1, 0.5, 0.5)  # Flash red
	
	# Create a timer to restore normal color
	var timer = get_tree().create_timer(0.2)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	
	# Optionally reduce health
	health -= 1
	if(health == 2):
		health1.visible = false;
	if(health == 1):
		health2.visible = false;
	if(health == 0):
		health3.visible = false;
		death.emit()
		
	
	print("Player health reduced to:", health)



func get_weight():
	return 30.0 
