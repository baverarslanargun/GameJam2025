#rigid_body_2d.gd
extends RigidBody2D

# Make it available to the Inspector
@export var is_magnetic: bool = true

func _ready() -> void:
	# Add to magnetic group
	add_to_group("magnetic")
	
	# Make sure physics are
