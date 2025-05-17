extends CharacterBody2D

@export var is_positive := true  # True = Posibot, False = Negabot
@export var move_speed := 80.0
@export var detection_range := 300.0
@export var chase := false

var player

func _ready():
	player = get_tree().get_root().get_node("Game/CharacterBody2D")  # ya da Player
	$Area2D.connect("body_entered", _on_detected)
	$Area2D.connect("body_exited", _on_lost)

func _physics_process(delta):
	if not chase:
		velocity.x = 0
		return

	var direction = (player.global_position - global_position).normalized()

	# Zıt kutuplu mantık
	if is_positive:
		# Uzaklaşır → pozitif kutuplar iter
		velocity = -direction * move_speed
	else:
		# Negatif kutup → yaklaşır
		velocity = direction * move_speed

	move_and_slide()

func _on_detected(body):
	if body == player:
		chase = true

func _on_lost(body):
	if body == player:
		chase = false
