class_name ChooseBlackState
extends CAHStateHandler

var selected_black_card: Card
var black_cards: Array[Card] = []
var grabbed_card: Card

func _ready() -> void:
	nodes.right_card_slot.toggle_glow(false)
	nodes.button_controller.toggle_button(false)
	nodes.card_scroller.toggle_visible(true)
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
		if state.player_role == CAHState.ROLE_JUDGE:
			new_card.clicked.connect(_on_black_card_clicked.bind(new_card))
		else:
			new_card.set_clickable(false)
		card_slots[i].add_child(new_card)
		black_cards.push_back(new_card)
	
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
		nodes.bottom_button.pressed.connect(_on_bottom_button_pressed)
	else:
		nodes.top_label.animate_text("Aguarde a escolha do juiz.")


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
		nodes.bottom_button.toggle_mode = false
		nodes.bottom_button.button_pressed = false
		nodes.bottom_button.text = "Confirmar"
		nodes.button_controller.toggle_button(true)
	card.toggle_glow(not card.glowing)


func _on_bottom_button_pressed() -> void:
	for card in black_cards:
		card.set_clickable(false)
		card.clicked.disconnect(_on_black_card_clicked)
	nodes.button_controller.toggle_button(false)
	var selected_bc_text = selected_black_card.text
	for card in state.black_cards:
		if card.text == selected_bc_text:
			nodes.client.choose_black.rpc_id(1, card)
			return
