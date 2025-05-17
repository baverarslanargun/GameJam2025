extends CharacterBody2D

@onready var playerPos = get_node("/root/Game/Player")
@export var speed: float = 150.0
@export var gravity: float = 980.0
@export var is_magnetic: bool = true
@export var attack_cooldown: float = 0.8  # Time between attacks
@export var damage_radius: float = 25.0   # How close the enemy needs to be to damage player

var player: CharacterBody2D = null
var chasing: bool = false
var can_attack: bool = true
var attack_check_timer: float = 0.0

func _ready() -> void:
	# Setup detection area
	$Area2D.body_entered.connect(_on_area_body_entered)
	$Area2D.body_exited.connect(_on_area_body_exited)
	
	# Make sure HitBox exists
	_setup_hitbox()
	
	add_to_group("magnetic")

func _setup_hitbox() -> void:
	# Create a proper hitbox if it doesn't exist
	if not has_node("HitBox"):
		var hitbox = Area2D.new()
		hitbox.name = "HitBox"
		add_child(hitbox)
		
		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = damage_radius
		collision.shape = shape
		hitbox.add_child(collision)
		
		# Connect the signal
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		print("Created HitBox for enemy")
	else:
		# Make sure the existing hitbox has the signal connected
		if not $HitBox.is_connected("body_entered", _on_hitbox_body_entered):
			$HitBox.body_entered.connect(_on_hitbox_body_entered)
		print("Using existing HitBox")

func _on_area_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		chasing = true
		
		# Check if AnimatedSprite2D exists
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("Chase")
		print("Player detected by enemy")

func _on_area_body_exited(body: Node) -> void:
	if body == player:
		chasing = false
		player = null
		
		# Check if AnimatedSprite2D exists
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("Idle")
		print("Player left enemy detection area")

func _on_hitbox_body_entered(body: Node) -> void:
	print("HitBox detected collision with: ", body.name)
	
	# Only apply knockback when the player touches the enemy's hitbox
	# and when the enemy can attack
	if body.name == "Player" and can_attack:
		if body.has_method("apply_knockback"):
			print("ENEMY HIT PLAYER! Applying knockback from position:", global_position)
			body.apply_knockback(global_position)
			
			# Start attack cooldown
			can_attack = false
			var timer = get_tree().create_timer(attack_cooldown)
			timer.timeout.connect(func(): 
				can_attack = true
				print("Enemy can attack again")
			)
			
			# Visual feedback for the enemy
			modulate = Color(1.5, 1.5, 0.5)  # Flash brighter
			var flash_timer = get_tree().create_timer(0.2)
			flash_timer.timeout.connect(func(): modulate = Color(1, 1, 1))
		else:
			print("ERROR: Player doesn't have apply_knockback method!")

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
		if has_node("AnimatedSprite2D") and direction.x != 0:
			$AnimatedSprite2D.scale.x = -1 if direction.x < 0 else 1
			
		# Manual collision check timer
		attack_check_timer -= delta
		if attack_check_timer <= 0:
			attack_check_timer = 0.1  # Check every 0.1 seconds
			check_for_player_collision()
	else:
		# Slow down when not chasing
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

# Manual check for player collision in case area signals aren't reliable
func check_for_player_collision() -> void:
	if not player or not can_attack:
		return
		
	var distance = global_position.distance_to(player.global_position)
	if distance < damage_radius:
		print("Manual collision check - Player in damage radius!")
		_on_hitbox_body_entered(player)
