extends State

@export var character : Agent

#Called when entering state
func enter():
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
		print_debug("using seat")
	elif character.current_goal is ChatAction:
		print_debug("Chat action")
		character.current_goal.chat_with.chat(character)
		var variables = character.current_goal.chat_with.get_variables()
		character.start_need_refill(variables)
	else:
		print_debug("Finished aciton")
		call_deferred("action_finished")

#Called when exiting state
func exit():
	if character.current_goal is ChatAction:
		var conversation = Conversation.new()
		conversation.resolve_conversation(character, character.current_goal.chat_with)
		conversation.queue_free()
	if character.current_goal is UseAction:
		character.current_goal.use_item.stop_using()
	#if character.sitting_on && character.goal_queue.size() <= 1:
		#character.stop_sitting()
	if character.is_sleeping:
		character.wake_up()
	character.current_goal = null
	character.goal_queue.pop_front()

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	pass

func fill_need(need_name, fill_amount):
	pass
	#character.fill_need(need_name, fill_amount)

func action_finished():
	switch_state.emit(self, "Idle")
