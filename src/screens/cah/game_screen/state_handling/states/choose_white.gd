class_name ChooseWhiteState
extends CAHStateHandler

var grabbed_card: Card

func _ready() -> void:
	nodes.button_controller.toggle_button(false)
	nodes.white_card_holder.set_clickable(false)
	nodes.white_card_holder.set_draggable(false)
	nodes.scroller_split.update_offset(false)
	nodes.white_card_holder.dragger.set_child_modulate(Color.WHITE)
	if state.player_role == CAHState.ROLE_PLAYER:
		nodes.right_card_slot.toggle_glow(true)
		var white_choices = state.black_cards[0].pick
		if white_choices == 1:
			nodes.top_label.animate_text("Selecione sua carta.")
		else:
			nodes.top_label.animate_text("Selecione suas cartas.")
	else:
		nodes.top_label.animate_text("Aguarde os jogadores.")
		nodes.right_card_slot.toggle_glow(false)
	for card in nodes.white_card_holder.get_cards():
			nodes.white_card_holder.remove_card(card)
	nodes.bottom_button.toggle_mode = true
	nodes.bottom_button.set_pressed_no_signal(false)
	
	# show card scroller
	nodes.split_container.set_expanded(false)
	
	# (if the previous screen was choose_black)
	# Cleans slots and drags the selected card to the correct container
	if state.previous_game_state == CAHState.STATE_CHOOSE_BLACK:
		clean_center_slot()
		# Assumes the selected card is the left one then checks
		var card_text = state.black_cards[0].text
		var selected_black_card: Card
		var left_black_card: Card = nodes.left_card_slot.get_cards()[0]
		var right_black_card: Card = get_right_slot_card()
		if left_black_card.text == card_text:
			selected_black_card = left_black_card
			clean_right_slot()
		elif right_black_card.text == card_text:
			selected_black_card = right_black_card
			clean_left_slot()
		else: # carta editável ou outro problema
			var new_card = CAH.CARD_SCENE.instantiate()
			new_card.text = card_text
			new_card.card_type = Card.CardType.BLACK_CARD
			new_card.set_clickable(false)
			nodes.left_card_slot.add_child(new_card) # give it a parent to make it reparentable
			selected_black_card = new_card
			clean_left_slot()
			clean_right_slot()
		
		# Move a carta pro local certo (pro centro se não for jogador)
		var old_pos = selected_black_card.dragger.global_position
		if state.player_role != CAHState.ROLE_PLAYER:
			selected_black_card.reparent(nodes.center_card_slot)
			clean_left_slot()
			clean_right_slot()
		else:
			selected_black_card.reparent(nodes.left_card_slot)
		tween_card_to_new(selected_black_card, old_pos)
	else: # The player just entered the game or whatever
		clean_card_slots()
		var black_card = CAH.CARD_SCENE.instantiate()
		black_card.card_type = Card.BLACK_CARD
		black_card.text = state.black_cards[0].text
		black_card.set_clickable(false)
		# Move pro centro se não for jogador
		if state.player_role != CAHState.ROLE_PLAYER:
			nodes.center_card_slot.add_child(black_card)
		else:
			nodes.left_card_slot.add_child(black_card)
	
	# linking cards to functions etc
	var max_index = nodes.card_scroller.get_card_count()
	var card_list = nodes.card_scroller.get_card_list()
	for i in range(1, max_index+1):
		var card = card_list[i]
		card.grabbed.connect(_on_card_grabbed.bind(card))
		card.dropped.connect(_on_card_dropped.bind(card))
		if state.player_role == CAHState.ROLE_PLAYER:
			card.clicked.connect(_on_card_clicked.bind(card))
		card.mouse_entered.connect(_on_card_mouse_entered.bind(card))
	
	nodes.client.new_cards_added.connect(link_new_cards)
	if state.player_role == CAHState.ROLE_PLAYER:
		nodes.white_card_holder.mouse_entered.connect(_on_card_holder_mouse_entered)
		nodes.bottom_button.toggled.connect(_on_bottom_button_toggled)


func get_right_slot_card() -> Card:
	for card in nodes.right_card_slot.get_cards():
		if card != nodes.white_card_holder:
			return card
	# not found
	return null


func link_new_cards(cards: Array[Card]):
	for card in cards:
		card.grabbed.connect(_on_card_grabbed.bind(card))
		card.dropped.connect(_on_card_dropped.bind(card))
		if state.player_role == CAHState.ROLE_PLAYER:
			card.clicked.connect(_on_card_clicked.bind(card))
		card.mouse_entered.connect(_on_card_mouse_entered.bind(card))


func _on_card_grabbed(card: Card) -> void:
	grabbed_card = card

func _on_card_dropped(card: Card) -> void:
	if card == grabbed_card:
		grabbed_card = null


func _on_card_clicked(card: Card) -> void:
	grabbed_card = card
	if is_card_from_holder(card):
		var old_pos = card.dragger.global_position
		# add to center of the screen
		var slot = round(nodes.card_scroller.get_scroll_percentage() * nodes.card_scroller.get_card_count()) + 1
		add_card_to_scroller(card, slot)
		# we need to wait it to resize to do the animation cause reasons
		await card.dragger.resized
		var new_pos = card.dragger.global_position
		var offset = old_pos - new_pos
		card.dragger.set_child_position(offset)
	else:
		var holder_cards = nodes.white_card_holder.get_cards()
		if len(holder_cards) == 0:
			add_card_to_holder(grabbed_card)
		else:
			var last_holder_card = holder_cards.back()
			_on_card_mouse_entered(last_holder_card)
	grabbed_card = null


# TODO: there must be a better way!
# prevents weird bug where when we switch the cards parent container
# it detects mouse_entered again
var just_moved: bool = false
func _on_card_mouse_entered(card: Card) -> void:
	if grabbed_card == null or card == grabbed_card:
		return
	var confirmed: bool = nodes.bottom_button.button_pressed
	# Moving from scroller to holder
	if not confirmed and is_card_from_scroller(grabbed_card) and is_card_from_holder(card):
		# Adds card to holder. Only switches if the holder is full.
		var white_choices = state.black_cards[0].pick
		if nodes.white_card_holder.get_card_count() < white_choices:
			add_card_to_holder(grabbed_card)
			just_moved = true
		else:
			var target_holder_index = nodes.white_card_holder.find_card(card)
			var target_scroller_index = nodes.card_scroller.find_card(grabbed_card)
			add_card_to_holder(grabbed_card, target_holder_index, true)
			
			add_card_to_scroller(card, target_scroller_index, true, false)
	# Moving from holder to scroller
	elif not confirmed and is_card_from_holder(grabbed_card) and is_card_from_scroller(card):
		var target_index = nodes.card_scroller.find_card(card)
		add_card_to_scroller(grabbed_card, target_index)
	else:
		if just_moved:
			just_moved = false
			return
		swap_cards(grabbed_card, card)


func _on_card_holder_mouse_entered() -> void:
	# Prevents a weird bug where grabbed_card becomes null mid-function (?)
	var card = grabbed_card
	if card != null and nodes.white_card_holder.get_card_count() == 0 and not is_card_from_holder(card):
		var end_index = nodes.card_scroller.get_card_count() - 2
		nodes.card_scroller.move_card(grabbed_card, end_index)
		add_card_to_holder(card)


func _on_bottom_button_toggled(toggled: bool) -> void:
	if toggled:
		nodes.white_card_holder.set_draggable(true)
		nodes.top_label.animate_text("Aguarde os outros.")
		
		var cards: Array[String] = []
		for card in nodes.white_card_holder.get_cards():
			if card.is_editable():
				cards.push_back(CAH.wrap_emojis(card.get_display_text()))
				card.set_edit_visible(false)
			else:
				cards.push_back(card.text)
		var card_group = CAHState.new_choice_group(cards, Global.CONFIGS.username)
		nodes.client.choose_white.rpc_id(1, card_group)
	else:
		nodes.client.cancel_ready.rpc_id(1)
		var white_choices = state.black_cards[0].pick
		for card in nodes.white_card_holder.get_cards():
			if card.is_editable():
				card.set_edit_visible(true)
		if white_choices == 1:
			nodes.top_label.animate_text("Selecione sua carta.")
		else:
			nodes.top_label.animate_text("Selecione suas cartas.")
		nodes.white_card_holder.set_draggable(false)


#region OVERRIDES
func add_card_to_holder(card: Control, index: int = -1, skip_anim: bool = false, tween: bool = true) -> void:
	super(card, index, skip_anim, tween)
	var card_count = nodes.white_card_holder.get_card_count()
	var white_choices = state.black_cards[0].pick
	if card_count == 1:
		nodes.right_card_slot.toggle_glow(false)
	if card_count == white_choices:
		nodes.button_controller.toggle_button(true)


func add_card_to_scroller(card: Control, index: int = -1, skip_anim: bool = false, tween: bool = true) -> void:
	super(card, index, skip_anim, tween)
	var card_count = nodes.white_card_holder.get_card_count()
	var white_choices = state.black_cards[0].pick
	if card_count == 0:
		nodes.right_card_slot.toggle_glow(true)
	if card_count < white_choices:
		nodes.button_controller.toggle_button(false)
		nodes.bottom_button.set_pressed(false)
		nodes.bottom_button._pressed()
		nodes.bottom_button.button_pressed = false
#endregion
