extends Control

@onready var name_text := $HBoxContainer/Name
@onready var relationship_bar := $HBoxContainer/Relationship

var relationship : Relationship

func set_relationship(new_relationship : Relationship):
	call_deferred("set_relationship_deferred", new_relationship)

func set_relationship_deferred(new_relationship : Relationship):
	relationship = new_relationship
	name_text.text = new_relationship.agent_name
	relationship_bar.value = new_relationship.value
	relationship.value_changed.connect(update_variables)

func update_variables():
	name_text.text = relationship.agent_name
	relationship_bar.value = relationship.value
