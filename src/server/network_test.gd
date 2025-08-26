extends Node2D

@export
var server: Server

func _ready() -> void:
	print("White cards: %d" % len(CAH.cards_dict.whiteCards))
	print("Black cards: %d" % len(CAH.cards_dict.blackCards))
	server.create_server()
