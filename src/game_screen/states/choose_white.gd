class_name ChooseWhiteState
extends CAHStateHandler

var grabbed_card: Card


func _init(game_state: CAHState, screen_nodes: CAHNodes) -> void:
	super(game_state, screen_nodes)
	# TODO: add cards/new cards, check player role, hide stuff, etc.
	# i'm thinking "hide everything then only show what i need and resize&move accordingly etc."
	# resize vsplit only if it was hidden ig
	# i need to think


func _on_card_mouse_entered(card: Card) -> void:
	pass


func _on_card_holder_mouse_entered() -> void:
	var card = grabbed_card # Prevents a weird bug where cards becomes null mid-function?
	pass
