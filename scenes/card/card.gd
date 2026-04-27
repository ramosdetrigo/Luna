@tool
class_name Card
extends AspectRatioContainer

signal pressed
signal drag_started
signal drag_stopped

enum CardType {
	WHITE,
	BLACK,
}

const CARD_SCENE: PackedScene = preload("uid://crifadt6elvi7")

# Node exports
@export var editable_text: TextEdit
@export var static_text: RichTextLabel
@export var card_texture: Sprite2D
@export var static_text_container: SubViewportContainer
@export var buttons_container: HBoxContainer
@export var confirm_edit_button: Button
@export var edit_button: Button
@export var cancel_edit_button: Button
@export var card_border: Sprite2D
@export var texture_container: CardTextureContainer
@export var custom_image: CustomImageContainer
@export_multiline var text: String = "":
	set = set_text
@export var type: CardType = CardType.WHITE:
	set = set_card_type
@export var flipped: bool = false:
	set = flip
@export var texture_override: CompressedTexture2D = null:
	set = set_texture_override
## Text's height in number of lines (-1 disables override)
@export var height_override: float = -1.0
@export var editable: bool = false:
	set = set_editable
@export var glowing_border: bool = false:
	set = toggle_border

var card_modifier: CardModifier = null:
	set = set_card_modifier


static func new_card(card_text: String, card_type: CardType, is_editable: bool = false, is_flipped: bool = false) -> Card:
	var card: Card = CARD_SCENE.instantiate()
	card.editable = is_editable
	card.flipped = is_flipped
	card.type = card_type
	card.text = card_text # set text last 'cause set_text could override editable

	return card


func _ready() -> void:
	texture_container.pressed.connect(pressed.emit)
	texture_container.drag_started.connect(drag_started.emit)
	texture_container.drag_stopped.connect(drag_stopped.emit)


## Makes the card editable or not - Shows or hides the edit buttons
func set_editable(edit: bool) -> void:
	editable = edit
	if not buttons_container:
		await ready
	buttons_container.visible = editable

	toggle_editing(false)


## Switches the visibility between the static and editable text:
## Toggles the TextEdit node.
func toggle_editing(toggle: bool) -> void:
	editable_text.visible = toggle
	static_text.visible = not toggle

	edit_button.visible = not toggle
	confirm_edit_button.visible = toggle
	cancel_edit_button.visible = toggle


## Toggles a white border around the card - useful for "card selected" etc.
func toggle_border(toggle: bool) -> void:
	glowing_border = toggle
	if toggle:
		card_border.fade_in()
	else:
		card_border.fade_out()


## Sets the card text to the TextEdit's text
func confirm_edit() -> void:
	set_text(editable_text.text.rstrip(" \n"))
	toggle_editing(false)


## Cancels the edit and resets the TextEdit's text back to the current card text.
func cancel_edit() -> void:
	editable_text.text = text
	toggle_editing(false)


## Sets the card's text and updates its texture, modifier, etc.
func set_text(t: String) -> void:
	text = t
	if not editable_text:
		await ready
	editable_text.text = t
	static_text.text = t

	# Card reset
	texture_override = null
	static_text_container.material = null
	set_card_type(type)

	# Special card check
	set_card_modifier(CardData.get_card_modifier(self, t))


## Changes the card's modifier for special cards
func set_card_modifier(mod: CardModifier) -> void:
	if card_modifier != null:
		card_modifier.remove()
		remove_child(card_modifier)
	card_modifier = mod
	if mod != null:
		add_child(card_modifier)
		card_modifier.apply()


## Overrides the card's texture with another one
func set_texture_override(texture: CompressedTexture2D) -> void:
	texture_override = texture
	_update_texture()


## Sets the card's type and automatically changes its texture and text color
func set_card_type(card_type: CardType) -> void:
	type = card_type
	if type == CardType.WHITE:
		set_text_color(Color.BLACK)
	else:
		set_text_color(Color.WHITE)
	_update_texture()


## Changes text color for both static and editable text
func set_text_color(color: Color) -> void:
	if not static_text:
		await ready
	static_text.add_theme_color_override("default_color", color)
	editable_text.add_theme_color_override("font_color", color)
	editable_text.add_theme_color_override("font_readonly_color", color)


## Sets the card's texture
func set_texture(texture: CompressedTexture2D) -> void:
	if not card_texture:
		await ready
	card_texture.texture = texture


## Flips the card: flipped = back side up
func flip(f: bool = not flipped) -> void:
	flipped = f
	_update_texture()


func get_text_height() -> float:
	const LINE_SIZE: float = 59.0
	const MARGIN: float = 20.0
	var text_height: float
	if height_override == -1.0:
		text_height = max(static_text.size.y, LINE_SIZE)
	else:
		text_height = LINE_SIZE * height_override
	# static_text has "fit content" enabled, so the size is just:
	# size.y + border offset + a little margin
	# (scale is needeed 'cause we're scaling the node's parent (CardTexture))
	return (text_height + static_text.position.y + MARGIN) * texture_container.scale_target


func _update_texture() -> void:
	if flipped:
		# Memory optimization: we don't use black flipped cards,
		# so the black_back texture is never loaded
		set_texture(CardData.MAIN_TEXTURES["white_back"])
	elif texture_override != null:
		set_texture(texture_override)
	elif type == CardType.WHITE:
		set_texture(CardData.MAIN_TEXTURES["white_front"])
	else:
		set_texture(CardData.MAIN_TEXTURES["black_front"])
