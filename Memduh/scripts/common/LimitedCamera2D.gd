#LimitedCamera2D.gd

extends Camera2D

# The distance from the left edge where camera starts following
@export var follow_start_x: float = 400.0
# When true, camera starts following player horizontally
var follow_horizontally: bool = false

# Get the player node (parent of this camera)
@onready var player = get_parent()

func _ready():
	# Keep the camera fixed at starting position
	set_process(true)
	
	# Set initial camera position 
	# We're assuming the camera is a child of the player
	position = Vector2.ZERO # Local position relative to player is zero
	
	# But we want the global position to show the start of the level
	var initial_camera_x = 200.0 # Starting X position of the camera view
	var initial_camera_y = global_position.y # Keep Y the same
	
	# Hard-set global transform to put camera at starting view position
	global_transform.origin = Vector2(initial_camera_x, initial_camera_y)
	
	# Disable position smoothing if you have it enabled
	position_smoothing_enabled = false
	
	print("Camera initialized with fixed position:", global_position)
	print("Follow distance threshold:", follow_start_x)

func _process(delta):
	if player == null:
		return
	
	if !follow_horizontally:
		# Check if player has passed the threshold to start following
		if player.global_position.x > follow_start_x:
			follow_horizontally = true
			print("Player passed threshold, camera now following horizontally")
	
	if follow_horizontally:
		# Update camera position to follow player, but only horizontally
		global_position.x = player.global_position.x
	
	# Always follow vertically regardless of horizontal threshold
	global_position.y = player.global_position.y
	
	if follow_horizontally:
		# Check if player has moved back past the threshold
		if player.global_position.x < follow_start_x:
			follow_horizontally = false
			# Fix camera position at threshold
			global_position.x = follow_start_x
			print("Player moved back, camera fixed again")
		else:
			# Follow player horizontally
			global_position.x = player.global_position.x
