extends Node2D

onready var pointer = get_node("Pointer")

var pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	set_process_input(true)
	WorldHelper.world = self
	WorldHelper.parent_all_objects = get_node("Objects")

func _process(delta):
	refresh_hover()

func _input(event):
	if event is InputEventMouseButton:
		handle_press_input(event)
		handle_rotation_input(event)
	if event is InputEventMouseMotion:
		handle_drag_and_hover_input(event)

func handle_press_input(event):
	if event.button_index  == BUTTON_LEFT:
		pressed = event.is_pressed()
		if pressed:
			if WorldHelper.hovered_object and WorldHelper.hovered_object.visible:
				WorldHelper.pressed_object = WorldHelper.hovered_object
				WorldHelper.hovered_object = null
#				WorldHelper.pressed_object.hide()
				if WorldHelper.pressed_object.has_method("apply_drag_input"):
					if WorldHelper.pressed_object.get_node("AnimationPlayer"):
						WorldHelper.pressed_object.get_node("AnimationPlayer").stop()
#					if WorldHelper.pressed_object.physics_enabled:
					$SFX/selected.play()
					WorldHelper.pressed_object.mode = RigidBody2D.MODE_RIGID
					WorldHelper.pressed_object.dragging = true
					if(WorldHelper.pressed_object.has_method("set_hover")):
						WorldHelper.pressed_object.set_hover(false)
					pointer._on_hover_end(WorldHelper.pressed_object)
				if WorldHelper.pressed_object == $Hobo.item_target:
					$Hobo.target_interrupted()
				if WorldHelper.pressed_object.has_method("activate"):
					WorldHelper.pressed_object.activate()
		else:
			if WorldHelper.pressed_object != null:
				if WorldHelper.pressed_object.has_method("apply_drag_input"):
					if WorldHelper.pressed_object.physics_enabled:
						$SFX/drop.play()
					if(not WorldHelper.pressed_object.physics_enabled):
						WorldHelper.pressed_object.mode = RigidBody2D.MODE_STATIC
					WorldHelper.pressed_object.dragging = false
					nudge_object(WorldHelper.pressed_object)
					unsleep_all_objects()
	#				var collidys = WorldHelper.pressed_object.get_colliding_bodies()
	#				for thing in collidys:
	#					if(thing.has_method("take_item")):
	#						thing.take_item(WorldHelper.pressed_object)
	#						break
				WorldHelper.pressed_object = null
				
			
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

func handle_drag_and_hover_input(event):
	pointer.position = event.position
	
	refresh_hover()
		
	if WorldHelper.pressed_object and WorldHelper.pressed_object.has_method("apply_drag_input"):
		if WorldHelper.pressed_object.translate_by ==null:
			WorldHelper.pressed_object.translate_by = Vector2(0,0)
		WorldHelper.pressed_object.translate_by += event.get_relative()
		unsleep_all_objects()

func refresh_hover():
	var result = find_colliding_object()
	if WorldHelper.hovered_object != result:
		if result and not (result is RigidBody2D):
			return

		if WorldHelper.hovered_object and WorldHelper.hovered_object.has_method("set_hover"):
			WorldHelper.hovered_object.set_hover(false)
		
		if result and result.has_method("set_hover") and WorldHelper.pressed_object != result:
			result.set_hover(true)
		WorldHelper.hovered_object = result

func find_colliding_object():
	var pointer_shape = pointer.shape_owner_get_shape(0,0)
	var pointer_transform = pointer.get_transform()
	for node in WorldHelper.parent_all_objects.get_children():
		var shape = node.shape_owner_get_shape(0,0)
		var res = shape.collide(node.get_transform(), pointer_shape, pointer_transform)
		if res:
			return node
	return null

func nudge_object(object):
	object.apply_impulse(Vector2(0,0), Vector2(0,1))

func unsleep_all_objects():
	for node in WorldHelper.parent_all_objects.get_children():
		if node.has_method("set_sleeping"):
			node.set_sleeping(false)

func apply_weather_destruction():
	yield(get_tree().create_timer(3), "timeout")
	for node in $Objects.get_children():
		if node.has_method("apply_weather"):
			node.apply_weather() 
			