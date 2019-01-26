extends KinematicBody2D

export var default_action_time = 5

var item_target = null
var item_in_use = null

func _ready():
	randomize()

func _on_next_desire_timeout():
	$next_desire.stop()
	$walk_tween.stop(self, "position")
	print("Desire timeout")
	var all = WorldHelper.parent_all_objects.get_children()
	var index = randi() % all.size()
	item_target = all[index]
	while not valid_desire_object(item_target):
		print("Desire loop")
		index = randi() % all.size()
		item_target = all[index]
	move_to(Vector2(item_target.position.x, position.y))
	
func valid_desire_object(item):
	return item.has_method("set_desired") and abs(item.position.y - position.y) < 200

func move_to(pos):
	var walk_duration = abs(position.x - pos.x)/100
	$walk_tween.interpolate_property(self, "position",
	position, pos, walk_duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$walk_tween.start()
	
	yield(get_tree().create_timer(walk_duration), "timeout")
	var time_to_next = default_action_time
	if item_target.time_for_activity != -1:
		time_to_next = item_target.time_for_activity
	$next_desire.wait_time = time_to_next
	$next_desire.start()
