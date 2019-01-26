extends Area2D

var current_hover_item = null
var back_hover_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_hover_start(thing):
	if(thing != current_hover_item):
		var sprite = null
		if(current_hover_item):
			hover_item(current_hover_item, false)
			current_hover_item = null
		elif WorldHelper.pressed_object:
			if(not thing.has_method("take_item")):
				back_hover_item = thing
				return
		current_hover_item = thing
		hover_item(current_hover_item, true)

func _on_hover_end(thing):
	if(thing == current_hover_item):
		hover_item(current_hover_item, false)
		current_hover_item = null
		if(back_hover_item):
			_on_hover_start(back_hover_item)
			back_hover_item = null
				
func hover_item(item, active):
	var sprite = current_hover_item.get_node("icon")
	if(sprite and sprite.has_method("set_hover")):
		sprite.set_hover(active)