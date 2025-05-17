extends Node
@onready var music_player = $AudioStreamPlayer
var intro_music = preload("res://assets/sounds/BossIntro.wav")
var loop_music = preload("res://assets/sounds/BossMain.wav")

func _ready():
	music_player.stream = intro_music
	music_player.play()
	music_player.finished.connect(_on_music_finished)

func _on_music_finished():
	music_player.stream = loop_music
	# Set the loop property on the stream itself, not the player
	loop_music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_player.play()
	music_player.finished.disconnect(_on_music_finished)
