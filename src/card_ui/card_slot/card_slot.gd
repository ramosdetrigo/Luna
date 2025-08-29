class_name CardSlot
extends AspectRatioContainer

@export
var glowing: bool = true

@onready
var _edge_modulate_tween: Tween


func _ready() -> void:
	toggle_glow_instant(glowing)


func toggle_glow_instant(enable: bool) -> void:
	glowing = enable
	if _edge_modulate_tween:
		_edge_modulate_tween.kill()
	if enable:
		%CardSlotEdge.modulate = Color.WHITE
	else:
		%CardSlotEdge.modulate = Color.TRANSPARENT


func toggle_glow(enable: bool, time: float = 0.5) -> Tween:
	glowing = enable
	if _edge_modulate_tween:
		_edge_modulate_tween.kill()
	_edge_modulate_tween = %CardSlotEdge.create_tween().set_trans(Tween.TRANS_QUAD)
	_edge_modulate_tween.set_ease(Tween.EASE_IN_OUT)
	if enable:
		%CardSlotEdge.show()
		_edge_modulate_tween.tween_property(%CardSlotEdge, "modulate", Color.WHITE, time)
	else:
		_edge_modulate_tween.tween_property(%CardSlotEdge, "modulate", Color.TRANSPARENT, time)
		_edge_modulate_tween.finished.connect(%CardSlotEdge.hide)
	return _edge_modulate_tween


func get_cards() -> Array[Control]:
	var cards: Array[Control] = []
	for node in get_children():
		if node is Card or node is CardGroup:
			cards.push_back(node)
	return cards





func _on_child_entered_tree(node: Node) -> void:
	node.custom_minimum_size.y = 0


func _on_resized() -> void:
	for card in get_cards():
		card.custom_minimum_size.y = 0
