extends Node2D
class_name Seat

var is_busy = false

func use():
	print_debug("Seat was used")
	is_busy = true

func done_using():
	print_debug("Seat no longer used")
	is_busy = false
