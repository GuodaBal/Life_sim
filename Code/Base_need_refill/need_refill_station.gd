extends Area2D
class_name NeedRefillStation

@export var need_refilled = "placeholder"
@export var time_taken = 5.0
@export var refilled_per_second = 1.0

@onready var action_completion_timer := $ActionCompletionTime
@onready var need_fill_interval_timer := $NeedFillInterval

var current_user = null
@export var personality_buffs : Dictionary[Personality.PersonalityTrait, float]

func _ready() -> void:
	action_completion_timer.wait_time = time_taken

func use(user):
	current_user = user
	action_completion_timer.start()
	need_fill_interval_timer.start()

func _on_action_completion_time_timeout() -> void:
	current_user.action_finished()
	current_user = null
	need_fill_interval_timer.stop()

func _on_need_fill_interval_timeout() -> void:
	current_user.fill_need(need_refilled, refilled_per_second)

func is_busy():
	if current_user:
		return true
	else:
		return false
