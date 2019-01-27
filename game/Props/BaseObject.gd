extends RigidBody2D


export var time_for_activity = -1
export var physics_enabled = true
export var random_color = false
var color_randomized = false

var dragging = false
var translate_by = null
var rotate_by = 0
var ORIGINAL_GRAVITY = null
var being_displayed = false

signal item_pressed(item)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if(random_color and not color_randomized):
		modulate = Color(randf(), randf(), randf(), 1)
		color_randomized = true
	if not ORIGINAL_GRAVITY:
		ORIGINAL_GRAVITY = gravity_scale
	if(not physics_enabled):
		mode = MODE_STATIC

func activate():
	being_displayed = false
	if physics_enabled:
		reset_gravity()
	emit_signal("item_pressed", self)

func _integrate_forces(state):
	apply_drag_input(state)

func apply_drag_input(state):
	if dragging or being_displayed:
		gravity_scale = 0
		state.set_linear_velocity(Vector2(0,0))
		state.set_angular_velocity(0)
	if dragging:
		being_displayed = false
		if translate_by:
			var t = state.get_transform()
			state.set_transform(
				Transform2D(
					t.get_rotation(),
					t.get_origin() + translate_by
				)
			)
			translate_by = null
		if rotate_by:
			var t = state.get_transform()
			state.set_transform(
				Transform2D(
					t.get_rotation() + rotate_by,
					t.get_origin()
				)
			)
			rotate_by = null
	else:
		if physics_enabled:
			reset_gravity()

func reset_gravity():
	if being_displayed:
		return
	gravity_scale = 10

func set_hover(value):
	var sprite = get_node("icon")
	if sprite and sprite.has_method("set_hover"):
		sprite.set_hover(value)

func set_desired(value):
	pass