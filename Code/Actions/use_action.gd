extends Action
class_name UseAction

@export var use_item : Node

func validate():
	if use_item:
		return true
	return false
