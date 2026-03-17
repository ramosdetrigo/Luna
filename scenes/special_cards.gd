extends Node


const gradients: Dictionary[String, Gradient] = {
	"AROACE": preload("uid://dwjs35fa16x6x"),
	"AROMANTIC": preload("uid://dae1biehv85f4"),
	"ASEXUAL" : preload("uid://q0oc3eap4q2n"),
	"BISEXUAL" : preload("uid://ovsqk053rybw"),
	"DEMISEXUAL" : preload("uid://c45ssesfu2vc"),
	"GAY" : preload("uid://v0dl8p057d6h"),
	"LESBIAN" : preload("uid://dl6urtyf2jyps"),
	"LGBT" : preload("uid://dbt0m1xngjiuw"),
	"NONBINARY" : preload("uid://bmuy44q2gekoc"),
	"PANSEXUAL" : preload("uid://cikll1nkhdxvr"),
	"TRANS" : preload("uid://dgb6fuvsq3vq3"),
}


@abstract
class SpecialCard:
	extends Node
	var texture_path: StringName = ""
	func post_init(_card: Card) -> void: return
	static func gen_gradient(colors: Gradient) -> GradientTexture1D:
		var gradient = GradientTexture1D.new()
		gradient.gradient = colors
		return gradient


class LGBTCard:
	extends SpecialCard
	var gradient: Gradient = gradients["LGBT"]
	func post_init(card: Card) -> void:
		card.static_text_container.material = load("uid://mrb2o32b7sey").duplicate()
		card.static_text_container.material.set_shader_parameter("gradient", gen_gradient(gradient))


class Lesbica:
	extends LGBTCard
	func _init() -> void: gradient = gradients["LESBIAN"]


class Trans:
	extends LGBTCard
	func _init() -> void: gradient = gradients["TRANS"]


# TODO: Random text with _process
