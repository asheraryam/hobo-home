extends Area2D

var current_hover_item = null
var back_hover_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_hover_start(thing):
#	return # FIXME
	if(thing != current_hover_item):
		back_hover_item = thing
		var sprite = null
		if(current_hover_item):
			hover_item(current_hover_item, false)
			current_hover_item = null
		elif WorldHelper.pressed_object:
			if(not thing.has_method("take_item")):
				return
		current_hover_item = thing
		hover_item(current_hover_item, true)

func _on_hover_end(thing):
#	return # FIXME
	if thing == back_hover_item:
		back_hover_item = null
	if(thing == current_hover_item):
		hover_item(current_hover_item, false)
		current_hover_item = null
		if(back_hover_item):
#			if overlaps_body(back_hover_item):
			_on_hover_start(back_hover_item)
			back_hover_item = null
				
func hover_item(item, active):
#	return # FIXME
	if(current_hover_item.has_method("set_hover")):
		current_hover_item.set_hover(active)