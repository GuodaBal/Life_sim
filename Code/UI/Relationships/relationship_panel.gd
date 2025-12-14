extends Control

@export var current_character : CharacterBody2D

@onready var relationship_container := $ScrollContainer/RelationshipContainer
@onready var relationship_bar = preload("res://Code/UI/Relationships/single_relationship_bar.tscn")

func _ready() -> void:
	GlobalSignals.relationship_added.connect(set_up)
	if current_character:
		set_up()

func set_current_character(new_character):
	current_character = new_character
	set_up()

func set_up():
	if !current_character:
		return
	for child in relationship_container.get_children():
		child.queue_free()
	for relationship in current_character.relationships:
		var bar = relationship_bar.instantiate()
		relationship_container.add_child(bar)
		bar.set_relationship(relationship)
	
