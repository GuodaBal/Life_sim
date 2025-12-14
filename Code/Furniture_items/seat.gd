extends Node2D
class_name Seat

var is_busy = false

func use():
	is_busy = true

func done_using():
	is_busy = false
