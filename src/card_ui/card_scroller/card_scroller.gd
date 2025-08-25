class_name CardScroller
extends Control


#region METHODS
func get_card_list() -> Array[Node]:
	return %CardList.get_children()


func get_card_list_node() -> HBoxContainer:
	return %CardList


# Gets the correct card size for the container's size
func card_size() -> Vector2:
	var card_size_y = size.y
	var card_size_x = card_size_y * 0.6576
	return Vector2(card_size_x, card_size_y)


# Half-screen-sized edge for allowing scrolling past the last card
func edge_size() -> float:
	var half_size = size.x / 2.0
	var separator_size = %CardList.get_theme_constant("separation")
	var half_card_width = card_size().x / 2.0
	return half_size - half_card_width - separator_size

func new_edge() -> Control:
	var edge = Control.new()
	edge.custom_minimum_size.x = edge_size()
	return edge


func add_card(card: Card, index: int = -1, skip_anim: bool = false) -> void:
	if card.get_parent() == null:
		%CardList.add_child(card)
	else:
		card.reparent(%CardList)
	%CardList.move_child(card, %CardList.get_child_count() - 2)
	if index != -1:
		move_card(card, index, skip_anim)


# Animates the card moving from one index to another
func move_card(card: Card, index: int, skip_anim: bool = false) -> void:
	var card_list = %CardList.get_children()
	var old_index = card_list.find(card)
	# Skips the animations if the card is already at the right index
	if old_index == index:
		return
	
	%CardList.move_child(card, index)
	if skip_anim:
		return
		
	# This should skip the moved card
	var direction = sign(old_index - index)
	for i in range(index, old_index, direction):
		if i == len(card_list) - 3: # don't ask me. the last card is fucked up. and i dont know why.
			continue
		var current_card: Card = card_list[i]
		var next_card: Card = card_list[i+direction]
		
		var old_position = current_card.dragger.global_position
		var new_position = next_card.dragger.global_position
		var offset = old_position - new_position
		
		current_card.dragger.set_child_position(offset)
		current_card.dragger.tween_child_position(Vector2(0,0), 0.2)


# NOTE: is this wrong? 'cause the card fades in place etc
# instead of moving with the scroll
func remove_card(card: Card) -> void:
	var card_list = %CardList.get_children()
	move_card(card, len(card_list)-2)
	%CardList.remove_child(card)


func get_scroll_percentage() -> float:
	return ($ScrollContainer.scroll_horizontal / %CardList.size.x) * 2.0


func find_card(card: Card) -> int:
	return %CardList.get_children().find(card)


func get_card_count() -> int:
	return %CardList.get_child_count() - 2


func generate_placeholder_cards() -> void:
	for i in range(10):
		var new_card = Global.PACKED_SCENES.card.instantiate()
		new_card.custom_minimum_size = card_size()
		new_card.set_text("Carta" + str(i))
		#var t = CAH.custom_cards.keys().get(i)
		#if t:
			#new_card.set_text(t)
		#else:
			#new_card.set_text(CAH.gradient_cards.keys()[i])
			
		%CardList.add_child(new_card)
		%CardList.move_child(new_card, %CardList.get_child_count() - 2)
#endregion


#region CALLBACKS
func _ready():
	%CardList.add_child(new_edge())
	%CardList.add_child(new_edge())
	#generate_placeholder_cards()


func _on_resized() -> void:
	var card_list = %CardList.get_children()
	if len(card_list) == 0:
		return
	
	for element in card_list:
		if element is Card:
			element.custom_minimum_size = card_size()
		else:
			element.custom_minimum_size.x = edge_size()
#endregion


func _on_card_list_child_entered_tree(_node: Node) -> void:
	_on_resized()
