extends Area2D

var hadpass = false
signal bescaled


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(get_overlapping_bodies())>0 and not hadpass:
		hadpass = true
		bescaled.emit()
	elif len(get_overlapping_bodies()) == 0 and hadpass:
		hadpass = false
