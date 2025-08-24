class_name CAHStateHandler
extends Object
signal finished

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
	pass


func add_card_to_holder(card: Card, index: int = -1) -> void:
	pass


func add_card_to_scroller(card: Card, index: int = -1) -> void:
	pass
