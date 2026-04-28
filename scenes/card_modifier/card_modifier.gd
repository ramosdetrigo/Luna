class_name CardModifier
extends Resource

@export var json_data: Dictionary


## By default it overrides the card's text with nothing!.
func _init(json: Dictionary):
	json_data = json


func apply(card: Card) -> void:
	var text = json_data.get("text_override")
	if text is String:
		card.static_text.text = text

	var color = json_data.get("text_color_override")
	if color is String:
		card.set_text_color(Color(color))

	# TODO: support Base64 & URL
	var texture = json_data.get("texture_override")
	if texture is String:
		card.set_texture_override(load(texture))

	var height = json_data.get("height_override")
	if height is int:
		card.height_override = height


func process(_card: Card, _delta: float) -> void:
	pass


func remove(_card: Card) -> void:
	pass
