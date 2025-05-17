extends Node

# grab the label once, at startup
@onready var coin_label: Label = get_node("/root/Game/CanvasLayer/HBoxContainer/Label")

var coin_count: int = 0
var total_count: int = 0

func _ready() -> void:
	total_count = get_tree().get_nodes_in_group("coins").size()
	_update_label()

func add_coin():
	coin_count += 1
	_update_label()

func _update_label() -> void:
	# ör: “3 / 12”
	coin_label.text = "%d / %d" % [coin_count, total_count]
