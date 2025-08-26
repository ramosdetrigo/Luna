class_name Server
extends Node

@export
var PORT: int = 12112

var cards: Dictionary

func _ready() -> void:
	var interface = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(interface, get_path())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_server() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		print(error)
	multiplayer.multiplayer_peer = peer
	print("Server created!")





#region MULTIPLAYER CALLBACKS
func _on_peer_connected(peer_id: int) -> void:
	print("Server: Peer connected: %d" % peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Server: Peer disconnected: %d" % peer_id)
	# TODO: add player to disconnected list

func _on_connected_ok() -> void:
	print("Server: Connection ok!")

func _on_connected_fail() -> void:
	print("Server: Connection failed ;(")

func _on_server_disconnected() -> void:
	print("Server: Server disconnected")
#endregion
