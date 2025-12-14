extends State

@export var character : Agent

#Called when entering state
func enter():
	#Checking what kind of goal we have, and either fullfill it or move on to idle state
	if !character.current_goal:
		call_deferred("action_finished")
	elif character.current_goal is UseAction:
		character.current_goal.use_item.use(character)
		var variables = character.current_goal.use_item.get_variables()
		character.start_need_refill(variables)
	elif character.current_goal.is_in_group("Seat"):
		character.current_goal.use()
		character.sit(character.current_goal)
		call_deferred("action_finished")
	elif character.current_goal is ChatAction: #!!Duplicate with UseAction, should be adjusted
		character.current_goal.chat_with.chat(character)
		var variables = character.current_goal.chat_with.get_variables()
		character.start_need_refill(variables)
	else:
		call_deferred("action_finished")

#Called when exiting state
func exit():
	if character.current_goal is ChatAction:
		var conversation = Conversation.new()
		conversation.resolve_conversation(character, character.current_goal.chat_with)
		conversation.queue_free()
	if character.current_goal is UseAction:
		character.current_goal.use_item.stop_using()
	if character.is_sleeping:
		character.wake_up()
	#Marking the current goal as completed, and moving on to next one
	character.current_goal = null
	character.goal_queue.pop_front()

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	pass

func action_finished():
	switch_state.emit(self, "Idle")
