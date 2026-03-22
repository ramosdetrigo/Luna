class_name BasicMod
extends CardModifierComponent

const _NO_COLOR_OVERRIDE: Color = Color(0, 0, 0, 0)

# Path of the texture override
var texture_override: StringName = &""
var text_override: String = ""
var color_override: Color = Color(0, 0, 0, 0)


## By default it overrides the card's text with nothing!.
func _init(texture: StringName = &"", text: String = "", color = _NO_COLOR_OVERRIDE):
	texture_override = texture
	text_override = text
	color_override = color


func apply(card: Card) -> void:
	if not texture_override.is_empty():
		# NOTE: Target for optimization (ResourceLoader.load etc)
		card.set_texture_override(load(texture_override))
	card.static_text.text = text_override
	if color_override != _NO_COLOR_OVERRIDE:
		card.set_text_color(color_override)
