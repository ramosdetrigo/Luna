class_name Card
extends AspectRatioContainer

# Signals if the card was toggled to be edited etc.
signal editing(Card, bool)
# TODO: should is_interactible make them stop being draggable?

enum CardType {
	BLACK_CARD,
	WHITE_CARD
}

#region CONSTANTS
# 534,812: base card image resolution
const IMG_SIZE: Vector2 = Vector2(534, 812)

# Shader material that fixes that stupid emoji bug
const TEXTEDIT_MATERIAL = preload("res://src/card_ui/card/text_edit_material.tres")

# Base gradient material for special cards
const BASE_GRADIENT_MATERIAL = preload("res://src/card_ui/card/gradient_material.tres")

# Color gradients for special cards
const gradients: Array[Gradient] = [
	preload("res://src/card_ui/card/gradients/aroace.tres"),     # 0
	preload("res://src/card_ui/card/gradients/aromantic.tres"),  # 1
	preload("res://src/card_ui/card/gradients/asexual.tres"),    # 2
	preload("res://src/card_ui/card/gradients/bisexual.tres"),   # 3
	preload("res://src/card_ui/card/gradients/demisexual.tres"), # 4
	preload("res://src/card_ui/card/gradients/lesbian.tres"),    # 5
	preload("res://src/card_ui/card/gradients/lgbt.tres"),       # 6
	preload("res://src/card_ui/card/gradients/nonbinary.tres"),  # 7
	preload("res://src/card_ui/card/gradients/pansexual.tres"),  # 8
	preload("res://src/card_ui/card/gradients/trans.tres")       # 9
]

# Lookup table for special cards that use gradients
const gradient_cards: Dictionary[String, Gradient] = {
	"Aroaces.": gradients[0],
	"Arromânticos.": gradients[1],
	"Assexuais.": gradients[2],
	"Bissexuais.": gradients[3],
	"Demissexuais.": gradients[4],
	"Lésbicas.": gradients[5],
	"LGTV.": gradients[6],
	"Gays.": gradients[6],
	"Viado.": gradients[6],
	"Arco-íris!": gradients[6],
	"Não-binários": gradients[7],
	"Panssexuais": gradients[8],
	"Trans.": gradients[9]
}

# All card textures. Preloading them cause we're gonna use them all anyway
# and it really isn't all that heavy on RAM.
const textures: Array[CompressedTexture2D] = [
	preload("res://assets/images/cards/black_front.png"),   # 0
	preload("res://assets/images/cards/black_back.png"),    # 1
	preload("res://assets/images/cards/white_front.png"),   # 2
	preload("res://assets/images/cards/white_back.png"),    # 3
	preload("res://assets/images/cards/A.png"),             # 4
	preload("res://assets/images/cards/big.png"),           # 5
	preload("res://assets/images/cards/blood.png"),         # 6
	preload("res://assets/images/cards/bolsonaro.png"),     # 7
	preload("res://assets/images/cards/brasil.png"),        # 8
	preload("res://assets/images/cards/felps_bombado.png"), # 9
	preload("res://assets/images/cards/pau.png"),           # 10
]

# Lookup table for custom cards that use specific textures.
const custom_cards: Dictionary[String, Dictionary] = {
	"<glitch_text>": {"text": "r@^^()5", "texture": textures[2]},
	"<A>": {"text": "", "texture": textures[4]},
	"<O tamanho dessa carta>": {"text": "O tamanho dessa carta.", "texture": textures[5]},
	"<As abelhas chegaram>": {"text": "As abelhas chegaram.", "texture": textures[6]},
	"<Bolsonaro>": {"text": "", "texture": textures[7]},
	"<Brasil>": {"text": "", "texture": textures[8]},
	"<Felps bombado>": {"text": "", "texture": textures[9]},
	"<Pau>": {"text": "", "texture": textures[10]}
}
#endregion

# The card's text
@export_multiline
var text: String
# If the card is black or white
@export
var card_type: CardType
@export
var glowing: bool

# Tweener to change glow visibility
var _edge_modulate_tween: Tween


#region METHODS
func set_text(new_text: String) -> void:
	text = new_text
	%TextViewportTexture.material = null
	
	# Caso 1: Carta editável
	%TextEdit.clear()
	if text == "[Carta editável]":
		%CardText.hide()
		%TextEdit.show()
		%TextEditButton.show()
		if card_type == CardType.BLACK_CARD:
			%TextEdit.material = null
			%TextEdit.add_theme_color_override("default_color", Color.WHITE)
		else:
			%TextEdit.material = TEXTEDIT_MATERIAL
			%TextEdit.remove_theme_color_override("default_color")
	else:
		%CardText.show()
		%TextEdit.hide()
		%TextEditButton.hide()
	
	# Tests for Cubo.
	var enable = text == "Cubo." and card_type == CardType.WHITE_CARD
	%Camera3D.visible = enable
	%Cube.visible = enable
	%OmniLight3D.visible = enable
	%CubeViewportTexture.visible = enable
	%CubeViewport.disable_3d = not enable

	# Case 2: Black card
	if card_type == CardType.BLACK_CARD or text == "Carta preta.":
		%CardText.add_theme_color_override("default_color", Color.WHITE)
		%CardText.text = text.replace("_", "____")
		%Image.texture = textures[0]
		return
	
	# Tests for gradient
	var gradient: Gradient = gradient_cards.get(text, null)
	if gradient:
		var gradient_material := BASE_GRADIENT_MATERIAL.duplicate()
		var gradient_texture := GradientTexture1D.new()
		gradient_texture.gradient = gradient
		gradient_material.set_shader_parameter("gradient", gradient_texture)
		%TextViewportTexture.material = gradient_material

	# Searches for a custom card with text as key.
	# If there is none, makes a plain white card.
	var new_data = custom_cards.get(text, {"text": text, "texture": textures[2]})
	# Applies correct white card text, text color, and texture.
	%CardText.remove_theme_color_override("default_color")
	%Image.texture = new_data.texture
	%CardText.text = new_data.text
	if text == "<O tamanho dessa carta>":
		%Image.offset.y = 744


# Changes image position directly
func set_image_position(target: Vector2) -> void:
	%Image.position = target


func set_image_global_position(target: Vector2) -> void:
	%Image.global_position = target


func set_image_scale(target: Vector2) -> void:
	%Image.scale = target


func get_image_local_position() -> Vector2:
	return %Image.position


func get_image_global_position() -> Vector2:
	return %Image.global_position


func get_image_scale() -> Vector2:
	return %Image.scale


func get_display_text() -> String:
	if text == "[Carta editável]":
		return %TextEdit.text
	else:
		return %CardText.text


func get_container_scale() -> Vector2:
	var card_size = %ImageContainer.size
	var target_scale = card_size / IMG_SIZE
	return target_scale


func get_container_local_position() -> Vector2:
	return %ImageContainer.position


func get_container_global_position() -> Vector2:
	return %ImageContainer.global_position


func get_text_height() -> float:
	var y_scale = get_container_scale().y
	if is_editable():
		var line_height = %TextEdit.get_line_height()
		var line_spacing = %TextEdit.get_line_count()
		return line_height * line_spacing
	else:
		return (%CardText.get_content_height() + 35) * y_scale


func is_editable() -> bool:
	return text == "[Carta editável]"


func toggle_glow(enable: bool) -> Tween:
	glowing = enable
	_edge_modulate_tween.kill()
	_edge_modulate_tween = %Edge.create_tween().set_trans(Tween.TRANS_QUAD)
	_edge_modulate_tween.set_ease(Tween.EASE_OUT)
	if enable:
		%Edge.show()
		_edge_modulate_tween.tween_property(%Edge, "modulate", Color.WHITE, 0.5)
	else:
		_edge_modulate_tween.tween_property(%Edge, "modulate", Color.TRANSPARENT, 0.5)
		_edge_modulate_tween.finished.connect(%Edge.hide)
	return _edge_modulate_tween


# Generates a random garbled string of text (used for <glitch_text> card)
static func _random_text() -> String:
	const characters = "!@#$%¨&*()-=+_[]{}/?;:<>.,~^´`abcdefghijklmnopqrstuvwxyz"
	var output = ""
	
	for i in range(randi_range(8, 14)):
		var c = characters[randi_range(0, len(characters) - 1)]
		output += c
	
	return output
#endregion


#region CALLBACKS
func _ready() -> void:
	# Creates a valid tween by... killing it? Godot is weird sometimes
	_edge_modulate_tween = create_tween()
	_edge_modulate_tween.kill()
	# Update card text, scale, etc.
	set_text(text)
	
	# we have to await control to be resized because...
	# the node is... not actually ready... or whatever...
	await %ImageContainer.resized
	# Updates the card size, scale, position etc based on the control
	var card_size = %ImageContainer.size
	var target_scale = card_size / IMG_SIZE
	%Image.scale = target_scale
	%Image.show()


func _process(delta: float) -> void:
	if text == "<glitch_text>":
		%CardText.text = _random_text()
	if text == "Cubo.":
		%Cube.rotate_y(0.5 * delta)


func _on_text_edit_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%TextEdit.mouse_filter = MOUSE_FILTER_STOP
		%TextEdit.grab_focus()
		editing.emit(self, true)
	else:
		%TextEdit.mouse_filter = MOUSE_FILTER_IGNORE
		%TextEdit.release_focus()
		editing.emit(self, false)
#endregion
