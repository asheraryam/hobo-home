extends RigidBody2D

var displayed_item

export var max_next_time = 90
export var min_next_time = 45

export(PackedScene) var smoke_effect = null

var item_pool = []
var item_pool_length = 10
var display_index = 0

var random_object = preload("res://Props/Things/Jabberwocky.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	populate_pool()

func activate():
	if item_pool.size() >0 and not $AnimationPlayer.is_playing():
		show_item_from_pool()
	
func show_item_from_pool():
	$AnimationPlayer.play("trash_pressed")
	if displayed_item:
		displayed_item.being_displayed = false
		displayed_item.get_parent().remove_child(displayed_item)
		displayed_item = null
	
#	if(item_pool.size() < item_pool_length):
#		populate_pool()
	
	display_index = (display_index + 1) % item_pool.size()
	var thing = item_pool[display_index]
	display_item(thing)

func populate_pool():
	set_hover(false)
	if displayed_item:
		displayed_item.get_parent().remove_child(displayed_item)
		displayed_item = null
	item_pool = []
#	WorldHelper.world.get_node("SFX/more_trash").play()
	$AnimationPlayer.play("drop_trash")
	yield($AnimationPlayer,"animation_finished")
	if WorldHelper.world.get_node("Hobo").completely_aimless():
		WorldHelper.world.get_node("Hobo")._on_next_desire_timeout()
	$next_trash.wait_time = (randi() % (max_next_time - min_next_time)) + min_next_time
	
	if(randf() < WorldHelper.rain_chance):
		WorldHelper.set_rain(true)
	else:
		WorldHelper.set_rain(false)
		
	if item_pool_length > item_pool.size():
		for i in range(item_pool_length - item_pool.size()):
			var all = WorldHelper.parent_all_objects.all_items
			var index = randi() % all.size()
			var random_object = all[index]
			var tries = 0
			while not random_object:
				index = randi() % all.size()
				random_object = all[index]
				tries += 1
				if(tries > 1000):
					return
			item_pool.append(random_object.instance())

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
		displayed_item.can_sleep = false
		displayed_item.set_sleeping(false)
		
func displayed_pressed(item):
	item.disconnect("item_pressed", self, "displayed_pressed")
	if item == displayed_item:
		var index = item_pool.find(displayed_item)
		if index > -1:
			item_pool.remove(index)
			displayed_item = null
			if item_pool.size() < 1:
				get_node("icon").animation = "empty"
#			item_pool = []
#			$icon.animation = "empty"
#			set_hover(false)

func set_hover(value):
	if item_pool.size() == 0 and value:
		return
	var sprite = get_node("icon")
	if sprite and sprite.has_method("set_hover"):
		sprite.set_hover(value)
		
func _on_next_trash_timeout():
#	$next_trash.start()
#	smoke_effect()
	populate_pool()

func smoke_effect():
	var effect = smoke_effect.instance()
	WorldHelper.world.get_node("Effects").add_child(effect)

