extends Area2D

var items_taken = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_item(thing):
	thing.get_parent().remove_child(thing)
	items_taken.push_front(thing)
