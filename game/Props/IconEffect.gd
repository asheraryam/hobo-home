extends AnimatedSprite

onready var mat = self.get_material()

var highlight_off = Color(255,255,255,0)
var highlight_on = Color(100,100,100,99)
var MAX_INTENSITY = 120

var randomized_frame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if frames.has_animation("default"):
		if not randomized_frame:
			randomized_frame = true
			frame = randi() % frames.get_frame_count("default")
#	mat = ShaderMaterial.new()
	if(mat):
		mat.set_shader_param("outline_color", highlight_off)

func set_hover(active):
	if not mat:
		return
	if(active):
		if(get_parent().has_method("take_item")):
			WorldHelper.hovered_container = get_parent()
		mat.set_shader_param("intensity",MAX_INTENSITY)
		mat.set_shader_param("outline_color", highlight_on)
	else:
		if(WorldHelper.hovered_container == get_parent()):
			WorldHelper.hovered_container = null
		mat.set_shader_param("intensity",0)
		mat.set_shader_param("outline_color", highlight_off)
