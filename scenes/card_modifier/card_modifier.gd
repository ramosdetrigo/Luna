@tool
class_name CardModifier
extends Resource
## Base mod schema:
## "mod_type": "basic"
## "text_override": String
## "text_color_override": String (hex code)
## "texture_override": String (path || base64 || url)
## "height_override": int (line count)

@export_group("Text override")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var override_text: bool = false
@export_multiline
var text: String = ""

@export_group("Text color override")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var override_text_color: bool = false
@export var text_color: Color = Color.BLACK

@export_group("Texture override")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var override_texture: bool = false
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg")
var texture_path: String = ""

@export_group("Height override")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var override_height: bool = false
@export var height: int = 0


func _init(mod_data = null):
	if mod_data is not Dictionary:
		return

	mod_data = mod_data as Dictionary
	var t = mod_data.get("text_override")
	if t is String:
		override_text = true
		text = t

	var c = mod_data.get("text_color_override")
	if c is String:
		override_text_color = true
		text_color = Color(c)

	var tx = mod_data.get("texture_override")
	if tx is String:
		override_texture = true
		texture_path = tx

	var h = mod_data.get("height_override")
	if h is int:
		override_height = true
		height = h


func apply(card: Card) -> void:
	if override_text:
		card.static_text.text = text

	if override_text_color:
		card.set_text_color(text_color)

	# TODO: support Base64 & URL
	if override_texture:
		card.set_texture_override(load(texture_path))

	if override_height:
		card.height_override = height


func process(_card: Card, _delta: float) -> void:
	pass


func remove(_card: Card) -> void:
	pass
