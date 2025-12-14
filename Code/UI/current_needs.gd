extends Control

@export var current_character : CharacterBody2D

var all_needs = []

func _ready() -> void:
	if current_character:
		set_up()

func set_current_character(new_character : CharacterBody2D):
	current_character = new_character
	set_up()

func set_up():
	all_needs = current_character.get_needs()
	var children = $NeedsContainer.get_children()
	var index = 0
	for need in all_needs:
		children[index].need = need
		children[index].update_label()
		index += 1 
