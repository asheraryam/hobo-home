extends RigidBody2D

export var hidden_when_used = false
export var time_for_activity = -1
export var weather_sensitive = false
export var physics_enabled = true
export(String) var usage_animation = "default"
export var random_color = false
var color_randomized = false
export var use_as_frame = false

var inside_frame = false

var dragging = false
var translate_by = null
var rotate_by = 0
var ORIGINAL_GRAVITY = null
var being_displayed = false

var dead = false

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
	if dragging or being_displayed or inside_frame:
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

func activate_used(default_time):
	var sound = get_node("AudioStreamPlayer")
	if sound:
		sound.play()
	elif get_node("SFX"):
		var all = get_node("SFX").get_children()
		var index = randi() % all.size()
		all[index].play()
	else:
		WorldHelper.world.get_node("SFX").play_default()
	var duration = time_for_activity
	if(duration <0):
		duration = default_time
	if hidden_when_used:
		hide()
	get_tree().create_timer(duration).connect("timeout", self, "show")

func apply_weather():
	if weather_sensitive and not being_displayed:
#		var eff = WorldHelper.poof_effect.instance()
#		add_child(eff)
		dead = true
		get_node("CollisionShape2D").disabled = true
		get_node("icon").hide()
#		yield(get_tree().create_timer(3), "timeout")
		var hobo=WorldHelper.world.get_node("Hobo")
		if(hobo.target_item and hobo.target_item == self):
			hobo.hobo.get_node("moving").disconnect("timeout", self, "target_reached")
			hobo.get_node("usage_timer").disconnect("timeout", self, "idling")
		queue_free()
#		remove_child(eff)
#		WorldHelper.world.get_node("Effects").add_child(eff)
#		eff.position = position
#		WorldHelper.world.get_node("Effects").add_child(eff)
#		eff.position = position
#		hide()
#		get_parent().remove_child(self)
#		queue_free()

func set_framed(value):
	inside_frame = value