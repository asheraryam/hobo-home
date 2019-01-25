extends Node2D

var current_pressed_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			current_pressed_object = find_colliding_object(event.position)
			if current_pressed_object:
				current_pressed_object.dragging = true
		elif current_pressed_object != null:
			current_pressed_object.dragging = false
			nudge_object(current_pressed_object)
			unsleep_all_objects()
			current_pressed_object = null
	elif event is InputEventMouseMotion and current_pressed_object:
		if current_pressed_object.translate_by ==null:
			current_pressed_object.translate_by = Vector2(0,0)
		current_pressed_object.translate_by += event.get_relative()
		unsleep_all_objects()

func find_colliding_object(pos):
	var pointer = get_node("Pointer")
	pointer.position = pos
	var pointer_shape = pointer.shape_owner_get_shape(0,0)
	var pointer_transform = pointer.get_transform()
	for node in get_node("Objects").get_children():
		var shape = node.shape_owner_get_shape(0,0)
		var res = shape.collide(node.get_transform(), pointer_shape, pointer_transform)
		if res:
			return node
	return null

func nudge_object(object):
	object.apply_impulse(Vector2(0,0), Vector2(0,1))

func unsleep_all_objects():
	for node in get_node("Objects").get_children():
		node.set_sleeping(false)