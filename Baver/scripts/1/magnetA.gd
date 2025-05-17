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
					var force_dir = global_position.direction_to(body.global_position)
					var force_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius))
					
					print("  - Force direction:", force_dir)
					print("  - Force strength:", force_strength)
					print("  - Body mass:", body.mass)
					print("  - Body mode:", body.freeze_mode)
					print("  - Body sleeping:", body.sleeping)
					
					if Input.is_action_pressed("push"):
						var force = force_dir * push_force * force_strength
						body.apply_central_force(force)
						print("  - Pushing with force:", force)
					elif Input.is_action_pressed("pull"):
						var force = -force_dir * pull_force * force_strength
						body.apply_central_force(force)
						print("  - Pulling with force:", force)
				
				elif distance <= affect_radius and body.mass >= 30:
					# For heavy objects, move the player instead
					var force_dir = global_position.direction_to(body.global_position) * -1
					var force_strength = lerp(0.0, 1.0, 1.0 - (distance / affect_radius))
					
					# For CharacterBody2D, we need to modify velocity rather than apply force
					if Input.is_action_pressed("push"):
						var push_vector = force_dir * push_force * force_strength * delta * 0.01
						player.velocity += push_vector
						print("  - Player pushed with velocity change:", push_vector)
					elif Input.is_action_pressed("pull"):
						var pull_vector = -force_dir * pull_force * force_strength * delta * 0.01
						player.velocity += pull_vector
						print("  - Player pulled with velocity change:", pull_vector)
				else:
					print("  - Body out of range!")
			else:
				print("Body is not a RigidBody2D:", body.name)
	else:
		visible = false
