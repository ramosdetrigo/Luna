@tool
class_name GradientMod
extends CardModifier
## Gradient mod schema:
## "mod_type": "gradient"
## "target": Enum<Text, Texture, Both>
## "gradient": <String || Array[Color]>
## "gradient_speed": float
## "gradient_angle": float

enum GradientTarget {
	TEXT,
	TEXTURE,
	BOTH,
}

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

@export var target: GradientTarget = GradientTarget.TEXT:
	set(t):
		target = t
		if _target_card:
			remove(_target_card)
			apply(_target_card)
@export var gradient: Gradient:
	set(g):
		gradient = g
		if _target_card:
			apply(_target_card)
@export var speed: float = 0.6:
	set(s):
		speed = s
		if _target_card:
			apply(_target_card)
@export var angle: float = 1.0:
	set(a):
		angle = a
		if _target_card:
			apply(_target_card)

var _shader_material: ShaderMaterial = GRADIENT_SHADER.duplicate()
var _gradient_texture: GradientTexture1D


## Constructor from a dict following the mod's schema, usually obtained from a json.
func _init(mod_data = null):
	if mod_data is not Dictionary:
		return
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

	_gradient_texture = gen_gradient_texture()


func gen_gradient_texture() -> GradientTexture1D:
	var g = GradientTexture1D.new()
	g.gradient = gradient
	return g


func apply(card: Card) -> void:
	super(card)
	match target:
		GradientTarget.TEXT:
			_apply_to_text(card)
		GradientTarget.TEXTURE:
			_apply_to_texture(card)
		GradientTarget.BOTH:
			_apply_to_text(card)
			_apply_to_texture(card)


func remove(card: Card) -> void:
	super(card)
	match target:
		GradientTarget.TEXT:
			card.static_text_container.material = null
		GradientTarget.TEXTURE:
			card.card_texture.material = null
		GradientTarget.BOTH:
			card.card_texture.material = null
			card.static_text_container.material = null


func _apply_to_text(card: Card) -> void:
	card.static_text_container.material = _shader_material
	card.static_text_container.material.set_shader_parameter("gradient", _gradient_texture)
	card.static_text_container.material.set_shader_parameter("speed", speed)
	card.static_text_container.material.set_shader_parameter("angle", angle)


func _apply_to_texture(card: Card) -> void:
	card.card_texture.material = _shader_material
	card.card_texture.material.set_shader_parameter("gradient", _gradient_texture)
	card.card_texture.material.set_shader_parameter("speed", speed)
	card.card_texture.material.set_shader_parameter("angle", angle)
