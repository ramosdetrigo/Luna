class_name GradientMod
extends CardModifier
## Gradient mod schema:
## "mod_type": "gradient"
## "target": Enum<Text, Texture, Both>
## "gradient": <String || Array[Color]>
## "gradient_speed": float
## "gradient_angle": float

const GRADIENT_SHADER: ShaderMaterial = preload("uid://mrb2o32b7sey")
const GRADIENTS: Dictionary[String, Gradient] = {
	"AROACE": preload("uid://dwjs35fa16x6x"),
	"AROMANTIC": preload("uid://dae1biehv85f4"),
	"ASEXUAL": preload("uid://q0oc3eap4q2n"),
	"BISEXUAL": preload("uid://ovsqk053rybw"),
	"DEMISEXUAL": preload("uid://c45ssesfu2vc"),
	"GAY": preload("uid://v0dl8p057d6h"),
	"LESBIAN": preload("uid://dl6urtyf2jyps"),
	"LGBT": preload("uid://dbt0m1xngjiuw"),
	"NONBINARY": preload("uid://bmuy44q2gekoc"),
	"PANSEXUAL": preload("uid://cikll1nkhdxvr"),
	"TRANS": preload("uid://dgb6fuvsq3vq3"),
}

var gradient: Gradient = Gradient.new()
var speed: float = 0.6
var angle: float = 1.0


func _init(mod_data: Dictionary):
	super(mod_data)

	var gradient_data = mod_data.get("gradient")
	if gradient_data is String: # Case 1: pre-defined gradient
		gradient = GRADIENTS[gradient_data]
	elif gradient_data is Array: # Case 2: evenly spaced color array
		var offset: float = 0.0
		var offset_size: float = 1.0 / (len(gradient_data) - 1)
		for hex: String in gradient_data:
			var color: Color = Color(hex)
			gradient.add_point(offset, color)
			offset += offset_size

	var s = mod_data.get("gradient_speed")
	if s is float:
		speed = s

	var a = mod_data.get("gradient_angle")
	if a is float:
		angle = a / 180.0


func gen_gradient_texture() -> GradientTexture1D:
	var g = GradientTexture1D.new()
	g.gradient = gradient
	return g


func apply(card: Card) -> void:
	super(card)
	card.static_text_container.material = GRADIENT_SHADER.duplicate()
	card.static_text_container.material.set_shader_parameter("gradient", gen_gradient_texture())
	card.static_text_container.material.set_shader_parameter("speed", speed)
	card.static_text_container.material.set_shader_parameter("angle", angle)
