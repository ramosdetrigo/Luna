class_name ChooseWhiteState
extends CAHStateHandler

var grabbed_card: Card


func _init(game_state: CAHState, screen_nodes: CAHNodes) -> void:
	super(game_state, screen_nodes)


# TODO: what the fuck
# Switches the grabbed card position with the hovered card
func _on_card_mouse_entered(card: Card) -> void:
	if not grabbed_card or card == grabbed_card:
		return
	
	var card_list = nodes.card_scroller.get_card_list()
	var entered_index = card_list.find(card)
	# Moving in the card scroller
	if entered_index != -1:
		# Checks if the grabbed card is in the scroller container. If not, take it from its holder
		if card_list.find(grabbed_card) == -1:
			nodes.white_card_holder.remove_card(grabbed_card)
			if nodes.white_card_holder.get_card_count() == 0:
				nodes.card_slot.toggle_glow(true)
		nodes.card_scroller.move_card(grabbed_card, entered_index)
	# Moving inside the center card holder
	else:
		entered_index = nodes.white_card_holder.find_card(card)
		if nodes.white_card_holder.find_card(grabbed_card) == -1:
			var grabbed_index = nodes.card_scroller.get_card_list().find(grabbed_card)
			nodes.white_card_holder.add_card(grabbed_card)
			# Only do switches if its the card limit
			if nodes.white_card_holder.get_card_count() == state.white_choices + 1: # +1 because we added 1
				nodes.white_card_holder.remove_card(card)
				card.reparent(nodes.card_scroller.get_card_list_node())
				nodes.card_scroller.get_card_list_node().move_child(card, grabbed_index)
				nodes.white_card_holder.move_card(grabbed_card, entered_index)
		else:
			nodes.white_card_holder.move_card(grabbed_card, entered_index)


func _on_card_holder_mouse_entered() -> void:
	var card = grabbed_card # Prevents a weird bug where cards becomes null mid-function?
	if (not card) or nodes.white_card_holder.get_card_count() > 0:
		return
	nodes.card_scroller.move_card(card, len(nodes.card_scroller.get_card_list()) - 2)
	nodes.white_card_holder.add_card(card)
	nodes.card_slot.toggle_glow(false)
