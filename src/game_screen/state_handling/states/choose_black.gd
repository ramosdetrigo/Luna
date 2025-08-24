class_name ChooseBlackState
extends CAHStateHandler

var selected_black_card: Card
var black_cards: Array[Card] = []

func _ready() -> void:
	nodes.right_card_slot.toggle_glow(false)
	nodes.button_controller.toggle_button(false)
	nodes.white_card_holder.dragger.tween_child_modulate(Color.TRANSPARENT)
	
	# Set up split container height
	var target_offset = (nodes.split_container.size.y - 20.0) / 2.0
	nodes.split_container.tween_offset(target_offset, 1.0)
	#nodes.split_container.split_offset = 500
	
	# Erase old cards from the card slots
	clean_card_slots()
	
	# Set up black cards
	var card_slots: Array[CardSlot] = [nodes.left_card_slot, nodes.right_card_slot]
	for i in range(2):
		var new_card = CAH.CARD_SCENE.instantiate()
		new_card.card_type = Card.BLACK_CARD
		new_card.text = state.black_cards[i]
		if state.player_role == CAHState.ROLE_JUDGE:
			new_card.clicked.connect(_on_black_card_clicked.bind(new_card))
		else:
			new_card.set_clickable(false)
		card_slots[i].add_child(new_card)
		black_cards.push_back(new_card)
	
	# Finish config
	if state.player_role == CAHState.ROLE_JUDGE:
		nodes.top_label.animate_text("Escolha uma carta.")
		nodes.bottom_button.pressed.connect(_on_bottom_button_pressed)
	else:
		nodes.top_label.animate_text("Aguarde a escolha do juiz.")


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
