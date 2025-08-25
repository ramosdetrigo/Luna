class_name CAHStateHandler
extends Node

var state: CAHState
var nodes: CAHNodes


func _init(game_state: CAHState, screen_nodes: CAHNodes) -> void:
	state = game_state
	nodes = screen_nodes


func is_card_from_judge(card: Control) -> bool:
	return nodes.judge_scroller.find_card(card) != -1


func is_card_from_scroller(card: Control) -> bool:
	return nodes.card_scroller.find_card(card) != -1


func is_card_from_holder(card: Control) -> bool:
	return nodes.white_card_holder.find_card(card) != -1


func swap_cards(card1: Control, card2: Control) -> void:
	# Both cards are from scroller
	if card1 is CardGroup or card2 is CardGroup:
		if is_card_from_judge(card1) and is_card_from_judge(card2):
			var target_index: int = nodes.judge_scroller.find_card(card2)
			nodes.judge_scroller.move_card(card1, target_index)
	else:
		if is_card_from_scroller(card1) and is_card_from_scroller(card2):
			var target_index: int = nodes.card_scroller.find_card(card2)
			nodes.card_scroller.move_card(card1, target_index)
		# Both cards are from holder
		elif is_card_from_holder(card1) and is_card_from_holder(card2):
			var target_index: int = nodes.white_card_holder.find_card(card2)
			nodes.white_card_holder.move_card(card1, target_index)


func add_card_to_scroller(card: Control, index: int = -1, skip_anim: bool = false, tween: bool = true) -> void:
	var old_pos = card.dragger.global_position
	if is_card_from_holder(card):
		nodes.white_card_holder.remove_card(card)
	var last_index = nodes.card_scroller.get_card_count() + 1
	nodes.card_scroller.add_card(card, last_index, true)
	# i hate these stupid fixes
	var f = func():
		nodes.card_scroller.move_card(card, index, skip_anim)
		if tween and not card.dragger._grabbed:
			# I HATE THIS!!!
			tween_card_to_new.call_deferred(card, old_pos)
	# I HATE THIS!!!
	f.call_deferred()


func add_card_to_holder(card: Control, index: int = -1, skip_anim: bool = false, tween: bool = true) -> void:
	var old_pos = card.dragger.global_position
	if not skip_anim and is_card_from_scroller(card):
		var final_index = nodes.card_scroller.get_card_count() - 1
		nodes.card_scroller.move_card(card, final_index)
	nodes.white_card_holder.add_card(card, index, skip_anim)
	if tween and not card.dragger._grabbed:
		tween_card_to_new(card, old_pos)


func tween_card_to_new(card: Control, old_pos: Vector2) -> void:
	var new_pos = card.dragger.global_position
	var offset = old_pos - new_pos
	card.dragger.set_child_position(offset)
	card.dragger.tween_child_position(Vector2(0,0))


func create_card_group(cards: Array,
clickable: bool = true, draggable: bool = true, vertical: bool = false) -> CardGroup:
	var card_group: CardGroup = CAH.CARD_GROUP_SCENE.instantiate()
	card_group.clickable = clickable
	card_group.draggable = draggable
	card_group.vertical = vertical
	
	# we need to add the card group somewhere to make its child card _ready etc.
	nodes.confetti.add_child(card_group)
	for card_text in cards:
		var new_card = CAH.CARD_SCENE.instantiate()
		new_card.text = card_text
		# we need to add the card somewhere before adding it, 
		# else its child nodes will not exist and add_card will throw a fatal error
		card_group.add_child(new_card)
		card_group.add_card(new_card)
	return card_group


func clean_card_slots() -> void:
	clean_left_slot()
	clean_right_slot()
	clean_center_slot()

func clean_center_slot() -> void:
	var center_cards: Array[Control] = nodes.center_card_slot.get_cards()
	for card in center_cards:
		var tween = card.dragger.tween_child_modulate(Color.TRANSPARENT)
		tween.finished.connect(func(): nodes.center_card_slot.remove_child(card))

func clean_left_slot() -> void:
	var left_cards: Array[Control] = nodes.left_card_slot.get_cards()
	for card in left_cards:
		var tween = card.dragger.tween_child_modulate(Color.TRANSPARENT)
		tween.finished.connect(func(): nodes.left_card_slot.remove_child(card))

func clean_right_slot() -> void:
	var right_cards: Array[Control] = nodes.right_card_slot.get_cards()
	for card in right_cards:
		if card == nodes.white_card_holder:
			continue
		var tween = card.dragger.tween_child_modulate(Color.TRANSPARENT)
		tween.finished.connect(func(): nodes.right_card_slot.remove_child(card))
