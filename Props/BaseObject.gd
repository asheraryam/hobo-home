extends RigidBody2D


var dragging = false
var translate_by = null
var rotate_by = 0
var ORIGINAL_GRAVITY

# Called when the node enters the scene tree for the first time.
func _ready():
	ORIGINAL_GRAVITY = gravity_scale

func _integrate_forces(state):
	if dragging:
		gravity_scale = 0
		state.set_linear_velocity(Vector2(0,0))
		state.set_angular_velocity(0)
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
		reset_gravity()

func reset_gravity():
	gravity_scale = ORIGINAL_GRAVITY
