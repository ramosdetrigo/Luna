@tool
class_name Card
extends AspectRatioContainer

enum CardType {
	WHITE,
	BLACK
}

# Node exports
@export var editable_text: TextEdit
@export var static_text: RichTextLabel
@export var card_texture: Sprite2D
@export var static_text_container: SubViewportContainer
@export var buttons_container: HBoxContainer
@export var confirm_edit_button: Button
@export var edit_button: Button
@export var cancel_edit_button: Button


@export_multiline var text: String = "" : set = set_text
@export var card_type: CardType = CardType.WHITE : set = set_card_type
@export var flipped: bool = false : set = flip
@export var texture_override: CompressedTexture2D = null : set = set_texture_override
@export var height_override: float = -1.0
@export var editable: bool = false : set = set_editable

var card_modifier: CardModifier = null : set = set_card_modifier


func set_editable(edit: bool) -> void:
	editable = edit
	if not buttons_container: await ready
	buttons_container.visible = editable
	toggle_editing(false)


func toggle_editing(toggle: bool) -> void:
	editable_text.visible = toggle
	static_text.visible = not toggle
	
	edit_button.visible = not toggle
	confirm_edit_button.visible = toggle
	cancel_edit_button.visible = toggle


func confirm_edit() -> void:
	set_text(editable_text.text)
	toggle_editing(false)


func cancel_edit() -> void:
	editable_text.text = text
	toggle_editing(false)


## Sets the card's text
func set_text(t: String) -> void:
	text = t
	if not editable_text: await ready
	editable_text.text = t
	static_text.text = t
	
	# Card reset
	texture_override = null
	static_text_container.material = null
	set_card_type(card_type)
	
	# Special card check
	set_card_modifier(CardData.get_card_modifier(self, t))


func set_card_modifier(mod: CardModifier) -> void:
	if card_modifier != null:
		card_modifier.remove()
		remove_child(card_modifier)
	card_modifier = mod
	if mod != null:
		add_child(card_modifier)
		card_modifier.apply()


func set_texture_override(texture: CompressedTexture2D) -> void:
	texture_override = texture
	_update_texture()


## Sets the card's type and automatically changes its texture and text color
func set_card_type(type: CardType) -> void:
	card_type = type
	if type == CardType.WHITE:
		set_text_color(Color.BLACK)
	else:
		set_text_color(Color.WHITE)
	_update_texture()


## Changes text color for both static and editable text
func set_text_color(color: Color) -> void:
	if not static_text: await ready
	static_text.add_theme_color_override("default_color", color)
	editable_text.add_theme_color_override("font_color", color)
	editable_text.add_theme_color_override("font_readonly_color", color)


## Sets the card's texture
func set_texture(texture: CompressedTexture2D) -> void:
	if not card_texture: await ready
	card_texture.texture = texture


func flip(f: bool = not flipped) -> void:
	flipped = f
	_update_texture()


func get_text_height() -> float:
	const MARGIN: float = 10.0
	if height_override != -1.0: return height_override
	# FIXME: is scale needed?
	# static_text has "fit content" enabled, so the size is just
	# size.y + y offset + a little margin
	return static_text.size.y + static_text.position.y + MARGIN


func _update_texture() -> void:
	if flipped:
		# Memory optimization: we don't use black flipped cards,
		# so the black_back texture is never loaded
		set_texture(CardData.MAIN_TEXTURES["white_back"])
	elif texture_override != null:
		set_texture(texture_override)
	elif card_type == CardType.WHITE:
		set_texture(CardData.MAIN_TEXTURES["white_front"])
	else: 
		set_texture(CardData.MAIN_TEXTURES["black_front"])
