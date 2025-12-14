extends Node2D
class_name NeedRefiller

@export var agent : Agent

@onready var action_completion_timer := $ActionCompletionTime
@onready var need_fill_interval_timer := $NeedFillInterval

var need_refilled = "placeholder"
var time_taken = 5.0
var refilled_per_second = 1.0
var refill_amount = 0.0

func set_variables(variables):
	#!!Could change variables to be an object, having as array is flimsy and easy to get wrong order
	start_refill(variables["need_refilled"], variables["time_taken"], variables["refilled_per_second"], variables["personality_buffs"])

#Refills the agents need, according to given variables
func start_refill(new_need_refilled, new_time_taken, new_refilled_per_second, new_personality_buffs):
	var personality_bonus = 0
	for buff in new_personality_buffs.keys():
		personality_bonus += agent.personality.get_value_by_name(buff)
	if personality_bonus == 0: #If there are no buffs, make the multiplier 1
		personality_bonus = 1
	refill_amount = new_refilled_per_second * personality_bonus
	
	need_refilled = new_need_refilled
	time_taken = new_time_taken
	refilled_per_second = new_need_refilled
	
	action_completion_timer.wait_time = time_taken
	action_completion_timer.start()
	need_fill_interval_timer.start()

func _on_action_completion_time_timeout() -> void:
	agent.done_refilling()
	need_fill_interval_timer.stop()

func _on_need_fill_interval_timeout() -> void:
	agent.fill_need(need_refilled, refill_amount)
