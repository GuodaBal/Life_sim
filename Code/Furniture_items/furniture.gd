extends StaticBody2D
class_name FurnitureItem

@export var action_queue : Array[Action]

@export var need_refilled = "placeholder"
@export var time_taken = 5.0
@export var refilled_per_second = 1.0

@export var busy_when_used = false  #Temporary
#@onready var action_completion_timer := $ActionCompletionTime
#@onready var need_fill_interval_timer := $NeedFillInterval

var current_user = null
var is_busy = false
@export var personality_buffs : Dictionary[Personality.PersonalityTrait, float]

#func _ready() -> void:
	#action_completion_timer.wait_time = time_taken
#
func use(agent):
	if busy_when_used:
		is_busy = true
	#current_user = user
	#action_completion_timer.start()
	#need_fill_interval_timer.start()

func stop_using():
	is_busy = false

func get_variables():
	return {"need_refilled" : need_refilled, "time_taken" : time_taken, 
	"refilled_per_second" : refilled_per_second, "personality_buffs" : personality_buffs}

#func _on_action_completion_time_timeout() -> void:
	#current_user.action_finished()
	#current_user = null
	#need_fill_interval_timer.stop()
#
#func _on_need_fill_interval_timeout() -> void:
	#var personality_bonus = 0
	#for buff in personality_buffs.keys():
		#personality_bonus += current_user.character.personality.get_value_by_name(buff)
	#if personality_bonus == 0: #If there are no buffs, make the multiplyer 1
		#personality_bonus = 1
	#current_user.fill_need(need_refilled, refilled_per_second * personality_bonus)
