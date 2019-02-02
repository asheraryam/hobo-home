extends Node

func _ready():
	load_game()
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		save_game()
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		WorldHelper.world.get_node("Objects/Dumpster").populate_pool()

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if ("being_displayed" in i) and (not i.being_displayed) and i.get_filename() and i.has_method("save"):
			var node_data = i.call("save");
			save_game.store_line(to_json(node_data))
	save_game.close()
	
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	
	var default_objects = get_tree().root.get_node("World/Objects").get_children()
	for o in default_objects:
		if(o.has_method("self_destruct")):
			o.self_destruct()

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting savable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		# Firstly, we need to create the object and add it to the tree and set its position.
		if current_line:
			var new_object = load(current_line["filename"]).instance()
			if load(current_line["filename"]):
				get_node(current_line["parent"]).add_child(new_object)
				new_object.position = Vector2(current_line["pos_x"], current_line["pos_y"])
				# Now we set the remaining variables.
				for i in current_line.keys():
					if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
						continue
					new_object.set(i, current_line[i])
				if new_object.has_method("set_physics"):
					new_object.set_physics()
	save_game.close()