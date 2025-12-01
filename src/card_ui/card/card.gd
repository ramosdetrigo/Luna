class_name Card
extends AspectRatioContainer

# Exposing the ImageContainer signals
signal clicked
signal grabbed
signal dropped

enum CardType {
	BLACK_CARD,
	WHITE_CARD
}

const BLACK_CARD: CardType = CardType.BLACK_CARD
const WHITE_CARD: CardType = CardType.WHITE_CARD
var target_image: CompressedTexture2D = CAH.textures[2]
## Either Image or SpriteFrames
var custom_image: PackedByteArray
var custom_gif: PackedByteArray

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
@export
var flipped: bool = false

var pick = 1

# Helper var to know if do a complete or partial flip animation
var _flipping: bool = false

# Tweener to change glow visibility
var _edge_modulate_tween: Tween
# Tweener to change image scale
var _scale_tween: Tween
# Tweener to change image scale
var _flip_tween: Tween

@onready var dragger: Draggable = %ImageContainer


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
		if not flipped:
			%Image.texture = CAH.textures[0]
		target_image = CAH.textures[0]
	else:
		var new_data = CAH.custom_cards.get(text, {"text": text, "texture": CAH.textures[2]})
		%CardText.remove_theme_color_override("default_color")
		%CardText.text = new_data.text
		if not flipped:
			%Image.texture = new_data.texture
		%Image.offset.y = 744 * int(text == "<O tamanho dessa carta>")
		target_image = new_data.texture


func set_editable(toggle: bool) -> void:
	editable = toggle
	%CardText.visible = not editable
	%TextEdit.visible = editable
	%ButtonsContainer.visible = editable
	if card_type == BLACK_CARD:
		%PickSlider.visible = editable
		%TextEdit.material = null
	else:
		%PickSlider.hide()
		%TextEdit.material = CAH.TEXTEDIT_MATERIAL


func set_edit_visible(toggle: bool, pick_visible: bool = true) -> void:
	%ButtonsContainer.visible = toggle
	if card_type == BLACK_CARD:
		%PickSlider.visible = pick_visible
	else:
		%PickSlider.visible = false


func set_flipped(toggle: bool, no_tween: bool = false) -> void:
	if flipped == toggle:
		return
	flipped = toggle
	if _flip_tween:
		_flip_tween.kill()
	
	if no_tween:
		%ImageControl.scale = Vector2(1.0, 1.0)
		if flipped:
			# we only use flipped white cards, so it shouldn't matter.
			%Image.texture = CAH.textures[3] # 3: white_back
			%CardStuff.hide()
		else:
			%Image.texture = target_image
			%CardStuff.show()
		return
	
	_flip_tween = create_tween()
	_flip_tween.set_trans(Tween.TRANS_QUAD)
	
	# Only do partial animation if it was already flipping
	if _flipping:
		_flipping = false
		_flip_tween.tween_property(%ImageControl, "scale", Vector2(1.0, 1.0), 0.1)
		return
	
	_flip_tween.tween_property(%ImageControl, "scale", Vector2(0.0, 1.0), 0.1)
	_flipping = true
	
	_flip_tween.finished.connect(func():
		if flipped:
			# we only use flipped white cards, so it shouldn't matter.
			%Image.texture = CAH.textures[3] # 3: white_back
			%CardStuff.hide()
		else:
			%Image.texture = target_image
			%CardStuff.show()
		_flip_tween.stop()
		_flipping = false
		_flip_tween.tween_property(%ImageControl, "scale", Vector2(1.0, 1.0), 0.1)
		_flip_tween.play()
	, CONNECT_ONE_SHOT)


func set_pick(value: int) -> void:
	%PickSlider.set_value(value)


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


func set_custom_image(img: Image) -> void:
	custom_image = img.save_webp_to_buffer(true, 0.9)
	custom_gif = []
	
	# Scales image down to preserve space if necessary
	const bound_rect := Vector2(454, 731) # CustomImage node size
	var img_size := img.get_size()
	var scale_x := 1.0
	var scale_y := 1.0
	if img_size.x > bound_rect.x:
		scale_x = bound_rect.x / img_size.x
	if img_size.y > bound_rect.y:
		scale_y = bound_rect.y / img_size.y
	var s = min(scale_x, scale_y)
	if s <= 0.98: # 0.98 instead of 1.0 for error margin etc.
		img.resize(img_size.x * s, img_size.y * s, Image.INTERPOLATE_LANCZOS)
	
	%CustomImage.texture = ImageTexture.create_from_image(img)
	%CustomImage.show()
	%ImageSelectButton.set_toggled(true)


func set_custom_image_from_webp(webp_buffer: PackedByteArray) -> void:
	custom_image = webp_buffer
	custom_gif = []
	
	# Scales image down to preserve space if necessary
	var img = Image.new()
	img.load_webp_from_buffer(webp_buffer)
	%CustomImage.texture = ImageTexture.create_from_image(img)
	%CustomImage.show()
	%ImageSelectButton.set_toggled(true)


func set_custom_animated_image(gif_data: PackedByteArray) -> void:
	custom_image = []
	custom_gif = gif_data
	
	var anim: SpriteFrames = GifManager.sprite_frames_from_buffer(gif_data)
	%CustomAnimatedImage.sprite_frames = anim
	
	# Scales keeping aspect ratio
	var gif_res := anim.get_frame_texture("gif", 0).get_size()
	var rect_res: Vector2 = %CustomImage.size
	var scale_x := rect_res.x / gif_res.x
	var scale_y := rect_res.y / gif_res.y
	var s = min(scale_x, scale_y)
	%CustomAnimatedImage.scale = Vector2(s, s)
	
	# Plays and shows the gif
	%CustomAnimatedImage.play("gif")
	%CustomImage.show()
	%ImageSelectButton.set_toggled(true)


func clear_custom_image() -> void:
	custom_image = []
	custom_gif = []
	%CustomImage.texture = null
	%CustomAnimatedImage.sprite_frames = null
	%CustomImage.hide()
	%ImageSelectButton.set_toggled(false)
#endregion METHODS


#region CALLBACKS
func _ready() -> void:
	toggle_glow(glowing)
	%ImageContainer.grabbed.connect(func(): grabbed.emit())
	%ImageContainer.dropped.connect(func(): dropped.emit())
	%ImageContainer.clicked.connect(func(): clicked.emit())
	set_text(text)
	set_pick(pick)
	await %ImageContainer.resized
	%Image.scale = get_image_target_scale()
	%Image.show()
	%ImageContainer.set_child_modulate(Color.TRANSPARENT)
	%ImageContainer.tween_child_modulate(Color.WHITE)
	set_flipped(flipped, true)


func _process(delta: float) -> void:
	if text == "<glitch_text>":
		%CardText.text = _random_text()
	elif text == "Cubo.":
		%Cube.rotate_y(0.5 * delta)


func _on_image_container_resized() -> void:
	tween_image_scale(get_image_target_scale(),0.2)


func _on_image_select_button_toggled(toggled: bool) -> void:
	if not toggled:
		clear_custom_image()
	else:
		%FileDialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	var img = Image.new()
	if path.ends_with(".gif"):
		var gif_data: PackedByteArray = FileAccess.get_file_as_bytes(path)
		set_custom_animated_image(gif_data)
	else:
		var error = img.load(path)
		if error == OK:
			set_custom_image(img)


func _on_file_dialog_canceled() -> void:
	if custom_image == null:
		%ImageSelectButton.set_toggled(false)


func _on_http_request_request_completed(result: int, _response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	
	# Gets the image from the request
	for field: String in headers:
		if field.begins_with("Content-Type: image/"):
			var img_type = field.replace("Content-Type: image/", "")
			if img_type == "gif":
				%TextEdit.text = ""
				set_custom_animated_image(body)
			else:
				var img = Global.load_image_from_buffer(img_type, body)
				if img:
					%TextEdit.text = ""
					set_custom_image(img)
			return


func _on_text_edit_button_toggled(toggled_on: bool) -> void:
	%ImageSelectButton.visible = card_type == WHITE_CARD and toggled_on
	
	%TextEdit.editable = toggled_on
	%TextEdit.selecting_enabled = toggled_on
	
	# In "all editable mode" the card comes as non-editable.
	# Here we make it editable and set the textedit text to the current card text.
	if not editable:
		var previous_text = get_display_text()
		set_text("[Carta editável]")
		%TextEdit.text = previous_text
		set_editable(true)
	
	if toggled_on:
		%TextEdit.grab_focus()
		%TextEdit.mouse_filter = MOUSE_FILTER_STOP
		%TextEdit.mouse_default_cursor_shape = CURSOR_IBEAM
	else:
		%TextEdit.release_focus()
		%TextEdit.mouse_filter = MOUSE_FILTER_IGNORE
		%TextEdit.mouse_default_cursor_shape = CURSOR_ARROW
		# Check if the textedit is an url and an image.
		# If it is, we'll try to change custom_image to the url download.
		if card_type == WHITE_CARD:
			var urlRegex = RegEx.create_from_string('^(http|https)://[^ "]+$')
			var result = urlRegex.search(%TextEdit.text)
			if result:
				%HTTPRequest.request(%TextEdit.text)


func _on_pick_slider_value_changed(value: float) -> void:
	pick = value
	if pick == 1:
		%PickLabel.text = "1 resposta"
	else:
		%PickLabel.text = "%d respostas" % value


func _on_text_edit_focus_entered() -> void:
	@warning_ignore("narrowing_conversion")
	Global.TEXT_EDIT_Y = dragger.global_position.y + dragger.size.y
#endregion CALLBACKS


#region EXPOSE
func is_clickable() -> bool:
	return %ImageContainer.clickable

func set_clickable(clickable: bool) -> void:
	%ImageContainer.clickable = clickable
#endregion EXPOSE


#func _input(event: InputEvent) -> void:
	#if event.is_pressed():
		#set_flipped(not flipped)
