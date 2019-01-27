extends KinematicBody2D

export var default_action_time = 5

var item_target = null
var item_in_use = null

var moving = false

func _ready():
	randomize()

func _on_next_desire_timeout():
	if moving:
		return
	$next_desire.stop()
	$walk_tween.stop(self, "position")

	var all = WorldHelper.parent_all_objects.get_children()
	var index = 0
	item_target = null
	var tries = 1
	while not valid_desire_object(item_target):
		index = randi() % all.size()
		item_target = all[index]
		tries +=1
		if(tries > all.size() * 100):
			$next_desire.wait_time = default_action_time
			$next_desire.start()
			return
	move_to(Vector2(item_target.position.x, position.y))
	
func valid_desire_object(item):
	return item and item.has_method("set_desired") and abs(item.position.y - position.y) < 200 and not item.being_displayed and not WorldHelper.pressed_object == item and not item.dead

func move_to(pos):
	$icon.play("walking")
	$icon.flip_h = position.x - pos.x < 0
	var walk_duration = abs(position.x - pos.x)/100
	$walk_tween.interpolate_property(self, "position",
	position, pos, walk_duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$walk_tween.start()
	moving = true
	
	$moving.wait_time = walk_duration
	$moving.start()
	$moving.connect("timeout", self, "target_reached", [item_target.name])

func target_reached(thing):
	$icon.play("default")
	moving = false
	var time_to_next = default_action_time
	if item_target and item_target.name == thing:
		if item_target.time_for_activity != -1:
			time_to_next = item_target.time_for_activity
		item_target.activate_used(default_action_time)
		$next_desire.wait_time = time_to_next
		$next_desire.start()
	else:
		item_target = null
#		return
		_on_next_desire_timeout()

func target_interrupted():
	$icon.play("default")
	$moving.disconnect("timeout", self, "target_reached")
	moving = false
	$moving.stop()
	item_target = null
	_on_next_desire_timeout()

func completely_aimless():
	return $moving.is_stopped() and $next_desire.is_stopped()