extends Node
class_name Relationship

var agent_name
var agent_id
var value = 50

signal value_changed

func _init(a_name, a_id) -> void:
	agent_id = a_id
	agent_name = a_name

func add_value(addition):
	value += addition
	value = clamp(value, 0.0, 100.0)
	value_changed.emit()
