extends Node2D

onready var pointer = get_node("Pointer")

var current_pressed_object = null



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		handle_drag_input(event)
		handle_rotation_input(event)
	elif event is InputEventMouseMotion:
		$Pointer.position = event.position
		if current_pressed_object:
			if current_pressed_object.translate_by ==null:
				current_pressed_object.translate_by = Vector2(0,0)
			current_pressed_object.translate_by += event.get_relative()
			unsleep_all_objects()

func find_colliding_object(pos):
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

func handle_drag_input(event):
	if event.button_index  == BUTTON_LEFT:
		if event.is_pressed():
			current_pressed_object = find_colliding_object(event.position)
			if current_pressed_object and current_pressed_object.has_method("apply_drag_input"):
				current_pressed_object.dragging = true
				pointer._on_hover_end(current_pressed_object)
		else:
			if current_pressed_object != null:
				if WorldHelper.hovered_container:
					WorldHelper.hovered_container.take_item(current_pressed_object)
				current_pressed_object.dragging = false
				nudge_object(current_pressed_object)
				unsleep_all_objects()
				pointer._on_hover_start(current_pressed_object)
				current_pressed_object = null
			
func handle_rotation_input(event):
	if not current_pressed_object or not current_pressed_object.has_method("apply_drag_input"):
		return 
	if current_pressed_object.rotate_by == null:
		current_pressed_object.rotate_by = 0
	if event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
		if current_pressed_object:
			current_pressed_object.rotate_by -= 0.35
	if event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
		if current_pressed_object:
			current_pressed_object.rotate_by += 0.35