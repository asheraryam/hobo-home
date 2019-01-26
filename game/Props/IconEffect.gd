extends Sprite

onready var mat = self.get_material()

var highlight_off = Color(255,255,255,0)
var highlight_on = Color(100,100,100,99)
var MAX_INTENSITY = 200

# Called when the node enters the scene tree for the first time.
func _ready():
#	mat = ShaderMaterial.new()
	mat.set_shader_param("outline_color", highlight_off)

func set_hover(active):
	if(active):
		mat.set_shader_param("intensity",MAX_INTENSITY)
		mat.set_shader_param("outline_color", highlight_on)
	else:
		mat.set_shader_param("intensity",0)
		mat.set_shader_param("outline_color", highlight_off)
