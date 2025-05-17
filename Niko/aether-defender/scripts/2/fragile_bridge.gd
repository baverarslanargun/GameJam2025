extends StaticBody2D

# --- CONFIGURABLE VARIABLES ---
@export var max_supported_weight: float = 20.0  # Maximum total weight the bridge can hold

# --- NODES ---
@onready var sprite: Sprite2D = $Sprite  # Visual appearance of the bridge
@onready var bridge_collision: CollisionShape2D = $CollisionShape2D  # Collider for the bridge surface
@onready var detection_area: Area2D = $Area2D  # Detects objects on the bridge
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Optional, for break animation

# --- INTERNAL STATE ---
var current_total_weight: float = 0.0
var bodies_on_bridge: Dictionary = {}
var bridge_broken: bool = false

func _ready() -> void:
	# Verify that detection_area is properly set up
	if not detection_area:
		push_error("Area2D node not found! Ensure there is an 'Area2D' node as a direct child of this StaticBody2D.")
		return

	# Connect Area2D signals to detect bodies entering/exiting
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if bridge_broken:
		return

	# Only process bodies named "Player" with a get_weight method
	if body.name == "Player" and body.has_method("get_weight"):
		var weight: float = body.get_weight()
		current_total_weight += weight
		bodies_on_bridge[body] = weight
		print("✅ Player Entered: ", body.name, " | Weight: ", weight, " | Total: ", current_total_weight)
		_check_weight()

func _on_body_exited(body: Node2D) -> void:
	if bridge_broken:
		return

	# Remove Player from tracking if it was on the bridge
	if body.name == "Player" and body in bodies_on_bridge:
		var weight: float = bodies_on_bridge[body]
		current_total_weight -= weight
		bodies_on_bridge.erase(body)
		print("⬅️ Player Exited: ", body.name, " | Removed: ", weight, " | Total: ", current_total_weight)

func _check_weight() -> void:
	# Break the bridge if total weight exceeds the limit
	if current_total_weight > max_supported_weight:
		_break_bridge()

func _break_bridge() -> void:
	bridge_broken = true
	print("💥 Bridge broke! Total weight: ", current_total_weight)

	# Disable collision to prevent further interaction
	bridge_collision.disabled = true

	# Play break animation if available
	if animation_player:
		animation_player.play("break")

	# Visual feedback: turn sprite red
	sprite.modulate = Color(1, 0, 0)
