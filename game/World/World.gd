extends Node2D

onready var pointer = get_node("Pointer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		handle_press_input(event)
		handle_rotation_input(event)
	elif event is InputEventMouseMotion:
		handle_drag_input(event)

func handle_press_input(event):
	if event.button_index  == BUTTON_LEFT:
		if event.is_pressed():
			WorldHelper.pressed_object = find_colliding_object(event.position)
			if WorldHelper.pressed_object and WorldHelper.pressed_object.has_method("apply_drag_input"):
				WorldHelper.pressed_object.mode = RigidBody2D.MODE_RIGID
				WorldHelper.pressed_object.dragging = true
				pointer._on_hover_end(WorldHelper.pressed_object)
		else:
			if WorldHelper.pressed_object != null:
				if WorldHelper.hovered_container:
					WorldHelper.hovered_container.take_item(WorldHelper.pressed_object)
				if(not WorldHelper.pressed_object.physics_enabled):
					WorldHelper.pressed_object.mode = RigidBody2D.MODE_STATIC
				WorldHelper.pressed_object.dragging = false
				nudge_object(WorldHelper.pressed_object)
				unsleep_all_objects()
				var old = WorldHelper.pressed_object
				WorldHelper.pressed_object = null
				if pointer.back_hover_item:
					pointer._on_hover_start(pointer.back_hover_item)
				else:
					pointer._on_hover_start(old)
					
			
func handle_rotation_input(event):
	if not WorldHelper.pressed_object or not WorldHelper.pressed_object.has_method("apply_drag_input"):
		return 
	if WorldHelper.pressed_object.rotate_by == null:
		WorldHelper.pressed_object.rotate_by = 0
	if event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
		if WorldHelper.pressed_object:
			WorldHelper.pressed_object.rotate_by -= 0.35
	if event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
		if WorldHelper.pressed_object:
			WorldHelper.pressed_object.rotate_by += 0.35

func handle_drag_input(event):
	$Pointer.position = event.position
	if WorldHelper.pressed_object:
		if WorldHelper.pressed_object.translate_by ==null:
			WorldHelper.pressed_object.translate_by = Vector2(0,0)
		WorldHelper.pressed_object.translate_by += event.get_relative()
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