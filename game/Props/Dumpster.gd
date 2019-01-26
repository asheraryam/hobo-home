extends RigidBody2D

var displayed_item

var item_pool = []
var item_pool_length = 3
var display_index = 0

var random_object = preload("res://Props/Things/Jabberwocky.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
func take_item(item):
	if "being_displayed" in item:
		item.get_parent().remove_child(item)
	
func activate():
	if item_pool.size() >0:
		show_item_from_pool()
	
func show_item_from_pool():
	if displayed_item:
		displayed_item.get_parent().remove_child(displayed_item)
		displayed_item = null
	
	if(item_pool.size() < item_pool_length):
		populate_pool()
	var thing = item_pool[display_index]
	display_index = (display_index + 1) % item_pool.size()
	display_item(thing)

func populate_pool():
	WorldHelper.world.get_node("SFX/more_trash").play()
	if item_pool_length > item_pool.size():
		for i in range(item_pool_length - item_pool.size()):
			var thing = random_object.instance()
			item_pool.append(thing)

func display_item(thing):
	displayed_item = thing
	displayed_item.connect("item_pressed", self, "displayed_pressed")
	if "being_displayed" in thing:
		displayed_item.being_displayed = true
	if "gravity_scale" in thing:
		displayed_item.gravity_scale = 0
	if thing.get_node("AnimationPlayer"):
		thing.get_node("AnimationPlayer").play("hover")
	
	if(displayed_item.random_color and not displayed_item.color_randomized):
		displayed_item.modulate = Color(randf(), randf(), randf(), 1)
		displayed_item.color_randomized = true
	WorldHelper.parent_all_objects.add_child(displayed_item)
	displayed_item.global_position = get_node("spawn_pos").global_position
	if displayed_item.has_method("set_sleeping"):
		displayed_item.set_sleeping(false)
		
func displayed_pressed(item):
	item.disconnect("item_pressed", self, "displayed_pressed")
	if item == displayed_item:
		$SmokeEffect.emitting = false
		var index = item_pool.find(displayed_item)
		if index > -1:
			item_pool.remove(index)
			displayed_item = null
			item_pool = []
			set_hover(false)

func set_hover(value):
	if item_pool.size() == 0 and value:
		return
	var sprite = get_node("icon")
	if sprite and sprite.has_method("set_hover"):
		sprite.set_hover(value)

func _on_Area2D_body_entered(body):
	if "being_displayed" in body:
		take_item(body)
		
func _on_next_trash_timeout():
#	$next_trash.start()
	smoke_effect()
	populate_pool()

func smoke_effect():
	$SmokeEffect.emitting = true
