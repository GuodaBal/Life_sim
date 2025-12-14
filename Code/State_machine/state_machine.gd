extends Node
class_name StateMachine

var states = {}
var current_state : State
@export var starting_state : State

#Adds nodes to state list, enters starting state
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.switch_state.connect(on_state_switch)
	
	if starting_state:
		starting_state.enter()
		current_state = starting_state

#Calls update on current state
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

#Calls physics update on current state
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

#Switches states
func on_state_switch(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name)
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
