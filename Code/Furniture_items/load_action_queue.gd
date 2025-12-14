extends Node2D

@onready var furniture_item := $Base_furniture_item

func _ready() -> void:
	var action_queue = [Action]
	for child in get_children():
		if child is Action:
			action_queue[child.order_number] = child
			print_debug(child)
	furniture_item.action_queue = action_queue
