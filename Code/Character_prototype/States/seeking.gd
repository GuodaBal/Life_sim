extends State

@export var character : Agent
@export var line_of_sight : Area2D
@export var pos : Node2D #The position used for calculations instead of the agents actual position.
						 #Since agents block off the node they are standing on for pathfinding, they
						 #cannot find a path if they are searching from the middle of themselves
@export var personal_bubble : Area2D
@export var communication_area : Area2D

var path : Array
var distance_to_point_reached = 7
var direction

#Called when entering state
func enter():
	#Need to check if we arrived before getting up, so we don't stand up
	#then go into idle before moving anywhere, therefore blocking the seat
	if check_if_arrived() || check_if_goal_busy():
		return
		
	if character.sitting_on:
		character.stop_sitting()

	path = character.pathfinding.get_path_between_points(pos.global_position, character.current_goal.global_position, true)

#Called when exiting state
func exit():
	pass

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	#Can't walk if we are waiting for someone to come chat
	if character.is_awaiting_social:
		return
	
	#Stop walking if we already arrived or our goal was busy
	if check_if_arrived() || check_if_goal_busy():
		return
	
	#Get a new path each frame, as other agents moving block and unblock paths
	path = character.pathfinding.get_path_between_points(pos.global_position, character.current_goal.global_position, true)
	
	var next_position
	if path.size() > 1:
		next_position = path[1]
	#Sometimes pathfinding stops before fully reaching goal - in that case, character heads straight
	#towards it
	elif abs((character.global_position - character.current_goal.global_position).length()) > distance_to_point_reached:
		next_position = character.current_goal.global_position
	
	if next_position:
		var personal_space_vector = Vector2(0,0)
		#Checking for any agents in our personal bubble and creating a vector facing away from them
		for area in personal_bubble.get_overlapping_areas():
			if area.get_parent() is not Agent:
				continue
			var agent = area.get_parent() as Agent
			#If the agents aren't predicted to collide, don't add them to the calculation
			if !will_agents_collide(character.position, character.current_direction * character.current_speed, agent.position, agent.current_direction * agent.current_speed):
				continue
			var predicted_future_position = agent.position + agent.current_direction * agent.current_speed
			var agent_position = area.get_parent().position
			#Vector gets stronger the closer the agents are
			var personal_space_strength = 1 / (character.position.distance_to(predicted_future_position))
			personal_space_vector += character.position.direction_to(predicted_future_position) * -1 * personal_space_strength * 15
		if direction == null:
			direction = character.position.direction_to(next_position).normalized()
		direction = lerp(direction, character.position.direction_to(next_position) + personal_space_vector, character.rotation_speed * delta)
		character.current_direction = direction
		
		var target_rotation = direction.angle()
		character.rotation = lerp_angle(character.rotation, target_rotation, delta * character.rotation_speed)
		character.velocity = direction * character.current_speed
		character.move_and_slide()
	else:
		#If there is no next position, the goal has been reached, and we can move on to the next one
		switch_state.emit(self, "Busy")

func will_agents_collide(my_pos: Vector2, my_vel: Vector2, other_pos: Vector2, other_vel: Vector2, danger_radius: float = 50.0, max_time: float = 1.0) -> bool:
	var p = my_pos - other_pos
	var v = my_vel - other_vel
	var v_len_sq = v.length_squared()
	
	# If no relative velocity, distance won't change
	if v_len_sq == 0:
		return p.length() < danger_radius
	
	# Time of closest approach
	var t_min = clamp(-p.dot(v) / v_len_sq, 0.0, max_time)
	
	# Predicted distance at that time
	var dist = (p + v * t_min).length()
	
	return dist < danger_radius

#If the agent has entered an area that was set as the goal, then they have arrived
func _on_use_area_area_entered(area: Area2D) -> void:
	if character.current_goal == area:
		switch_state.emit(self, "Busy")

func check_if_arrived():
	if character.current_goal is Agent:
		#In order to chat, the agent just needs to be in the other agents communication area
		if communication_area.overlaps_body(character.current_goal):
			switch_state.emit(self, "Busy")
			return true
	return false

func check_if_goal_busy():
	if character.current_goal.is_in_group("Seat"):
		if line_of_sight.overlaps_area(character.current_goal) && character.current_goal.is_busy:
			#If the wanted seat was busy, switch to idle to look for a new one
			switch_state.emit(self, "Idle")
			return true
	if character.current_goal.is_in_group("Furniture"):
		if line_of_sight.overlaps_body(character.current_goal) && character.current_goal.is_busy:
			#If goal was busy, go back to idle to look for a different goal
			character.goal_queue = []
			switch_state.emit(self, "Idle")
			return true
	return false
