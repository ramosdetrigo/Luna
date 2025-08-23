extends Control


func _ready() -> void:
	if %Box.vertical:
		%Box.size.y = get_card_size().y*3
	for i in range(3):
		var new_card = Global.PACKED_SCENES.card.instantiate()
		var t = ""
		for _j in range(i):
			t += "\n"
		new_card.set_text("Carta" + t + str(i+1))
		
		add_card(new_card)


func add_card(card: Card) -> void:
	var container = new_card_container()
	
	container.add_child(card)
	card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	card.set_position(Vector2(0,0))
	card.size = get_card_size()
	
	%Box.add_child(container)
	await card.container_resized
	if %Box.vertical:
		container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		container.custom_minimum_size.y = card.get_text_height() * card.scale.x


func get_card_size() -> Vector2:
	if %Box.vertical:
		return Vector2(size.x, size.x / 0.6576)
	else:
		return Vector2(size.y * 0.6576, size.y)


func new_card_container() -> Control:
	var container = Control.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return container


func move_card(card: Card, target_index: int) -> void:
	var card_container = %Box.get_child(find_card(card))
	%Box.move_child(card_container, target_index)

# Finds card in the container box
func find_card(card: Card) -> int:
	var card_list = %Box.get_children()
	for i in range(len(card_list)):
		if get_container_card(card_list[i]) == card:
			return i
	return -1


static func get_container_card(container: Control) -> Card:
	return container.get_child(0)

# TODO: is this needed?
func _on_resized() -> void:
	pass # Replace with function body.
