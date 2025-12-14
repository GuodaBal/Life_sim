extends CharacterBody2D
class_name Agent

#Variables for socialising
@export var action_queue : Array[Action]
@export var need_refilled = "placeholder"
@export var time_taken = 5.0
@export var refilled_per_second = 1.0
@export var personality_buffs : Dictionary[Personality.PersonalityTrait, float]

#Variables for actual agent
@onready var collision_shape := $CollisionShape2D
@onready var sprite := $Sprite2D

@onready var need_refiller := $Need_refiller

@onready var spotlight := $FocusGlow

@export var SPEED = 100
@export var rotation_speed = 10
@export var needs_list : Array[base_need]
var personality = Personality.new()
var relationships : Array[Relationship]

@export var id = 0
var agent_name = "Josh"

var pathfinding : Pathfinding

var current_speed = SPEED

var is_sleeping = false
var sitting_on = null
var is_awaiting_social = false
var current_goal = null

var goal_queue = []

#Temporary vars
var current_direction = Vector2(0,0)

func _ready() -> void:
	personality.set_personality(0,0,0,0)
	call_deferred("add_personality_buffs_to_needs")
	
	#Children can't have parent in an export variable, so need to add refferene here
	#$SocializationActionQueue/SeekAction.item = self
	#$SocializationActionQueue/ChatAction.chat_with = self

func add_personality_buffs_to_needs():
	for need in needs_list:
		for buff in need.personality_buffs.keys():
			need.add_speed_buff(personality.get_value_by_name(buff) * need.personality_buffs[buff])

func get_needs():
	return needs_list

func fill_need(need_name, fill_amount):
	for need in needs_list:
		if need.need_name == need_name:
			need.value += fill_amount
			need.value = clamp(need.value, 0, 130)
 
func start_need_refill(variables):
	need_refiller.set_variables(variables)

func change_speed(_time, multiplyer):
	current_speed = SPEED * multiplyer
	$SpeedTimer.start()

func _on_speed_timer_timeout() -> void:
	current_speed = SPEED

func _on_pathing_direction_area_entered(area: Area2D) -> void:
	var agent = area.get_parent()
	if current_goal && agent.current_goal && $SpeedTimer.is_stopped():
		if id > agent.id:
			change_speed(1.0, 1.2)
			agent.change_speed(1.0, 0.8)
		else:
			change_speed(1.0, 0.8)
			agent.change_speed(1.0, 1.2)

##Called when need is done being refilled
func done_refilling():
	$StateMachine/Busy.action_finished()

func wake_up():
	is_sleeping = false

func sleep():
	is_sleeping = true

func sit(seat):
	sitting_on = seat

func stop_sitting():
	sitting_on.done_using()
	sitting_on = null

func is_busy():
	if $StateMachine.current_state == $StateMachine/Seeking || is_sleeping || is_awaiting_social:
		return true
	return false

func await_social(tf):
	is_awaiting_social = tf

func chat(agent):
	var have_chatted = false
	for relationship in relationships:
		if relationship.agent_id == agent.id:
			have_chatted = true
	if !have_chatted:
		add_new_relationship(agent)
	#is_awaiting_social = false
	start_need_refill(agent.get_variables())
	
	#var conversation = Conversation.new()
	#conversation.resolve_conversation(self, agent)
	#conversation.queue_free()
	print_debug("Chatted")

func get_variables():
	return {"need_refilled" : need_refilled, "time_taken" : time_taken, 
	"refilled_per_second" : refilled_per_second, "personality_buffs" : personality_buffs}
	

func add_value_to_relationship(agent, value):
	for relationship in relationships:
		if relationship.agent_id == agent.id:
			relationship.add_value(value)
			return
	var relationship = add_new_relationship(agent)
	relationship.add_value(value)

func add_new_relationship(agent: Agent):
	var relationship = Relationship.new(agent.agent_name, agent.id)
	relationships.append(relationship)
	GlobalSignals.relationship_added.emit()
	return relationship

func get_relationship(agent : Agent):
	for relationship in relationships:
		if relationship.agent_id == agent.id:
			return relationship
	return null

func spotlight_toggle(tf : bool):
	spotlight.visible = tf
