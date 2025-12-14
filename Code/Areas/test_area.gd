extends Node2D

@export var pathfinding : Pathfinding
@export var ground_tilemap : TileMapLayer

@onready var space_state = get_world_2d().direct_space_state
@onready var current_needs_display = $Camera2D/CurrentNeeds
@onready var relationship_display = $Camera2D/RelationshipPanel
@onready var spawn_position = $SpawnPosition.position

var previous_agent : Agent

func _ready() -> void:
	$Floor.set_floor_weights()
	pathfinding.create_nav_map(ground_tilemap)
	for agent in get_tree().get_nodes_in_group("Agent"):
		agent.pathfinding = pathfinding
	pathfinding.update_nav_map()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Game_speed_1"):
		Engine.time_scale = 1
	if Input.is_action_just_pressed("Game_speed_2"):
		Engine.time_scale = 2
	if Input.is_action_just_pressed("Game_speed_3"):
		Engine.time_scale = 5
	if Input.is_action_just_pressed("Pause_game"):
		if !get_tree().paused:
			get_tree().paused = true
		else:
			get_tree().paused = false
	if Input.is_action_just_pressed("Click"):
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collide_with_bodies = true
		var results = space_state.intersect_point(query, 32)
		var was_agent = false
		for result in results:
			if result.collider is Agent: #Changing the currently selected agent
				if previous_agent:
					previous_agent.spotlight_toggle(false)
				result.collider.spotlight_toggle(true)
				current_needs_display.visible = true
				current_needs_display.set_current_character(result.collider)
				relationship_display.visible = true
				relationship_display.set_current_character(result.collider)
				was_agent = true
				previous_agent = result.collider
				break
		if !was_agent:
			current_needs_display.visible = false
			relationship_display.visible = false

func _on_create_character_pressed() -> void:
	get_tree().paused = true
	var instance = preload("res://Code/UI/Character_creation/character_creation_ui.tscn").instantiate()
	add_child(instance)

func init_agent(agent):
	agent.pathfinding = pathfinding
