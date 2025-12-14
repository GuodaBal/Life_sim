extends Node

class_name base_need

@export var personality_buffs : Dictionary[Personality.PersonalityTrait, float]

@export var need_name := "placeholder"
@export var decrease_speed := 0.1
@export var need_curve : Curve

var value
var priority

func _ready() -> void:
	value = 100

func _physics_process(delta: float) -> void:
	value -= decrease_speed * delta
	priority = need_curve.sample(value)

func add_speed_buff(buff):
	decrease_speed += buff

func remove_speed_buff(buff):
	decrease_speed -= buff
