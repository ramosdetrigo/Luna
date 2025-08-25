class_name ChooseWhiteState
extends CAHStateHandler

var grabbed_card: Card

func _ready() -> void:
	nodes.button_controller.toggle_button(false)
	nodes.white_card_holder.set_clickable(false)
	nodes.white_card_holder.set_draggable(false)
	if state.player_role == CAHState.ROLE_PLAYER:
		nodes.right_card_slot.toggle_glow(true)
		if state.white_choices == 1:
			nodes.top_label.animate_text("Selecione sua carta.")
		else:
			nodes.top_label.animate_text("Selecione suas cartas.")
	else:
		nodes.top_label.animate_text("Aguarde os jogadores.")
		nodes.right_card_slot.toggle_glow(false)
	
	# show card scroller
	nodes.split_container.set_expanded(false)
	
	# (if the previous screen was choose_black)
	# Cleans slots and drags the selected card to the correct container
	if state.previous_game_state == CAHState.STATE_CHOOSE_BLACK:
		clean_center_slot()
		# Assumes the selected card is the left one then checks
		var selected_black_card: Card = nodes.left_card_slot.get_cards()[0]
		var right_black_card: Card = nodes.right_card_slot.get_cards()[0]
		if right_black_card.text == state.black_cards[0]:
			selected_black_card = right_black_card
			clean_left_slot()
		else:
			clean_right_slot()
		
		# Move a carta pro local certo (pro centro se não for jogador)
		var old_pos = right_black_card.dragger.global_position
		if state.player_role != CAHState.ROLE_PLAYER:
			selected_black_card.reparent(nodes.center_card_slot)
			clean_left_slot()
			clean_right_slot()
		else:
			selected_black_card.reparent(nodes.left_card_slot)
		tween_card_to_new(right_black_card, old_pos)
	else: # The player just entered the game or whatever
		clean_card_slots()
		var black_card = CAH.CARD_SCENE.instantiate()
		black_card.card_type = Card.BLACK_CARD
		black_card.text = state.black_cards[0]
		black_card.set_clickable(false)
		# Move pro centro se não for jogador
		if state.player_role != CAHState.ROLE_PLAYER:
			nodes.center_card_slot.add_child(black_card)
		else:
			nodes.left_card_slot.add_child(black_card)
	
	# Adds new cards to the card scroller
	var new_card_text = state.new_white_cards.pop_front()
	while new_card_text != null:
		var new_card: Card = CAH.CARD_SCENE.instantiate()
		new_card.text = new_card_text
		nodes.card_scroller.add_card(new_card)
		new_card.mouse_entered.connect(_on_card_mouse_entered.bind(new_card))
		new_card.grabbed.connect(_on_card_grabbed.bind(new_card))
		new_card.dropped.connect(_on_card_dropped.bind(new_card))
		new_card.clicked.connect(_on_card_clicked.bind(new_card))
		new_card_text = state.new_white_cards.pop_front()
	
	if state.player_role == CAHState.ROLE_PLAYER:
		nodes.white_card_holder.mouse_entered.connect(_on_card_holder_mouse_entered)
		nodes.bottom_button.toggled.connect(_on_bottom_button_toggled)


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
		var slot = floor(nodes.card_scroller.get_scroll_percentage() * nodes.card_scroller.get_card_count()) + 1
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
		if nodes.white_card_holder.get_card_count() < state.white_choices:
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
	else:
		if state.white_choices == 1:
			nodes.top_label.animate_text("Selecione sua carta.")
		else:
			nodes.top_label.animate_text("Selecione suas cartas.")
		nodes.white_card_holder.set_draggable(false)


#region OVERRIDES
func add_card_to_holder(card: Card, index: int = -1, skip_anim: bool = false, tween: bool = true) -> void:
	super(card, index, skip_anim, tween)
	var card_count = nodes.white_card_holder.get_card_count()
	if card_count == 1:
		nodes.right_card_slot.toggle_glow(false)
	if card_count == state.white_choices:
		nodes.button_controller.toggle_button(true)


func add_card_to_scroller(card: Card, index: int = -1, skip_anim: bool = false, tween: bool = true) -> void:
	super(card, index, skip_anim, tween)
	var card_count = nodes.white_card_holder.get_card_count()
	if card_count == 0:
		nodes.right_card_slot.toggle_glow(true)
	if card_count < state.white_choices:
		nodes.button_controller.toggle_button(false)
		nodes.bottom_button.set_pressed(false)
		nodes.bottom_button._pressed()
		nodes.bottom_button.button_pressed = false
#endregion
