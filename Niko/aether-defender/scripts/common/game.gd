extends Node2D

func _ready():
	$AudioStreamPlayer.stream = preload("res://assets/sounds/Boss.ogg")
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.finished.connect(func():
		$AudioStreamPlayer.play()
	)


func _on_hurt_box_2_dead() -> void:
	%CanvasLayer2.visible = true
	get_tree().paused = true


func _on_player_death() -> void:
	%CanvasLayer2.visible = true
	get_tree().paused = true


func _on_hurt_box_dead_2() -> void:
	%CanvasLayer2.visible = true
	get_tree().paused = true
