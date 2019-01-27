extends Node

export var default_vol = 0
var min_vol = -60.0
export var transition_beats = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	_mute(get_node("rain"))
	get_node("rain").play()

#slowly bring in the specified layer
func _fade_in(target):
	var tween = target.get_node("Tween")
	if not tween:
		return
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, default_vol, transition_beats, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

#slowly take out the specified layer
func _fade_out(target):
	var tween = target.get_node("Tween")
	if not tween:
		return
	var in_from = target.get_volume_db()
	tween.interpolate_property(target, 'volume_db', in_from, min_vol, transition_beats, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	
#mute only the specified layer
func _mute(layer):
	layer.set_volume_db(min_vol)

#unmute only the specified layer
func _unmute(layer):
	layer.set_volume_db(default_vol)

func trash_filled():
	$trashfall2dumspter.play()

func play_default():
	$default_used.play()