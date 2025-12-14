extends StaticBody2D
class_name FurnitureItem

@export var action_queue : Array[Action]

@export var need_refilled = "placeholder"
@export var time_taken = 5.0
@export var refilled_per_second = 1.0

@export var personality_buffs : Dictionary[Personality.PersonalityTrait, float]
@export var busy_when_used = false  #!!Currently used because there are no items, so for furniture
#like a fridge or bookshelf, they are not considered busy while the agent 'uses' them, because they 
#are supposed to be using something they took from them (food, book)

var is_busy = false

func use(agent):
	if busy_when_used:
		is_busy = true

func stop_using():
	is_busy = false

#These variables show what need is filled and how much by using them
func get_variables():
	return {"need_refilled" : need_refilled, "time_taken" : time_taken, 
	"refilled_per_second" : refilled_per_second, "personality_buffs" : personality_buffs}
