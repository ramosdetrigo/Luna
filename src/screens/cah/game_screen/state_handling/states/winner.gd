class_name WinnerState
extends CAHStateHandler

var timers: Array[SceneTreeTimer] = []
var black_card: Card
var grabbed_group: CardGroup

func _ready() -> void:
	nodes.button_controller.toggle_button(false)
	nodes.right_card_slot.toggle_glow(false)
	var wch_tweener = nodes.white_card_holder.dragger.tween_child_modulate(Color.TRANSPARENT)
	nodes.white_card_holder.set_clickable(false)
	nodes.white_card_holder.set_draggable(true)
	# hide cardscroller
	var ss_tween = nodes.split_container.set_expanded(true)
	nodes.split_container.dragging_enabled = false
	nodes.scroller_split.update_offset(true)
	ss_tween.finished.connect(func():
		# Clear card scroller
		for card in nodes.judge_scroller.get_card_list():
			if card is CardGroup:
				nodes.judge_scroller.remove_card(card)
		#Adds new card groups to the card scroller
		var first = true
		for group in state.choice_groups:
			if first:
				first = false
				continue
			var card_group = create_card_group(group)
			nodes.judge_scroller.add_card(card_group)
			card_group.dragger.set_child_modulate(Color.TRANSPARENT)
			card_group.dragger.grabbed.connect(func(): grabbed_group = card_group)
			card_group.dragger.dropped.connect(func(): grabbed_group = null)
			card_group.mouse_entered.connect(func():
				if card_group != grabbed_group:
					swap_cards(grabbed_group, card_group))
	)
	
	# Erase old cards from the card slots
	clean_card_slots()
	
	# TODO: não criar a carta preta se ela já existe
	if state.previous_game_state != CAHState.STATE_CHOOSE_WHITE:
		black_card = CAH.CARD_SCENE.instantiate()
		black_card.text = state.black_cards[0].text
		black_card.card_type = Card.BLACK_CARD
		nodes.left_card_slot.add_child(black_card)
		black_card.set_clickable(false)
		black_card.dragger.set_child_modulate(Color.TRANSPARENT)
		black_card.dragger.tween_child_modulate(Color.WHITE)
	else:
		if state.player_role == CAHState.ROLE_PLAYER:
			black_card = nodes.left_card_slot.get_cards()[0]
		else:
			black_card = nodes.center_card_slot.get_cards()[0]
		black_card.set_clickable(false)
		
		var old_pos = black_card.dragger.global_position
		black_card.reparent(nodes.left_card_slot)
		tween_card_to_new(black_card, old_pos)
	
	# Cria o grupo de cartas brancas quando o card holder ficar transparente
	wch_tweener.finished.connect(func():
		for card in nodes.white_card_holder.get_cards():
			nodes.white_card_holder.remove_card(card)
		for card_text in state.choice_groups[0].cards:
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
	Global.play_audio(Global.SFX[4])
	var timer2 = get_tree().create_timer(3)
	timer2.timeout.connect(func():
		for card_group in nodes.judge_scroller.get_card_list():
			if card_group is not CardGroup: continue
			card_group.dragger.set_child_modulate(Color.WHITE)
		
		var winner_name = state.choice_groups[0].player
		nodes.top_label.animate_text("O vencedor é... " + winner_name + "!")
		nodes.top_label._erasing = false
		nodes.split_container.dragging_enabled = true
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


func _exit_tree() -> void:
	for card in nodes.judge_scroller.get_card_list():
		if card is not CardGroup: continue
		nodes.judge_scroller.remove_card(card)


func _on_bottom_button_pressed() -> void:
	nodes.client.winner_ready.rpc_id(1)
	nodes.top_label.animate_text("Aguarde os outros jogadores...")
	nodes.button_controller.toggle_button(false)
