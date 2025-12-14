extends State

@export var character : Agent
@export var line_of_sight : Area2D

@onready var check_next_goal_timer := $CheckForNextGoal

#Called when entering state
func enter():
	if character.goal_queue.is_empty(): #If current goal is done, search for new one
		check_next_goal_timer.start()
	#Agent is stopped from fullfilling next goal if someone is coming to chat
	elif !character.is_awaiting_social: 
		call_deferred("fullfill_goal", character.goal_queue[0])

#Called when exiting state
func exit():
	check_next_goal_timer.stop()

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	pass

func _on_check_for_next_goal_timeout() -> void:
	if character.is_awaiting_social: #Cannot look for next goal while waiting for/currently chatting
		return
	
	#Adding all non busy objects to a list of possible goals
	var possible_objects_list = []
	for furniture in get_tree().get_nodes_in_group("Furniture"):
		if !furniture.is_busy:
			possible_objects_list.append(furniture)
	for agent in get_tree().get_nodes_in_group("Agent"):
		if agent != character && !agent.is_busy():
			possible_objects_list.append(agent)
	
	#If there are no possible things to do, stay in idle and wait for next timeout
	if possible_objects_list.size() <= 0:
		return
	
	#Calculating priority of each object
	var priority_points = {}
	var need_priority = {}
	for need in character.needs_list:
		#Get how high of a priority each need is currently at
		need_priority[need.need_name] = need.priority 
	for item in possible_objects_list:
		var distance = character.pathfinding.get_path_between_points(character.position, item.global_position, false).size()
		var personality_bonus = 0
		for buff in item.personality_buffs.keys():
			personality_bonus += character.personality.get_value_by_name(buff) * item.personality_buffs[buff] #Weighted average
		if personality_bonus == 0: #If there are no buffs, make the multiplier 1
			personality_bonus = 1
		
		var points = need_priority[item.need_refilled] * item.refilled_per_second * personality_bonus + clamp((100.0/distance) * 0.1, 0, 2)
		priority_points[points] = item
	
	priority_points.sort()
	#Picking goal with highest priority value
	character.current_goal = priority_points[priority_points.keys()[-1]]
	#If our goal is an agent, we tell it to wait until we get there to chat
	if character.current_goal is Agent:
		character.current_goal.await_social(true)
	character.goal_queue = character.current_goal.action_queue.duplicate()
	fullfill_goal(character.goal_queue[0])

#Checks what kind of goal we passed and passes off information so next state can fullfill it
func fullfill_goal(goal):
	#If the agent needs to sit, an available seat needs to be found
	if goal is SitAction:
		if goal.sit_in_area:
			#If character is already sitting in needed area, move on to next goal
			if character.sitting_on && character.sitting_on.overlaps_area(goal.sit_in_area):
				character.goal_queue.pop_front()
				fullfill_goal(character.goal_queue[0])
				return
			for item in goal.sit_in_area.get_overlapping_areas(): #Looks for seat in seating area
				if item.is_in_group("Seat") && !item.is_busy:
					character.current_goal = item
					switch_state.emit(self, "Seeking")
					return
			character.current_goal = goal.sit_in_area
			switch_state.emit(self, "Seeking") #If there is no seat, walk to area
		else: #If there is no specific seating area, find closest seat
			#If character is already sitting, move on to next goal
			if character.sitting_on:
				character.goal_queue.pop_front()
				fullfill_goal(character.goal_queue[0])
				return
			
			var closest_seat = null
			var smallest_distance = INF
			for seat in get_tree().get_nodes_in_group("Seat"):
				var path = character.pathfinding.get_path_between_points(character.position, seat.position, false)
				if path.size() < smallest_distance && path.size() > 0 && !seat.is_busy:
					smallest_distance = path.size()
					closest_seat = seat
			if closest_seat:
				character.current_goal = closest_seat
				switch_state.emit(self, "Seeking")
				return
			#If there's no seat available, move on to next goal
			character.goal_queue.pop_front()
			fullfill_goal(character.goal_queue[0])
	#!!Repeating code, kinda. Not too important, but could maybe change
	elif goal is SeekAction:
		character.current_goal = goal.item
		switch_state.emit(self, "Seeking")
	elif goal is UseAction || ChatAction:
		character.current_goal = goal
		switch_state.emit(self, "Busy")
