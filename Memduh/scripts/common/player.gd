extends CharacterBody2D

@onready var health1 = get_node("/root/Game/CanvasLayer/HBoxContainer2/TextureRect")
@onready var health2 = get_node("/root/Game/CanvasLayer/HBoxContainer2/TextureRect2")
@onready var health3 = get_node("/root/Game/CanvasLayer/HBoxContainer2/TextureRect3")

signal death

const SPEED = 300.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 980.0

var facingRight = true
var health = 3
var knockback_timer := 0.0
var knockback_strength := 500.0  # Increased strength for more noticeable effect
var invincibility_timer := 0.0   # Added invincibility after taking damage
var was_on_floor := false        # Track floor state for better jumping

func _ready():
	if is_inside_tree():
		death.connect(get_node("/root/Game")._on_player_death)

func _physics_process(delta: float) -> void:
	was_on_floor = is_on_floor()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle invincibility
	if invincibility_timer > 0:
		invincibility_timer -= delta
		# Flash effect during invincibility
		var flash_visible = int(invincibility_timer * 10) % 2 == 0
		modulate.a = 0.4 if flash_visible else 1.0
	else:
		modulate.a = 1.0
	
	# Handle knockback with priority
	if knockback_timer > 0:
		knockback_timer -= delta
		
		if knockback_timer <= 0:
			# When knockback ends, add a small boost if in air
			if not is_on_floor():
				velocity.y = min(velocity.y, 0)  # Reset downward velocity
				
		# Don't let player control during knockback
		move_and_slide()
		return  # Exit early to prevent player control
	
	# Handle jump with better buffering
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or was_on_floor: # Allow slight jump forgiveness
			velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("Jump")
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		if is_on_floor():
			$AnimatedSprite2D.play("Walk")
		velocity.x = direction * SPEED
		if direction < 0 and facingRight:
			scale.x *= -1
			facingRight = false
		elif direction > 0 and not facingRight:
			scale.x *= -1
			facingRight = true
	else:
		if is_on_floor():
			$AnimatedSprite2D.play("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func apply_knockback(from_position: Vector2) -> void:
	# If already in knockback or invincible, don't apply again
	if knockback_timer > 0 or invincibility_timer > 0:
		return
	
	var direction = (global_position - from_position).normalized()
	
	# More powerful knockback with vertical component
	velocity.x = direction.x * knockback_strength
	velocity.y = -knockback_strength * 0.6  # Stronger upward force
	
	# Set knockback timer - make player unable to control for this duration
	knockback_timer = 0.3
	invincibility_timer = 1.0  # 1 second of invincibility after being hit
	
	# Log for debugging
	print("Player knockback applied! Direction:", direction, " Velocity:", velocity)
	
	# Visual feedback - stronger flash
	modulate = Color(1, 1, 1)  # Brighter red
	
	# Create a timer to restore normal color
	var timer = get_tree().create_timer(0.2)
	timer.timeout.connect(func(): 
		if invincibility_timer <= 0:  # Only reset if not still invincible
			modulate = Color(1, 1, 1)
	)
	
	# Play hit sound if available
	if has_node("HitSound"):
		$HitSound.play()
	
	# Reduce health
	health -= 1
	if health == 2:
		health1.visible = false
	if health == 1:
		health2.visible = false
	if health == 0:
		health3.visible = false
		death.emit()
	
	print("Player health reduced to:", health)

# Add a collision shape for player's hitbox
func _ready_setup_hitbox():
	# This function can be called to ensure player has proper collision setup
	if not has_node("Hitbox"):
		var hitbox = Area2D.new()
		hitbox.name = "Hitbox"
		add_child(hitbox)
		
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(30, 60)  # Adjust based on sprite size
		shape.shape = rect
		hitbox.add_child(shape)
		
		print("Added hitbox to player")
