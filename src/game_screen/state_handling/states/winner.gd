class_name WinnerState
extends CAHStateHandler

var timers: Array[SceneTreeTimer] = []
var black_card: Card

func _ready() -> void:
	nodes.button_controller.toggle_button(false)
	nodes.right_card_slot.toggle_glow(false)
	var wch_tweener = nodes.white_card_holder.dragger.tween_child_modulate(Color.TRANSPARENT)
	nodes.white_card_holder.set_clickable(false)
	nodes.white_card_holder.set_draggable(true)
	# hide cardscroller
	nodes.split_container.set_expanded(true)
	
	# Erase old cards from the card slots
	clean_card_slots()
	nodes.white_card_holder.get_cards()
	
	# Cria a carta preta
	black_card = CAH.CARD_SCENE.instantiate()
	black_card.text = state.black_cards[0]
	black_card.card_type = Card.BLACK_CARD
	nodes.left_card_slot.add_child(black_card)
	black_card.set_clickable(false)
	black_card.dragger.set_child_modulate(Color.TRANSPARENT)
	black_card.dragger.tween_child_modulate(Color.WHITE)
	
	# Cria o grupo de cartas brancas quando o card holder ficar transparente
	wch_tweener.finished.connect(func():
		for card in nodes.white_card_holder.get_cards():
			nodes.white_card_holder.remove_card(card)
		for card_text in state.choice_groups[0]:
			var new_card = CAH.CARD_SCENE.instantiate()
			new_card.text = card_text
			nodes.white_card_holder.add_child(new_card)
			nodes.white_card_holder.add_card(new_card)
	)
	
	# Winner animation
	nodes.top_label.animate_text("O vencedor é...")
	# Mostra a cartinha vazia (antecipação uau wow cinema)
	var timer1 = get_tree().create_timer(1.0)
	timer1.timeout.connect(func():
		nodes.right_card_slot.toggle_glow(true, 1.5)
	)
	
	# Anuncia o vencedor
	var timer2 = get_tree().create_timer(3)
	timer2.timeout.connect(func():
		nodes.top_label.animate_text("O vencedor é... " + state.winner_name + "!")
		nodes.top_label._erasing = false
		nodes.confetti.emitting = true
		nodes.right_card_slot.toggle_glow(false)
		nodes.white_card_holder.dragger.tween_child_modulate(Color.WHITE)
		
		# Espera um porquin pra mostrar o botão de continuar
		var timer3 = get_tree().create_timer(0.5)
		timer3.timeout.connect(func():
			nodes.button_controller.toggle_button(true)
			nodes.bottom_button.text = "Continuar"
			nodes.bottom_button.toggle_mode = false
			nodes.bottom_button.button_pressed = false
			nodes.bottom_button.pressed.connect(_on_bottom_button_pressed)
		)
	)
	

func _on_bottom_button_pressed() -> void:
	nodes.top_label.animate_text("Aguarde os outros jogadores...")
	nodes.button_controller.toggle_button(false)
