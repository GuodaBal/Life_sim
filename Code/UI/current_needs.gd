extends Control

@export var current_character : CharacterBody2D

@onready var needs_container := $NeedsContainer

var all_needs = []

func _ready() -> void:
	if current_character:
		set_up()

func set_current_character(new_character : CharacterBody2D):
	current_character = new_character
	set_up()

func set_up(): #Could be changed if different agents have different amounts of needs somehow
	all_needs = current_character.get_needs()
	var children = needs_container.get_children()
	var index = 0
	for need in all_needs:
		children[index].need = need
		children[index].update_label()
		index += 1 
