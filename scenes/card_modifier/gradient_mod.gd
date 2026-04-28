class_name GradientMod
extends CardModifier

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


func gen_gradient(gradient: Gradient) -> GradientTexture1D:
	var g = GradientTexture1D.new()
	g.gradient = gradient
	return g


func apply(card: Card) -> void:
	super(card)
	card.static_text_container.material = GRADIENT_SHADER.duplicate()

	var gradient: Gradient = Gradient.new()
	var gradient_data = json_data.get("gradient")
	if gradient_data is String: # Case 1: pre-defined gradient
		gradient = GRADIENTS[gradient_data]
	elif gradient_data is Array: # Case 2: evenly spaced color array
		var offset: float = 0.0
		var offset_size: float = 1.0 / (len(gradient_data) - 1)
		for hex: String in gradient_data:
			var color: Color = Color(hex)
			gradient.add_point(offset, color)
			offset += offset_size
	card.static_text_container.material.set_shader_parameter("gradient", gen_gradient(gradient))

	var speed = json_data.get("gradient_speed")
	if speed is float:
		card.static_text_container.material.set_shader_parameter("speed", speed)

	var angle = json_data.get("gradient_angle")
	if angle is float:
		card.static_text_container.material.set_shader_parameter("angle", angle / 180.0)
