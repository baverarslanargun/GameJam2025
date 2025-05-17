extends CharacterBody2D

@onready var playerPos = get_node("/root/Game/Player")
@export var speed: float = 150.0
@export var gravity: float = 980.0  # Yerçekimi değeri (pixel/s²)
@export var is_magnetic: bool = true
var player: CharacterBody2D = null
var chasing: bool = false

func _ready() -> void:
	$Area2D.body_entered.connect(_on_area_body_entered)
	$Area2D.body_exited.connect(_on_area_body_exited)
	add_to_group("magnetic")

func _on_area_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		chasing = true

func _on_area_body_exited(body: Node) -> void:
	if body == player:
		chasing = false
		player = null

func _physics_process(delta: float) -> void:
	# Gravity uygula
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # opsiyonel, zıplama yoksa
	# Takip hareketi
	if chasing and player:
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * speed
		if direction.x != 0:
			$AnimatedSprite2D.scale.x = -1 if direction.x < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
