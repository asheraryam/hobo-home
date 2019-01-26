extends Area2D

var current_hover_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_hover_start(thing):
	if(thing != current_hover_item):
		var sprite = null
		if(current_hover_item):
			sprite = current_hover_item.get_node("icon")
		if(sprite and sprite.has_method("set_hover")):
			sprite.set_hover(false)
			current_hover_item = null
		current_hover_item = thing
		sprite = current_hover_item.get_node("icon")
		if(sprite and sprite.has_method("set_hover")):
			sprite.set_hover(true)
			

func _on_hover_end(thing):
	if(thing == current_hover_item):
		var sprite = current_hover_item.get_node("icon")
		if(sprite and sprite.has_method("set_hover")):
				sprite.set_hover(false)
				current_hover_item = null