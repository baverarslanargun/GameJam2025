extends Camera2D

# Path to your player node
@export_node_path var player_path
# Where camera starts following
@export var follow_threshold_x: float = 400.0
# Initial camera position
@export var start_camera_x: float = 200.0

var player: Node2D
var following: bool = false

func _ready():
	# Get the player node
	player = get_node(player_path)
	
	# Set initial camera position
	global_position = Vector2(start_camera_x, 0)
	if player:
		global_position.y = player.global_position.y
	
	# Make this camera current
	make_current()
	
	print("Standalone camera initialized at:", global_position)

func _process(delta):
	if player == null:
		return
	
	# Always follow vertical position
	global_position.y = player.global_position.y
	
	if !following:
		# Only start following horizontally after player reaches threshold
		if player.global_position.x >= follow_threshold_x:
			following = true
			print("Player reached threshold, camera following horizontally")
	
	if following:
		global_position.x = player.global_position.x
	
