extends Node

var hovered_container
var pressed_object = null
var hovered_object = null

var parent_all_objects = null

var world = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_rain(value):
	if value:
		if not world.get_node("Weather/Rain").emitting:
			world.get_node("Weather/GreyEffect/AnimationPlayer").play("start")	
		world.get_node("Backgrounds/Sky").animation = "dark"
		world.get_node("Weather/Rain").emitting = true
		world.get_node("SFX")._fade_in(world.get_node("SFX/rain"))
	else:
		if world.get_node("Weather/Rain").emitting:
			world.get_node("Weather/GreyEffect/AnimationPlayer").play("end")
		world.get_node("Backgrounds/Sky").animation = "light"
		world.get_node("Weather/Rain").emitting = false
		world.get_node("SFX")._fade_out(world.get_node("SFX/rain"))

