extends Node
class_name Conversation

func resolve_conversation(agent_1 : Agent, agent_2 : Agent):
	var agent_1_polite = true
	var agent_2_polite = true
	
	var relationship = agent_1.get_relationship(agent_2)
	var relationship_bonus = 0
	if relationship:
		relationship_bonus = (relationship.value - 50)/100
		#if relationship.value >= 50:
			#relationship_bonus = relationship.value/200
		#else:
			#relationship_bonus = -relationship.value/100
	print_debug(relationship_bonus)
	if randf() - agent_1.personality.mean / 2 + relationship_bonus < 0.1:
		agent_1_polite = false
	if randf() - agent_2.personality.mean / 2 + relationship_bonus < 0.1:
		agent_2_polite = false
	
	if agent_1_polite && agent_2_polite:
		agent_1.add_value_to_relationship(agent_2, 10)
		agent_2.add_value_to_relationship(agent_1, 10)
		print_debug("went well")
	elif agent_1_polite || agent_2_polite:
		agent_1.add_value_to_relationship(agent_2, -5)
		agent_2.add_value_to_relationship(agent_1, -5)
		print_debug("went not great")
	else:
		agent_1.add_value_to_relationship(agent_2, -10)
		agent_2.add_value_to_relationship(agent_1, -10)
		print_debug("went bad")
	
	agent_1.await_social(false)
	agent_2.await_social(false)
