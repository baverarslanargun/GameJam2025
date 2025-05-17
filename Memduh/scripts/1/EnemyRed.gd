extends CharacterBody2D

@onready var playerPos = get_node("/root/Game/Player")
@export var speed: float = 150.0
@export var gravity: float = 980.0
@export var is_magnetic: bool = true
@export var attack_cooldown: float = 0.8  # Time between attacks

var player: CharacterBody2D = null
var chasing: bool = false
var can_attack: bool = true

func _ready() -> void:
	$Area2D.body_entered.connect(_on_area_body_entered)
	$Area2D.body_exited.connect(_on_area_body_exited)
	
	# Add collision detection for actual hits
	if has_node("HitBox"):
		$HitBox.body_entered.connect(_on_hitbox_body_entered)
	
	add_to_group("magnetic")

func _on_area_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		chasing = true
		$AnimatedSprite2D.play("Chase")  # Assuming you have animations

func _on_area_body_exited(body: Node) -> void:
	if body == player:
		chasing = false
		player = null
		$AnimatedSprite2D.play("Idle")  # Back to idle when not chasing

func _on_hitbox_body_entered(body: Node) -> void:
	# Only apply knockback when the player touches the enemy's hitbox
	# and when the enemy can attack
	if body.name == "Player" and can_attack and body.has_method("apply_knockback"):
		print("Enemy hit player! Applying knockback from position:", global_position)
		body.apply_knockback(global_position)
		
		# Start attack cooldown
		can_attack = false
		var timer = get_tree().create_timer(attack_cooldown)
		timer.timeout.connect(func(): can_attack = true)
		
		# Optional: Visual feedback for the enemy
		modulate = Color(1.2, 1.2, 0.8)  # Flash slightly
		var flash_timer = get_tree().create_timer(0.1)
		flash_timer.timeout.connect(func(): modulate = Color(1, 1, 1))
		
		

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity on floor

	# Chasing movement
	if chasing and player:
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * speed
		
		# Flip sprite based on direction
		if direction.x != 0:
			$AnimatedSprite2D.scale.x = -1 if direction.x < 0 else 1
	else:
		# Slow down when not chasing
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
