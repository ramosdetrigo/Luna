extends Screen

var _selected_black_card: Card
var _grabbed_card: Card

enum GameState {
	CHOOSE_BLACK,
	CHOOSE_WHITE,
	JUDGEMENT,
	WINNER,
}


@export_range(1, 3)
var white_choices: int = 1

#region STATES
#endregion


#region HELPER METHODS
#endregion


#region CALLBACKS
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	var black_card = Global.PACKED_SCENES.card.instantiate()
	black_card.set_text("Say my name.")
	black_card.card_type = Card.CardType.BLACK_CARD
	black_card.is_interactible = true
	black_card.clicked.connect(_on_black_card_clicked)
	%CentralCardContainer.add_child(black_card)
	%CentralCardContainer.move_child(%WhiteCardHolder, 1)
	
	%CardScroller.generate_placeholder_cards()
	var card_list = %CardScroller.get_card_list()
	for element in card_list:
		if element is Card:
			element.grabbed.connect(func(card: Card): _grabbed_card = card)
			element.dropped.connect(func(_card: Card): _grabbed_card = null)
			element.mouse_entered.connect(_on_card_mouse_entered.bind(element))


func _on_black_card_clicked(card: Card) -> void:
	if not card.is_interactible:
		return
	
	if _selected_black_card == card:
		_selected_black_card.toggle_glow(false)
		_selected_black_card = null
	else:
		if _selected_black_card:
			_selected_black_card.toggle_glow(false)
		card.toggle_glow(true)
		_selected_black_card = card


func _on_send_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%SendButton.text = "Cancelar"
	else:
		%SendButton.text = "Confirmar"
#endregion

# Moves cards inside the card scroller
func _on_card_mouse_entered(card: Card) -> void:
	if not _grabbed_card:
		return
	var card_list = %CardScroller.get_card_list()
	var entered_index = card_list.find(card)
	# Switches the grabbed card position with the hovered card
	if entered_index != -1 and card != _grabbed_card:
		# Checks if card is in the scroller container
		if card_list.find(_grabbed_card) == -1:
			var new_scale = card.get_container_scale()
			_grabbed_card.tween_image_scale(new_scale, 0.2)
		%CardScroller.move_card(_grabbed_card, entered_index)


func _on_white_card_holder_mouse_entered() -> void:
	var card = _grabbed_card # Prevents a weird bug where cards becomes null mid-function?
	if (not card) or card.get_parent() == %WhiteCardHolder:
		return
	var old_scale = card.get_container_scale()
	
	card.reparent(%WhiteCardHolder, true)
	await card.container_resized
	var new_scale = card.get_container_scale()
	card.set_image_scale(old_scale)
	card.tween_image_scale(new_scale, 0.2)


# Dynamic resize that matches most resolutions nicely
func _on_viewport_size_changed() -> void:
	self.size = get_viewport_rect().size
	var new_scale = self.size / Vector2(1280, 720)
	
	var width_guess = max(400 * new_scale.y, 400)
	if size.x > 400 and width_guess < size.x*0.9:
		%CHControl.custom_minimum_size.x = width_guess
	else:
		%CHControl.custom_minimum_size.x = size.x*0.9
	%VSplitContainer.split_offset = %VSplitContainer.size.y/13.0
	
	%Label.custom_minimum_size.x = 400 * new_scale.y
	%Label.add_theme_font_size_override("normal_font_size", 40 * new_scale.y)
	
	%SendButton.custom_minimum_size.x = 360 * new_scale.y
	%SendButton.add_theme_font_size_override("font_size", 24 * new_scale.y)
