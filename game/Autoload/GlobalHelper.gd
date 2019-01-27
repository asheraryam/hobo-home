extends Node

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		WorldHelper.world.get_node("Objects/Dumpster").populate_pool()
