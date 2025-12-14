extends State

@export var character : Agent
@export var line_of_sight : Area2D

@onready var check_next_goal_timer := $CheckForNextGoal

#Called when entering state
func enter():
	#character.current_goal = null
	if character.goal_queue.is_empty(): #If current goal is done, search for new one
		check_next_goal_timer.start()
	elif !character.is_awaiting_social: #&& !character.current_goal:
		#call_deferred("fullfill_goal", character.goal_queue.pop_front())
		call_deferred("fullfill_goal", character.goal_queue[0])
	#else: #If a character came in with a current goal, it means they were interrupted or could
		  ##not complete it, this gives a chance to finish it
		#call_deferred("fullfill_goal", character.current_goal)

#Called when exiting state
func exit():
	check_next_goal_timer.stop()

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	pass

#func _on_check_for_next_goal_timeout() -> void:
	#var possible_objects_list = []
	#var visibly_busy_objects = []
	#for area in line_of_sight.get_overlapping_areas():
		#if area.is_in_group("Furniture") && area.is_busy():
			#visibly_busy_objects.append(area)
	#for child in get_tree().get_nodes_in_group("Furniture"):
		##if !child.is_busy():
			##if !visibly_busy_objects.has(child):
		#possible_objects_list.append(child)
	#var priority_points = {}
	#var need_priority = {}
	#for need in character.needs_list:
		#need_priority[need.need_name] = need.priority
	#for item in possible_objects_list:
		#var distance = character.pathfinding.get_path_between_points(character.position, item.position).size()
		#var personality_bonus = 0
		#for buff in item.personality_buffs.keys():
			#personality_bonus += character.personality.get_value_by_name(buff) * item.personality_buffs[buff]
		#if personality_bonus == 0: #If there are no buffs, make the multiplyer 1
			#personality_bonus = 1
		#var points = need_priority[item.need_refilled] * item.refilled_per_second * personality_bonus + clamp((100.0/distance) * 0.3, 0, 2)
		#priority_points[points] = item
	#priority_points.sort()
	#character.current_goal = priority_points[priority_points.keys()[-1]]
	#character.goal_queue = character.current_goal.action_queue.duplicate()
	#fullfill_goal_queue()

func _on_check_for_next_goal_timeout() -> void:
	if character.is_awaiting_social:
		return
	var possible_objects_list = []
	for furniture in get_tree().get_nodes_in_group("Furniture"):
		if !furniture.is_busy:
			possible_objects_list.append(furniture)
	for agent in get_tree().get_nodes_in_group("Agent"):
		if agent != character && !agent.is_busy():
			possible_objects_list.append(agent)
	var priority_points = {}
	var need_priority = {}
	for need in character.needs_list:
		need_priority[need.need_name] = need.priority #Get how high of a priority each need is currently at
	for item in possible_objects_list:
		print_debug("possible object")
		print_debug(item)
		var distance = character.pathfinding.get_path_between_points(character.position, item.global_position, false).size()
		var personality_bonus = 0
		for buff in item.personality_buffs.keys():
			personality_bonus += character.personality.get_value_by_name(buff) * item.personality_buffs[buff] #Weighted average
		if personality_bonus == 0: #If there are no buffs, make the multiplyer 1
			personality_bonus = 1
		#print_debug("personality bonus", personality_bonus)
		#var points = need_priority[item.need_refilled] * item.refilled_per_second * personality_bonus
		var points = need_priority[item.need_refilled] * item.refilled_per_second * personality_bonus + clamp((100.0/distance) * 0.1, 0, 2)
		#print_debug(points)
		priority_points[points] = item
	priority_points.sort()
	if priority_points.size() <= 0:
		switch_state.emit(self, "Idle")
	else:
		character.current_goal = priority_points[priority_points.keys()[-1]] #Picking goal with highest key value
		if character.current_goal is Agent:
			character.current_goal.await_social(true)
		character.goal_queue = character.current_goal.action_queue.duplicate()
		#fullfill_goal(character.goal_queue.pop_front())
		fullfill_goal(character.goal_queue[0])

#func fullfill_goal_queue():
	#var goal = character.goal_queue.pop_front()
	##print_debug(goal, character)
	#if goal is SitAction:
		#if goal.sit_in_area:
			#for item in goal.sit_in_area.get_overlapping_areas(): #Looks for seat in seating area
				#if item.is_in_group("Seat") && !item.is_busy:
					#character.current_goal = item
					#switch_state.emit(self, "Seeking")
					##print_debug("going to seat in area", item, character)
					#return
			#character.current_goal = goal.sit_in_area
			#switch_state.emit(self, "Seeking") #If there is no seat, walk to area
			##fullfill_goal_queue() #If there is no seat, moves on to next step
		#else: #If there is no specific seating area, find closest seat
			#var closest_seat = null
			#var smallest_distance = INF
			#for seat in get_tree().get_nodes_in_group("Seat"):
				##print_debug("possible seat", seat)
				#var path = character.pathfinding.get_path_between_points(character.position, seat.position, false)
				##print_debug("path", path)
				#if path.size() < smallest_distance && path.size() > 0 && !seat.is_busy:
					#smallest_distance = path.size()
					#closest_seat = seat
			#if closest_seat:
				#character.current_goal = closest_seat
				#switch_state.emit(self, "Seeking")
				##print_debug("going to seat", closest_seat, character)
				#return
			#fullfill_goal_queue() #If there's no seat, move on to next step
	#elif goal is SeekAction:
		#character.current_goal = goal.item
		##print_debug("seeking", character.current_goal, character)
		#switch_state.emit(self, "Seeking")
	#elif goal is UseAction:
		#character.current_goal = goal
		##print_debug("using", character.current_goal, character)
		#switch_state.emit(self, "Busy")
	#elif goal is ChatAction:
		#character.current_goal = goal
		#switch_state.emit(self, "Busy")
	
func fullfill_goal(goal):
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
					#print_debug("going to seat in area", item, character)
					return
			character.current_goal = goal.sit_in_area
			switch_state.emit(self, "Seeking") #If there is no seat, walk to area
			#fullfill_goal_queue() #If there is no seat, moves on to next step
		else: #If there is no specific seating area, find closest seat
			#If character is already sitting, move on to next goal
			if character.sitting_on:
				character.goal_queue.pop_front()
				fullfill_goal(character.goal_queue[0])
				return
			var closest_seat = null
			var smallest_distance = INF
			for seat in get_tree().get_nodes_in_group("Seat"):
				#print_debug("possible seat", seat)
				var path = character.pathfinding.get_path_between_points(character.position, seat.position, false)
				#print_debug("path", path)
				if path.size() < smallest_distance && path.size() > 0 && !seat.is_busy:
					smallest_distance = path.size()
					closest_seat = seat
			if closest_seat:
				character.current_goal = closest_seat
				switch_state.emit(self, "Seeking")
				#print_debug("going to seat", closest_seat, character)
				return
			#fullfill_goal(character.goal_queue.pop_front())
			character.goal_queue.pop_front()
			fullfill_goal(character.goal_queue[0])
			#fullfill_goal_queue() #If there's no seat, move on to next step
	elif goal is SeekAction:
		character.current_goal = goal.item
		#print_debug("seeking", character.current_goal, character)
		switch_state.emit(self, "Seeking")
	elif goal is UseAction:
		character.current_goal = goal
		#print_debug("using", character.current_goal, character)
		switch_state.emit(self, "Busy")
	elif goal is ChatAction:
		character.current_goal = goal
		switch_state.emit(self, "Busy")
