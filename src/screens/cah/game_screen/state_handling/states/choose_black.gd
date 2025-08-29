class_name ChooseBlackState
extends CAHStateHandler

var selected_black_card: Card
var black_cards: Array[Card] = []
var grabbed_card: Card


func _ready() -> void:
	nodes.right_card_slot.toggle_glow(false)
	nodes.button_controller.toggle_button(false)
	if state.previous_game_state == CAHState.STATE_CONNECTING:
		nodes.scroller_split.modulate = Color.TRANSPARENT
		get_tree().create_timer(0.25).timeout.connect(func():
			nodes.scroller_split.modulate = Color.WHITE)
	var ss_tween = nodes.scroller_split.tween_offset(false)
	ss_tween.finished.connect(func():
		nodes.scroller_split.update_offset(false))
	var wch_tween = nodes.white_card_holder.dragger.tween_child_modulate(Color.TRANSPARENT)
	wch_tween.finished.connect(func():
		for card in nodes.white_card_holder.get_cards():
			nodes.white_card_holder.remove_card(card))
	# hide card scroller
	nodes.split_container.set_expanded(true)
	
	# Erase old cards from the card slots
	clean_card_slots()
	
	# Set up black cards
	var card_slots: Array[CardSlot] = [nodes.left_card_slot, nodes.right_card_slot]
	for i in range(2):
		var new_card = CAH.CARD_SCENE.instantiate()
		new_card.card_type = Card.BLACK_CARD
		new_card.text = state.black_cards[i].text
		new_card.pick = state.black_cards[i].pick
		card_slots[i].add_child(new_card)
		if state.player_role == CAHState.ROLE_JUDGE:
			new_card.clicked.connect(_on_black_card_clicked.bind(new_card))
			if state.edit_all_black:
				new_card.set_edit_visible(true, false)
		else:
			new_card.set_clickable(false)
			# Don't let players edit black cards
			new_card.set_edit_visible(false, false)
		black_cards.push_back(new_card)
		new_card.dragger.set_child_modulate(Color.TRANSPARENT)
		new_card.dragger.tween_child_modulate(Color.WHITE)
	
	var max_index = nodes.card_scroller.get_card_count()
	var card_list = nodes.card_scroller.get_card_list()
	for i in range(1, max_index+1):
		var card = card_list[i]
		card.grabbed.connect(func(): grabbed_card = card)
		card.dropped.connect(func(): grabbed_card = null)
		card.mouse_entered.connect(func():
			if card != grabbed_card:
				swap_cards(grabbed_card, card))
	
	nodes.client.new_cards_added.connect(link_new_cards)
	# Finish config
	if state.player_role == CAHState.ROLE_JUDGE:
		nodes.top_label.animate_text("Escolha uma carta.")
		nodes.bottom_button.toggled.connect(_on_bottom_button_toggled)
	else:
		nodes.top_label.animate_text("Aguarde a escolha de %s." % state.current_judge)
		for card in black_cards:
			if card.text == "[Carta editável]":
				card.set_edit_visible(false)


func _exit_tree() -> void:
	for card in black_cards:
		card.toggle_glow(false)
		# Makes cards into a normal card if they're editable.
		if card.is_editable():
			var regex = RegEx.create_from_string("_+")
			var card_text = card.get_display_text()
			card.set_text(regex.sub(card_text, "_", true))


func link_new_cards(cards: Array[Card]):
	for card in cards:
		card.grabbed.connect(func(): grabbed_card = card)
		card.dropped.connect(func(): grabbed_card = null)
		card.mouse_entered.connect(func():
			if card != grabbed_card:
				swap_cards(grabbed_card, card))


func _on_black_card_clicked(card: Card) -> void:
	if selected_black_card == card:
		selected_black_card = null
		nodes.button_controller.toggle_button(false)
	else:
		if selected_black_card != null:
			selected_black_card.toggle_glow(false)
		selected_black_card = card
		nodes.bottom_button.toggle_mode = true
		nodes.bottom_button.set_pressed_no_signal(false)
		nodes.bottom_button.text = "Confirmar"
		nodes.button_controller.toggle_button(true)
	card.toggle_glow(not card.glowing)


func _on_bottom_button_toggled(toggled: bool) -> void:
	if toggled:
		nodes.top_label.animate_text("Aguarde os outros.")
		for card in black_cards:
			card.set_clickable(false)
			card.clicked.disconnect(_on_black_card_clicked)
			if card.text == "[Carta editável]":
				card.set_edit_visible(false)
		var selected_bc_text = selected_black_card.text
		var selected_bc_pick = selected_black_card.pick
		if selected_bc_text == "[Carta editável]":
			var regex = RegEx.create_from_string("_+")
			selected_bc_text = selected_black_card.get_display_text()
			selected_bc_text = regex.sub(selected_bc_text, "_", true)
		var card = {
			"text": selected_bc_text,
			"pick": selected_bc_pick
		}
		nodes.client.choose_black.rpc_id(1, card)
	else:
		nodes.client.cancel_ready.rpc_id(1)
		nodes.top_label.animate_text("Escolha uma carta.")
		for card in black_cards:
			card.set_clickable(true)
			card.clicked.connect(_on_black_card_clicked.bind(card))
			if card.text == "[Carta editável]":
				card.set_edit_visible(true)
