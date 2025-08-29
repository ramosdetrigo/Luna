class_name JudgementState
extends CAHStateHandler

var grabbed_group: CardGroup

func _ready() -> void:
	nodes.button_controller.toggle_button(false)
	nodes.white_card_holder.set_clickable(false)
	nodes.white_card_holder.set_draggable(false)
	# switch between the card scroller and the judge scroller
	nodes.scroller_split.tween_offset(true)
	
	if state.player_role == CAHState.ROLE_JUDGE:
		nodes.right_card_slot.toggle_glow(true)
		nodes.top_label.animate_text("Qual a melhor resposta?")
	else:
		if state.vote_mode:
			nodes.top_label.animate_text("Aguarde os juízes.")
		else:
			nodes.top_label.animate_text("Aguarde o juiz.")
		nodes.right_card_slot.toggle_glow(false)
	for card in nodes.white_card_holder.get_cards():
			nodes.white_card_holder.remove_card(card)
	nodes.bottom_button.toggle_mode = true
	nodes.bottom_button.set_pressed_no_signal(false)
	
	# show card scroller
	nodes.split_container.set_expanded(false)
	
	# (if the previous screen was choose_black)
	# Cleans slots and drags the selected card to the correct container
	if state.previous_game_state == CAHState.STATE_CHOOSE_WHITE:
		clean_right_slot()
		# Assumes the black card is the left one then checks
		var black_group = nodes.left_card_slot.get_cards()
		var center_group = nodes.center_card_slot.get_cards()
		if len(center_group) == 1:
			black_group = center_group
		var black_card = black_group[0]
		
		# Move a carta pro local certo (pro centro se for jogador)
		var old_pos = black_card.dragger.global_position
		if state.player_role == CAHState.ROLE_JUDGE:
			black_card.reparent(nodes.left_card_slot)
		else:
			black_card.reparent(nodes.center_card_slot)
		tween_card_to_new(black_card, old_pos)
	else: # The player just entered the game or whatever
		clean_card_slots()
		var black_card = CAH.CARD_SCENE.instantiate()
		black_card.card_type = Card.BLACK_CARD
		black_card.text = state.black_cards[0].text
		black_card.set_clickable(false)
		# Move pro centro se não for juiz
		if state.player_role == CAHState.ROLE_JUDGE:
			nodes.left_card_slot.add_child(black_card)
		else:
			nodes.center_card_slot.add_child(black_card)
	
	# Clears card scroller
	for card in nodes.judge_scroller.get_card_list():
		if card is CardGroup:
			nodes.judge_scroller.remove_card(card, true)
	#Adds new card groups to the card scroller
	for group in state.choice_groups:
		var is_judge = state.player_role == CAHState.ROLE_JUDGE
		var card_group = create_card_group(group, is_judge, true, false, true)
		nodes.judge_scroller.add_card(card_group)
		card_group.mouse_entered.connect(_on_group_mouse_entered.bind(card_group))
		card_group.dragger.grabbed.connect(_on_group_grabbed.bind(card_group))
		card_group.dragger.dropped.connect(_on_group_dropped.bind(card_group))
		if is_judge:
			card_group.dragger.clicked.connect(_on_group_clicked.bind(card_group))
	if state.player_role == CAHState.ROLE_JUDGE:
		nodes.white_card_holder.mouse_entered.connect(_on_group_holder_mouse_entered)
		nodes.bottom_button.toggled.connect(_on_bottom_button_toggled)


func _on_group_grabbed(group: CardGroup) -> void:
	grabbed_group = group

func _on_group_dropped(group: CardGroup) -> void:
	if group == grabbed_group:
		grabbed_group = null


func _on_group_clicked(group: CardGroup) -> void:
	var confirmed: bool = nodes.bottom_button.button_pressed
	if group.flipped:
		flip_card_group(group)
		return
	# move a carta pra dentro do slot
	if get_right_slot_group() == null:
		nodes.right_card_slot.toggle_glow(false)
		var old_pos = group.dragger.global_position
		# animates the card scroller
		nodes.judge_scroller.move_card(group, nodes.judge_scroller.get_card_count())
		# moves card there
		group.set_vertical(true)
		group.custom_minimum_size = nodes.right_card_slot.size
		group.size = nodes.right_card_slot.size
		group.reparent(nodes.right_card_slot)
		group.custom_minimum_size.x = 0
		# hacky tween cause stuff is shit
		var new_pos = nodes.white_card_holder.dragger.global_position
		var offset = old_pos - new_pos
		group.dragger.set_child_position(offset)
		group.dragger.tween_child_position(Vector2(0,0))
		nodes.button_controller.toggle_button(true)
	elif not confirmed:
		# tira a carta do slot e bota no scroller
		if group == get_right_slot_group():
			nodes.right_card_slot.toggle_glow(true)
			var old_pos = group.dragger.global_position
			group.set_vertical(false)
			var slot = round(nodes.judge_scroller.get_scroll_percentage() * nodes.judge_scroller.get_card_count()) + 1
			nodes.judge_scroller.add_card(group, slot, true)
			
			# this is the worst fucking fix of my life. i don't care if it works. holy shit.
			await group.resized
			await group.resized # yes. await twice.
			group.toggle_box_collapsed(false)
			tween_card_to_new(group, old_pos)
			
			nodes.button_controller.toggle_button(false)
		# troca a carta do scroll com a carta do slot
		else:
			# moves scroll card into slot
			var clicked_group = group
			var scroller_index = nodes.judge_scroller.find_card(clicked_group)
			var clicked_old_pos = clicked_group.dragger.global_position
			clicked_group.set_vertical(true)
			clicked_group.custom_minimum_size = nodes.right_card_slot.size
			clicked_group.size = nodes.right_card_slot.size
			clicked_group.reparent(nodes.right_card_slot)
			clicked_group.custom_minimum_size.x = 0
			# hacky tween cause stuff is shit
			var clicked_new_pos = nodes.white_card_holder.dragger.global_position
			var clicked_offset = clicked_old_pos - clicked_new_pos
			clicked_group.dragger.set_child_position(clicked_offset)
			clicked_group.dragger.tween_child_position(Vector2(0,0))
			
			# moves slot card into scroller
			var selected_group = get_right_slot_group()
			var old_pos = selected_group.dragger.global_position
			selected_group.set_vertical(false)
			nodes.judge_scroller.add_card(selected_group, scroller_index, true)
			# this is the worst fucking fix of my life. i don't care if it works. holy shit.
			await selected_group.resized
			await selected_group.resized # yes. await twice.
			selected_group.toggle_box_collapsed(false)
			tween_card_to_new(selected_group, old_pos)
			
			await clicked_group.resized
			selected_group.update_card_sizes()


func _on_group_mouse_entered(group: CardGroup) -> void:
	if grabbed_group == null or group == grabbed_group:
		return
	# não enviar se o botão de confirmar já foi apertado
	var confirmed: bool = nodes.bottom_button.button_pressed
	var selected_group = get_right_slot_group()
	if not confirmed and (selected_group == group or selected_group == grabbed_group):
		# add from holder to scroller
		if selected_group == grabbed_group:
			var target_index = nodes.judge_scroller.find_card(group)
			# i... don't know why +1
			var final_index = nodes.judge_scroller.get_card_count() + 1
			selected_group.set_vertical(false)
			nodes.judge_scroller.add_card(selected_group, final_index, true)
			await selected_group.resized
			nodes.judge_scroller.move_card(selected_group, target_index)
			nodes.button_controller.toggle_button(false)
			nodes.right_card_slot.toggle_glow(true)
		# switch scroller (grabbed_group) with slot (entered card)
		else:
			var scroller_group = grabbed_group
			var scroller_old_pos = scroller_group.dragger.global_position
			var scroller_index = nodes.judge_scroller.find_card(grabbed_group)
			# moves grabbed card to slot
			if scroller_group.flipped:
				flip_card_group(scroller_group)
			scroller_group.set_vertical(true)
			scroller_group.custom_minimum_size = nodes.right_card_slot.size
			scroller_group.size = nodes.right_card_slot.size
			scroller_group.reparent(nodes.right_card_slot)
			scroller_group.custom_minimum_size.x = 0
			# hacky tween cause stuff is shit
			if not scroller_group.dragger._grabbed:
				tween_card_to_new(scroller_group, scroller_old_pos, 1.0)
			
			# moves slot card into scroller
			var old_pos = selected_group.dragger.global_position
			selected_group.set_vertical(false)
			nodes.judge_scroller.add_card(selected_group, scroller_index, true)
			
			# this is the worst fucking fix of my life. i don't care if it works. holy shit.
			await selected_group.resized
			await selected_group.resized # yes. await twice.
			selected_group.toggle_box_collapsed(false)
			tween_card_to_new(selected_group, old_pos)
			
			await scroller_group.resized
			selected_group.update_card_sizes()
	else:
		swap_cards(grabbed_group, group)


func _on_group_holder_mouse_entered() -> void:
	# Prevents a weird bug where grabbed_group becomes null mid-function (?)
	var group = grabbed_group
	if group == null:
		return
	
	if group.flipped:
		flip_card_group(group)
	nodes.right_card_slot.toggle_glow(false)
	group.set_vertical(true)
	group.custom_minimum_size = nodes.right_card_slot.size
	group.size = nodes.right_card_slot.size
	nodes.judge_scroller.move_card(group, nodes.judge_scroller.get_card_count())
	group.reparent(nodes.right_card_slot)
	group.custom_minimum_size.x = 0
	nodes.button_controller.toggle_button(true)


func _on_bottom_button_toggled(toggled: bool) -> void:
	if toggled:
		get_right_slot_group().set_clickable(false)
		nodes.top_label.animate_text("Aguarde os outros.")
		
		var cards: Array[String] = []
		for card in get_right_slot_group().get_cards():
			if card.is_editable():
				cards.push_back(card.get_display_text())
			else:
				cards.push_back(card.text)
		
		var card_group = CAHState.new_choice_group(cards, Global.CONFIGS.username)
		for cg in state.choice_groups:
			if cg.cards == cards:
				card_group = cg
				break
		nodes.client.choose_white.rpc_id(1, card_group)
	else:
		nodes.client.cancel_ready.rpc_id(1)
		get_right_slot_group().set_clickable(true)
		nodes.top_label.animate_text("Qual a melhor resposta?")


# Returns the right slot's card group (other than white_card_holder), if there is any
func get_right_slot_group() -> CardGroup:
	for group in nodes.right_card_slot.get_cards():
		if group != nodes.white_card_holder:
			return group
	# not found
	return null

func flip_card_group(group: CardGroup) -> void:
	group.set_flipped(false)
	var cards: Array[String] = []
	for card in group.get_cards():
		cards.push_back(card.text)
	nodes.client.flip_group.rpc_id(1, cards)
