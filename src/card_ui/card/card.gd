class_name Card
extends AspectRatioContainer

# Exposing the ImageContainer signals
signal clicked
signal grabbed
signal dropped
# Signals if the card was toggled to be edited etc.
signal editing
signal edited

enum CardType {
	BLACK_CARD,
	WHITE_CARD
}

const BLACK_CARD: CardType = CardType.BLACK_CARD
const WHITE_CARD: CardType = CardType.WHITE_CARD

# The card's text
@export_multiline
var text: String
# If the card is black or white
@export
var card_type: CardType
@export
var editable: bool
@export
var glowing: bool

# Tweener to change glow visibility
var _edge_modulate_tween: Tween
# Tweener to change image scale
var _scale_tween: Tween

@onready var container: Draggable = %ImageContainer


#region METHODS
func set_text(new_text: String) -> void:
	text = new_text
	%TextViewportTexture.material = null
	%TextEdit.clear()

	# Caso 1: Carta editável
	set_editable(text == "[Carta editável]")

	# Caso especial: Cubo
	var cubo = (text == "Cubo." and card_type == WHITE_CARD)
	%Camera3D.visible = cubo
	%Cube.visible = cubo
	%OmniLight3D.visible = cubo
	%CubeViewportTexture.visible = cubo
	%CubeViewport.disable_3d = not cubo

	set_type(card_type)

	# Caso 3: Gradiente
	if card_type != BLACK_CARD:
		var gradient = CAH.gradient_cards.get(text)
		if gradient:
			var gradient_texture := GradientTexture1D.new()
			gradient_texture.gradient = gradient
			var gradient_material := CAH.BASE_GRADIENT_MATERIAL.duplicate()
			gradient_material.set_shader_parameter("gradient", gradient_texture)
			%TextViewportTexture.material = gradient_material


func set_type(type: CardType) -> void:
	card_type = type
	if type == BLACK_CARD or text == "Carta preta.":
		%CardText.add_theme_color_override("default_color", Color.WHITE)
		%CardText.text = text.replace("_", "____")
		%Image.texture = CAH.textures[0]
	else:
		var new_data = CAH.custom_cards.get(text, {"text": text, "texture": CAH.textures[2]})
		%CardText.remove_theme_color_override("default_color")
		%CardText.text = new_data.text
		%Image.texture = new_data.texture
		%Image.offset.y = 744 * int(text == "<O tamanho dessa carta>")


func set_editable(toggle: bool) -> void:
	editable = toggle
	%CardText.visible = not editable
	%TextEdit.visible = editable
	%TextEditButton.visible = editable
	if card_type == BLACK_CARD:
		%TextEdit.material = null
		%TextEdit.add_theme_color_override("default_color", Color.WHITE)
		%TextEdit.add_theme_color_override("font_readonly_color", Color.WHITE)
	else:
		%TextEdit.material = CAH.TEXTEDIT_MATERIAL
		%TextEdit.remove_theme_color_override("default_color")
		%TextEdit.add_theme_color_override("font_readonly_color", Color.BLACK)


func get_display_text() -> String:
	if text == "[Carta editável]":
		return %TextEdit.text
	else:
		return %CardText.text


func get_image_scale() -> Vector2:
	return %ImageContainer.scale


func get_image_target_scale() -> Vector2:
	var card_size = %ImageContainer.size
	var target_scale = card_size / CAH.CARD_IMAGE_SIZE
	return target_scale


func get_text_height() -> float:
	var y_scale = get_image_target_scale().y
	if is_editable():
		var line_height = %TextEdit.get_line_height()
		var line_spacing = %TextEdit.get_line_count()
		return line_height * line_spacing
	else:
		return (%CardText.get_content_height() + 35) * y_scale


func is_editable() -> bool:
	return text == "[Carta editável]"


func set_image_scale(sc: Vector2) -> void:
	%Image.scale = sc

func tween_image_scale(sc: Vector2, time: float = 0.2) -> void:
	if _scale_tween:
		_scale_tween.kill()
	_scale_tween = create_tween()
	_scale_tween.set_ease(Tween.EASE_OUT)
	_scale_tween.set_trans(Tween.TRANS_QUAD)
	_scale_tween.tween_property(%Image, "scale", sc, time)


func toggle_glow(enable: bool) -> Tween:
	glowing = enable
	if _edge_modulate_tween:
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
#endregion METHODS


#region CALLBACKS
func _ready() -> void:
	toggle_glow(glowing)
	%ImageContainer.grabbed.connect(func(): grabbed.emit())
	%ImageContainer.dropped.connect(func(): dropped.emit())
	%ImageContainer.clicked.connect(func(): clicked.emit())
	set_text(text)
	await %ImageContainer.resized
	%Image.scale = get_image_target_scale()
	%Image.show()


func _on_image_container_resized() -> void:
	tween_image_scale(get_image_target_scale(),0.2)


func _process(delta: float) -> void:
	if text == "<glitch_text>":
		%CardText.text = _random_text()
	elif text == "Cubo.":
		%Cube.rotate_y(0.5 * delta)


func _on_text_edit_button_toggled(toggled_on: bool) -> void:
	%TextEdit.editable = toggled_on
	%TextEdit.selecting_enabled = toggled_on
	
	if toggled_on:
		%TextEdit.grab_focus()
		%TextEdit.mouse_default_cursor_shape = CURSOR_IBEAM
		editing.emit()
	else:
		%TextEdit.release_focus()
		%TextEdit.mouse_default_cursor_shape = CURSOR_ARROW
		edited.emit()
#endregion CALLBACKS


#region EXPOSE
func is_clickable() -> bool:
	return %ImageContainer.clickable

func set_clickable(clickable: bool) -> void:
	%ImageContainer.clickable = clickable
#endregion CALLBACKS
