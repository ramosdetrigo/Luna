class_name CAHStateHandler
extends Node

var state: CAHState
var nodes: CAHNodes


func _init(game_state: CAHState, screen_nodes: CAHNodes) -> void:
	state = game_state
	nodes = screen_nodes


func is_card_from_scroller(card: Card) -> bool:
	return nodes.card_scroller.find_card(card) != -1


func is_card_from_holder(card: Card) -> bool:
	return nodes.white_card_holder.find_card(card) != -1


func swap_cards(card1: Card, card2: Card) -> void:
	# Both cards are from scroller
	if is_card_from_scroller(card1) and is_card_from_scroller(card2):
		var target_index: int = nodes.card_scroller.find_card(card2)
		nodes.card_scroller.move_card(card1, target_index)
	# Both cards are from holder
	elif is_card_from_holder(card1) and is_card_from_scroller(card2):
		var target_index: int = nodes.white_card_holder.find_card(card2)
		nodes.white_card_holder.move_card(card1, target_index)
	# They have different owners
	else:
		# Swaps cards so card1 is from scroller an card2 is from holder
		if is_card_from_holder(card1):
			var aux = card1
			card1 = card2
			card2 = aux
		var target_index1: int = nodes.white_card_holder.find_card(card2)
		var target_index2: int = nodes.card_scroller.find_card(card1)
		add_card_to_holder(card1, target_index1)
		add_card_to_scroller(card2, target_index2)


func add_card_to_scroller(card: Card, index: int = -1) -> void:
	var old_pos = card.dragger.global_position
	nodes.card_scroller.add_card(card, index)
	tween_card_to_new(card, old_pos)


func add_card_to_holder(card: Card, index: int = -1) -> void:
	var old_pos = card.dragger.global_position
	nodes.white_card_holder.add_card(card, index)
	tween_card_to_new(card, old_pos)


func tween_card_to_new(card: Card, old_pos: Vector2) -> void:
	var new_pos = card.dragger.global_position
	var offset = old_pos - new_pos
	card.dragger.set_child_position(offset)
	card.dragger.tween_child_position(Vector2(0,0))


func create_card_group(group: Array,
clickable: bool = true, draggable: bool = true, vertical: bool = false) -> CardGroup:
	var card_group: CardGroup = CAH.CARD_GROUP_SCENE.instantiate()
	for card_text in group:
		var new_card: Card = CAH.CARD_SCENE.instantiate()
		new_card.text = card_text
		card_group.add_card(new_card)
	card_group.draggable = draggable
	card_group.clickable = clickable
	card_group.vertical = vertical
	return card_group


func clean_card_slots() -> void:
	var left_cards: Array[Control] = nodes.left_card_slot.get_cards()
	var center_cards: Array[Control] = nodes.center_card_slot.get_cards()
	var right_cards: Array[Control] = nodes.right_card_slot.get_cards()
	for card in left_cards:
		var tween = card.dragger.tween_child_modulate(Color.TRANSPARENT)
		tween.finished.connect(func(): nodes.left_card_slot.remove_child(card))
	for card in center_cards:
		var tween = card.dragger.tween_child_modulate(Color.TRANSPARENT)
		tween.finished.connect(func(): nodes.center_card_slot.remove_child(card))
	for card in right_cards:
		if card == nodes.white_card_holder:
			continue
		var tween = card.dragger.tween_child_modulate(Color.TRANSPARENT)
		tween.finished.connect(func(): nodes.right_card_slot.remove_child(card))
