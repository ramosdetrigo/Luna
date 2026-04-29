@abstract
class_name CardModifier
extends Resource
## Base mod schema:
## "mod_type": "basic"
## "text_override": String
## "text_color_override": String (hex code)
## "texture_override": String (path || base64 || url)
## "height_override": int (line count)


## Constructor from a dict following the mod's schema, usually obtained from a json.
func apply(_card: Card) -> void:
	pass


func process(_card: Card, _delta: float) -> void:
	pass


func remove(_card: Card) -> void:
	pass
