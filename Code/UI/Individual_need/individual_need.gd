extends Control

@export var need : base_need

@onready var need_label := $HBoxContainer/NeedLabel
@onready var need_score := $HBoxContainer/NeedScore

func update_label():
	if !need:
		return
	need_label.text = need.need_name
	need_score.value = need.value

func _on_value_update_timer_timeout() -> void:
	if !need:
		return
	need_score.value = need.value
