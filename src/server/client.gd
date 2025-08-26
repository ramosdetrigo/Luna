class_name Client
extends Node

@export
var PORT: int = 12112
@export
var IP_ADDR: String = "localhost"

func _ready() -> void:
	var interface = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(interface, get_path())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_client() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_client("ws://%s:%d" % [IP_ADDR, PORT])
	if error:
		print(error)
	multiplayer.multiplayer_peer = peer
	print("Client created!")
