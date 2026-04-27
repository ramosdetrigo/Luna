class_name TextGradientMod
extends CardModifierComponent

var gradient: Gradient


func _init(g: Gradient) -> void:
	gradient = g


func gen_gradient() -> GradientTexture1D:
	var g = GradientTexture1D.new()
	g.gradient = gradient
	return g


func apply(card: Card) -> void:
	card.static_text_container.material = load("uid://mrb2o32b7sey").duplicate()
	card.static_text_container.material.set_shader_parameter("gradient", gen_gradient())
