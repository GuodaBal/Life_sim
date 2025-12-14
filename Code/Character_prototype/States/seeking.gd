extends State

@export var character : Agent
@export var line_of_sight : Area2D
@export var pos : Node2D
@export var personal_bubble : Area2D
@export var communication_area : Area2D

var path : Array
var distance_to_point_reached = 7
var current_point_goal = 1
var direction

var goal_is_social = false

#Called when entering state
func enter():
	if character.sitting_on:
		character.stop_sitting()
	for body in line_of_sight.get_overlapping_bodies():
		if body == character.current_goal && body.is_busy():
			switch_state.emit(self, "Idle")
			return
	for area in line_of_sight.get_overlapping_areas():
		if area.is_in_group("Seat") && area.is_busy:
			switch_state.emit(self, "Idle")
			return
	path = character.pathfinding.get_path_between_points(pos.global_position, character.current_goal.global_position, true)
	current_point_goal = 1
	

#Called when exiting state
func exit():
	#print_debug("not seeking")
	pass

#Called on process(delta)
func update(delta):
	pass

#Called on physics_process(delta)
func physics_update(delta):
	if character.is_awaiting_social:
		return
	
	#If we are heading towards an agent, we don't need to get to a precise location, we just need
	#to be in earshot. Once our communication area overlaps with the agent, we are considered close
	#enough, and the goal is reached
	if character.current_goal is Agent:
		if communication_area.overlaps_body(character.current_goal):
			switch_state.emit(self, "Busy")
	if character.current_goal.is_in_group("Seat"):
		#print_debug(line_of_sight.overlaps_area(character.current_goal))
		#print_debug( character.current_goal.is_busy)
		if line_of_sight.overlaps_area(character.current_goal) && character.current_goal.is_busy:
			switch_state.emit(self, "Idle")
			print_debug("Seat taken, retreating")
	if character.current_goal.is_in_group("Furniture"):
		print_debug(character.current_goal.is_busy)
		print_debug(line_of_sight.overlaps_body(character.current_goal))
		if line_of_sight.overlaps_body(character.current_goal) && character.current_goal.is_busy:
			character.goal_queue = []
			switch_state.emit(self, "Idle")
			print_debug("Furniture taken, retreating")
	
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
		var agents_nearby = []
		for area in personal_bubble.get_overlapping_areas():
			if area.get_parent() is not Agent:
				continue
			var agent = area.get_parent() as Agent
			agents_nearby.append(agent)
			if !will_agents_collide(character.position, character.current_direction * character.current_speed, agent.position, agent.current_direction * agent.current_speed):
				continue
			var predicted_future_position = agent.position + agent.current_direction * agent.current_speed
			var agent_position = area.get_parent().position
			var personal_space_strength = 1 / (character.position.distance_to(predicted_future_position))
			personal_space_vector += character.position.direction_to(predicted_future_position) * -1 * personal_space_strength * 15
		if direction == null:
			direction = character.position.direction_to(next_position).normalized()
		direction = lerp(direction, character.position.direction_to(next_position) + personal_space_vector, character.rotation_speed * delta)
		#direction = lerp(direction, calculate_avoidance_velocity(character.position.direction_to(path[1]).normalized(), agents_nearby), character.rotation_speed * delta)
		character.current_direction = direction
		
		
		#character.look_at(path[1])
		#character.position = character.position.lerp(path[1], character.current_speed/20 * delta)
		var target_rotation = direction.angle()
		character.rotation = lerp_angle(character.rotation, target_rotation, delta * character.rotation_speed)
		character.velocity = direction * character.current_speed
		character.move_and_slide()
		#if path[1].distance_to(character.position) < distance_to_point_reached:
			#current_point_goal += 1
	else:
		#if character.current_goal.is_busy():
			#print_debug("goal was busy")
			#switch_state.emit(self, "Idle")
		#else:
		#print_debug("using")
		character.current_goal = null
		switch_state.emit(self, "Busy")
	
	#if !character.navigation.is_navigation_finished():
		#var direction = character.position.direction_to(character.navigation.get_next_path_position()).normalized()
		#character.look_at(character.navigation.get_next_path_position())
		#character.velocity = direction * character.speed
		#character.move_and_slide()


func _on_navigation_agent_2d_navigation_finished() -> void:
	#switch_state.emit(self, "Busy")
	pass

#func _on_line_of_sight_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	#if area == character.current_goal && area.is_busy():
			#switch_state.emit(self, "Idle")
			
func Avoid(InPosition: Vector2, InDelta):
	#Offset is PointB - PointA
	var offset = InPosition - character.position
	#If in range
	if offset.length() < 30:
		#Better formula: ((offset.normalized() * ((BoidDistance*2) - offset.length())) + offset.normalized()) * InDelta
		character.position -= offset.normalized() * character.speed * InDelta
	else:
		#We need a direction to look at, just keep looking at X
		offset = character.transform.x
	
	#Rotate in the direction we are moving
	character.rotation = offset.normalized().angle()
	#Later we will need direction so grab it while we are here
	return offset.normalized()

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

func calculate_avoidance_velocity(target_velocity, all_agents):
	var new_velocity = target_velocity

	for other_agent in all_agents:
		if other_agent == character: continue # Don't avoid self

		var relative_position = other_agent.position - character.position
		var relative_velocity = character.velocity - other_agent.velocity # Corrected relative velocity

		var radius = 1000

		# 1. Check if collision is imminent
		# This is a simplified check. A proper RVO uses the velocity obstacle concept.
		# For now, let's just see if they are close and heading towards each other.
		if relative_position.length_squared() < radius: # If within 2x combined radi# This is a very basic "predict and steer"
			#print_debug("yes")
			var time_to_collision = - relative_position.dot(relative_velocity) / relative_velocity.length_squared() if relative_velocity.length_squared() > 0 else 999
			if time_to_collision > 0 and time_to_collision < 2.0: # If collision in next 2 seconds
				var collision_point_char = character.position + character.velocity * time_to_collision
				var collision_point_other = other_agent.position + other_agent.velocity * time_to_collision

				if collision_point_char.distance_to(collision_point_other) < radius:
					# Collision predicted! Try to steer away.
					# This is still a heuristic, not full RVO.
					var avoidance_direction = (character.position - other_agent.position).normalized()
					# Add a perpendicular component for "sliding past"
					var perpendicular_direction = avoidance_direction.rotated(PI/2) # Rotate 90 degrees
					# Prioritize perpendicular movement if close and head-on
					var dot_product = relative_position.normalized().dot(relative_velocity.normalized())
					if dot_product < -0.5: # Mostly head-on
						# Prefer moving to the side
						new_velocity += perpendicular_direction * 150 * 0.1 # A strong push
						print_debug("strong push")
					else:
						new_velocity += avoidance_direction * 150 * 0.01 # A softer push
						print_debug("soft push")

				# Limit how much avoidance overrides desired velocity
				new_velocity = new_velocity.normalized() * min(new_velocity.length(), 150)
				# This needs to be carefully tuned.

# Clamp the final velocity to max speed
	return new_velocity


func _on_line_of_sight_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	#print_debug("entered line of sight")
	#print_debug(area.is_in_group("Seat"))
	#print_debug(area.is_in_group("Seat") && area.is_busy)
	#if area == character.current_goal && area.is_in_group("Seat") && area.is_busy:
		#switch_state.emit(self, "Idle")
		#print_debug("seat was busy, retreat")
	pass


func _on_use_area_area_entered(area: Area2D) -> void:
	print_debug("entered area")
	if character.current_goal == area:
		print_debug("entered use area")
		switch_state.emit(self, "Busy")
