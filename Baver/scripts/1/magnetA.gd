extends Area2D

@export var push_force: float = 5000.0  # Increased force
@export var pull_force: float = 4000.0  # Increased force
@export var affect_radius: float = 200.0
var player 

func _ready() -> void:
	visible = false
	print("Magnet initialized with radius:", affect_radius)
	print("Push force:", push_force, "Pull force:", pull_force)
	player = get_node("/root/Game/CharacterBody2D")

func _physics_process(delta: float) -> void:
	# Get the mouse position and calculate direction
	var mouse_pos = get_global_mouse_position()
	var direction = global_position.direction_to(mouse_pos)
	
	# Set the rotation to face the mouse
	rotation = direction.angle()
	
	if Input.is_action_pressed("push") or Input.is_action_pressed("pull"):
		visible = true
		
		# Get all RigidBody2D nodes in the scene
		var bodies = get_tree().get_nodes_in_group("magnetic")
		if bodies.size() > 0:
			print("Found", bodies.size(), "magnetic bodies")
		else:
			print("WARNING: No magnetic bodies found!")
		
		for body in bodies:
			if body is RigidBody2D:
				print("Processing body:", body.name)
				print("  - Body position:", body.global_position)
				print("  - Magnet position:", global_position)
				
				var distance = $CollisionShape2D.global_position.distance_to(body.global_position)
				print("  - Distance:", distance, "Radius:", affect_radius)
				
				if distance <= affect_radius and body.mass < 30:
					# For lighter objects, move the object
					var force_dir = global_position.direction_to(body.global_position)
					var force_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius))
					
					print("  - Force direction:", force_dir)
					print("  - Force strength:", force_strength)
					print("  - Body mass:", body.mass)
					
					# Try using impulse instead of force for more immediate effect
					if Input.is_action_pressed("push"):
						var impulse = force_dir * push_force * force_strength * 0.1
						body.apply_central_impulse(impulse)
						print("  - Pushing with impulse:", impulse)
					elif Input.is_action_pressed("pull"):
						var impulse = -force_dir * pull_force * force_strength * 0.1
						body.apply_central_impulse(impulse)
						print("  - Pulling with impulse:", impulse)
				
				elif distance <= affect_radius and body.mass >= 30:
					# For heavy objects, move the player instead
					var move_dir = global_position.direction_to(body.global_position) * -1
					var move_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius))
					
					# Calculate a direct movement vector for the player
					var move_speed = 150.0  # Adjust this value as needed
					
					if Input.is_action_pressed("push"):
						# Move the player away from the heavy object
						var move_vector = move_dir * move_speed * move_strength
						player.velocity = move_vector  # Set directly to override current movement
						print("  - Moving player with velocity:", move_vector)
					elif Input.is_action_pressed("pull"):
						# This would pull the player toward the heavy object
						var move_vector = -move_dir * move_speed * move_strength
						player.velocity = move_vector  # Set directly to override current movement
						print("  - Moving player with velocity:", move_vector)
						
					# Make sure character moves by forcing a move_and_slide call
					player.move_and_slide()
				else:
					print("  - Body out of range!")
			else:
				print("Body is not a RigidBody2D:", body.name)
	else:
		visible = false
