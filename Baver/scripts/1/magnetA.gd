#magnetA.gd

extends Area2D

@export var push_force: float = 5000.0
@export var pull_force: float = 4000.0
@export var affect_radius: float = 200.0

@export var push_sfx: AudioStream
@export var pull_sfx: AudioStream

var player

@onready var sfx_player: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	visible = false
	print("Magnet initialized with radius:", affect_radius)
	print("Push force:", push_force, "Pull force:", pull_force)
	player = get_node("/root/Game/CharacterBody2D")

func _physics_process(delta: float) -> void:  # Fixed function name here
	# Get the mouse position and calculate direction
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos);
	
	visible = false
	$AnimatedSprite2D.visible = false
	
	if Input.is_action_pressed("push"):
		visible = true
		$AnimatedSprite2D.play("push")
		$AnimatedSprite2D.visible = true
		# push sesi ata ve çal
		sfx_player.stream = push_sfx
		sfx_player.play()
		apply_magnetic_force(true)
	elif Input.is_action_pressed("pull"):
		visible = true
		$AnimatedSprite2D.play("pull")
		$AnimatedSprite2D.visible = true
		# pull sesi ata ve çal
		sfx_player.stream = pull_sfx
		sfx_player.play()
		apply_magnetic_force(false)

func apply_magnetic_force(is_push: bool) -> void:
	# Get all nodes in the "magnetic" group
	var bodies = get_tree().get_nodes_in_group("magnetic")
	
	for body in bodies:
		var distance = $CollisionShape2D.global_position.distance_to(body.global_position)
		
		if distance <= affect_radius:
			var force_dir = global_position.direction_to(body.global_position)
			var force_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius))
			
			if body is RigidBody2D:
				if body.mass < 30:
					# For lighter objects, apply impulse to the object
					var impulse_force = push_force if is_push else pull_force
					var impulse_dir = force_dir if is_push else -force_dir
					var impulse = impulse_dir * impulse_force * force_strength * 0.1
					
					body.apply_central_impulse(impulse)
				else:
					# For heavy objects, move the player instead
					var move_dir = -force_dir  # Direction away from heavy object
					var move_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius))
					var move_speed = 150.0
					
					if is_push:
						# Move the player away from the heavy object
						var move_vector = move_dir * move_speed * move_strength
						player.velocity = move_vector
					else:
						# Pull the player toward the heavy object
						var move_vector = -move_dir * move_speed * move_strength
						player.velocity = move_vector
					
					# Make sure character moves
					player.move_and_slide()
			
			elif body is StaticBody2D:
				# For fixed obstacles, move the player based on magnetic interaction
				var magnetic_str = 1.0
				if body.has_method("get_magnetic_strength"):
					magnetic_str = body.get_magnetic_strength()
				elif body.get("magnetic_strength") != null:
					magnetic_str = body.magnetic_strength
				
				# Calculate move direction (reversed from the magnetic field direction)
				var move_dir = -force_dir if is_push else force_dir
				var move_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius)) * magnetic_str
				var move_speed = 200.0
				
				# Apply the calculated force to player
				var move_vector = move_dir * move_speed * move_strength
				player.velocity = move_vector
				
				# Make sure character moves
				player.move_and_slide()
				
				# Notify the obstacle of magnetic interaction (for effects)
				if body.has_method("highlight_magnetic_influence"):
					body.highlight_magnetic_influence(force_strength * magnetic_str)
