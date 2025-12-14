extends Control

@export var shape_options : Array[Texture2D]

@onready var hue_slider := $HSplitContainer/CustomisationSelection/TabContainer/Appearance/ColorSliders/Hue/HueSlider
@onready var saturation_slider := $HSplitContainer/CustomisationSelection/TabContainer/Appearance/ColorSliders/Saturation/SaturationSlider
@onready var value_slider := $HSplitContainer/CustomisationSelection/TabContainer/Appearance/ColorSliders/Value/ValueSlider

@onready var extrovertedness_slider := $HSplitContainer/CustomisationSelection/TabContainer/Personality/PersonalitySliders/Extrovertedness/ExtrovertednessSlider
@onready var sedentariness_slider := $HSplitContainer/CustomisationSelection/TabContainer/Personality/PersonalitySliders/Sedentariness/SedentarinessSlider
@onready var sillyness_slider := $HSplitContainer/CustomisationSelection/TabContainer/Personality/PersonalitySliders/Sillyness/SillynessSlider
@onready var meanness_slider := $HSplitContainer/CustomisationSelection/TabContainer/Personality/PersonalitySliders/Meanness/MeannessSlider

@onready var character_sprite := $HSplitContainer/CharacterDisplay/CenterContainer/CenterPosition/Character

@onready var shape_option_container := $HSplitContainer/CustomisationSelection/TabContainer/Appearance/ShapeOptions
@onready var shape_option_button = preload("res://Code/UI/Character_creation/character_shape_option.tscn")

@onready var agent_name := $HSplitContainer/CharacterDisplay/Name

var current_hue = 0
var current_saturation = 0
var current_value = 1

var current_shape = 0

func _ready() -> void:
	var id = 0
	for shape in shape_options:
		var button_instance = shape_option_button.instantiate() as TextureButton
		button_instance.texture_normal = shape
		button_instance.pressed.connect(change_shape.bind(id))
		shape_option_container.add_child(button_instance)
		id+=1
	change_shape(0)
	color_changed()

func color_changed():
	var color = Color.from_hsv(current_hue, current_saturation, current_value, 1.0)
	character_sprite.modulate = color


func _on_hue_slider_value_changed(value: float) -> void:
	current_hue = value
	color_changed()

func _on_saturation_slider_value_changed(value: float) -> void:
	current_saturation = value
	color_changed()

func _on_value_slider_value_changed(value: float) -> void:
	current_value = value
	color_changed()
	
func change_shape(id):
	character_sprite.texture = shape_options[id]
	current_shape = id


func _on_return_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_add_character_pressed() -> void:
	#add character
	if agent_name.text.length() <= 0:
		return
	var agent = preload("res://Code/Character_prototype/character_prototype.tscn").instantiate()
	call_deferred("set_agent_attrs", agent)
	get_parent().add_child(agent)
	get_parent().init_agent(agent)
	get_tree().paused = false
	queue_free()

func set_agent_attrs(agent: Agent):
	agent.id = get_tree().get_nodes_in_group("Agent").size()
	agent.personality.set_personality(extrovertedness_slider.value, sedentariness_slider.value, sillyness_slider.value, meanness_slider.value)
	agent.sprite.texture = shape_options[current_shape]
	var color = Color.from_hsv(current_hue, current_saturation, current_value, 1.0)
	agent.modulate = color
	agent.position = get_parent().spawn_position
	agent.agent_name = agent_name.text
	agent.process_mode = Node.PROCESS_MODE_PAUSABLE
