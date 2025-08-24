class_name CardGroup
extends Control
@export
var draggable: bool = true

@export
var vertical: bool = true

@export
var clickable: bool = false

@onready
var dragger: Draggable = %Draggable

var _size_x_tween: Tween

#region CARD MANIPULATION
func add_card(card: Card, index: int = -1) -> void:
	var container = new_card_container()
	
	card.reparent(container)
	card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	card.set_position(Vector2(0,0))
	card.size = get_card_size()
	card.custom_minimum_size = get_card_size()
	container.resized.connect(card._on_image_container_resized)
	
	if draggable:
		card.mouse_filter = MOUSE_FILTER_IGNORE
		card.dragger.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		card.mouse_filter = MOUSE_FILTER_PASS
		card.dragger.mouse_filter = MOUSE_FILTER_PASS
	card.dragger.resized.connect(func():
		if %Box.vertical:
			container.custom_minimum_size.y = card.get_text_height()
	)
	
	%Box.add_child(container)
	
	if index != -1:
		move_card(card, index)


func update_card_sizes() -> void:
	if %Box.vertical:
		%Box.size.y = get_card_size().y*3
	else:
		%Box.size.y = size.y
	
	var container_list = %Box.get_children()
	for container in container_list:
		var card = get_container_card(container)
		card.size = get_card_size()
		card.custom_minimum_size = get_card_size()
		if %Box.vertical:
			container.custom_minimum_size.y = card.get_text_height()


func get_cards() -> Array[Card] :
	var cards: Array[Card]
	for container in %Box.get_children():
		cards.push_back(get_container_card(container))
	return cards


func move_card(card: Card, index: int) -> void:
	var container_list = %Box.get_children()
	var old_index = find_card(card)
	# Skips the animations if the card is already at the right index
	if old_index == index:
		return
	
	var card_container = container_list[old_index]
	%Box.move_child(card_container, index)
	var direction = sign(old_index - index)
	# This should skip the moved card
	for i in range(index, old_index, direction):
		var current_card: Card = get_container_card(container_list[i])
		var next_card: Card = get_container_card(container_list[i+direction])
		
		var old_position = current_card.dragger.global_position
		var new_position = next_card.dragger.global_position
		var offset = (old_position - new_position)
		
		current_card.dragger.set_child_position(offset)
		current_card.dragger.tween_child_position(Vector2(0,0), 0.2)


func remove_card(card: Card) -> void:
	for container in %Box.get_children():
		if get_container_card(container) == card:
			%Box.remove_child(container)


func get_card_count() -> int:
	return len(%Box.get_children())


# Finds card in the container box
func find_card(card: Card) -> int:
	var card_list = %Box.get_children()
	for i in range(len(card_list)):
		if get_container_card(card_list[i]) == card:
			return i
	return -1


func is_vertical() -> bool:
	return %Box.vertical


func set_vertical(toggle: bool) -> void:
	vertical = toggle
	if %Box.vertical == toggle:
		return
	
	var container_list = %Box.get_children()
	# Anota os tamanhos antigos pra refazer a trajetória depois com um tween
	var old_card_positions: Array[Vector2] = []
	var old_card_scales: Array[Vector2] = []
	for i in range(len(container_list)):
		var card: Card = get_container_card(container_list[i])
		old_card_positions.push_back(card.dragger.global_position)
		old_card_scales.push_back(card.get_image_scale())
	
	%Box.vertical = toggle
	update_card_sizes()
	
	for i in range(1,len(container_list)):
		var card: Card = get_container_card(container_list[i])
		var pos_offset = old_card_positions[i] - card.dragger.global_position
		
		card.dragger.set_child_position(pos_offset)
		card.dragger.tween_child_position(Vector2(0,0), 0.5)


func set_draggable(enabled: bool) -> void:
	draggable = enabled
	%Draggable.mouse_filter = MOUSE_FILTER_PASS if draggable else MOUSE_FILTER_IGNORE
	for container in %Box.get_children():
		var card = get_container_card(container)
		if draggable:
			card.dragger.mouse_filter = MOUSE_FILTER_IGNORE
			card.mouse_filter = MOUSE_FILTER_IGNORE
		else:
			card.dragger.mouse_filter = MOUSE_FILTER_PASS
			card.mouse_filter = MOUSE_FILTER_PASS

func set_clickable(enabled: bool) -> void:
	clickable = enabled
	%Draggable.clickable = enabled
#endregion CARD_MANIPULATION


#region HELPERS
func get_card_size() -> Vector2:
	if %Box.vertical:
		return Vector2(size.x, size.x / 0.6576)
	else:
		return Vector2(size.y * 0.6576, size.y)


func new_card_container() -> Control:
	var container = Control.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return container


static func get_container_card(container: Control) -> Card:
	return container.get_child(0)


func generate_dummy_cards() -> void:
	for i in range(3):
		var new_card = Global.PACKED_SCENES.card.instantiate()
		var t = ""
		for _j in range(i):
			t += "\n"
		new_card.set_text("Carta" + t + str(i+1))
		
		add_card(new_card)
#endregion HELPERS


#region CALLBACKS
func _ready() -> void:
	set_clickable(clickable)
	set_draggable(draggable)
	set_vertical(vertical)


# TODO: is this needed?
func _on_resized() -> void:
	update_card_sizes()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.get_keycode_with_modifiers() == KEY_SPACE and event.is_released():
		if not is_vertical():
			size = Vector2(140, 220)
		else:
			size = Vector2(220, 140)
		set_vertical(not is_vertical())
#endregion CALLBACKS


func _on_draggable_grabbed() -> void:
	if not is_vertical() and %Box.get_child_count() > 1:
		if _size_x_tween:
			_size_x_tween.kill()
		_size_x_tween = create_tween()
		_size_x_tween.set_ease(Tween.EASE_OUT)
		_size_x_tween.set_trans(Tween.TRANS_QUAD)
		var target = get_card_size()
		target.x /= %Box.get_child_count()
		target.x *= 1.1
		_size_x_tween.tween_property(%Box, "size", target, 0.25)
	pass # Replace with function body.


func _on_draggable_dropped() -> void:
	if not is_vertical() and %Box.get_child_count() > 1:
		if _size_x_tween:
			_size_x_tween.kill()
		_size_x_tween = create_tween()
		_size_x_tween.set_ease(Tween.EASE_OUT)
		_size_x_tween.set_trans(Tween.TRANS_QUAD)
		var target = get_card_size()
		target.x /= %Box.get_child_count()
		target.x *= 1.1
		_size_x_tween.tween_property(%Box, "size", size, 0.2)
	pass # Replace with function body.


func _process(_delta: float) -> void:
	var card_size = get_card_size()
	for container in %Box.get_children():
		var card = get_container_card(container)
		if card.custom_minimum_size != card_size or card.size != card_size:
			card.custom_minimum_size = card_size
			card.size = card_size
