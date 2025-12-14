extends Node

class_name State

signal switch_state

#Called when entering state
func enter():
	pass

#Called when exiting state
func exit():
	pass

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	pass
