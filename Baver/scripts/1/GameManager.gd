extends Node

var coin_count: int = 0

func add_coin():
	coin_count += 1
	update_ui()

func update_ui():
	var label = get_node("../CanvasLayer/Label")
	label.text = "Coins: %d" % coin_count
