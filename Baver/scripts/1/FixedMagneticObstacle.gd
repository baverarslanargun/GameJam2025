# FixedMagneticObstacle.gd
extends StaticBody2D

@export var magnetic: bool = true
@export var magnetic_strength: float = 1.0  # How strongly it responds to magnetic fields

func _ready():
	# Add to the "magnetic" group so your magnet script can detect it
	if magnetic:
		add_to_group("magnetic")
