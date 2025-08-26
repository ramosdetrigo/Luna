extends Node
class_name Client

signal state_updated
signal new_cards_added(card: Array[Card])
var game_state: CAHState = CAHState.dummy_state()

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
	var error = peer.create_client("ws://%s:%d" % [Global.IP_ADDR, Global.PORT])
	if error:
		print(error)
	multiplayer.multiplayer_peer = peer
	print("Client created!")


#region CLIENT RPC
@rpc("authority", "call_remote", "reliable")
func add_cards(new_cards: Array) -> void:
	print(new_cards)
	var card_nodes: Array[Card] = []
	for card_text in new_cards:
		var card = CAH.CARD_SCENE.instantiate()
		card.text = card_text
		%CardScroller.add_child(card)
		%CardScroller.add_card(card)
		card_nodes.push_back(card)
	new_cards_added.emit(card_nodes)

@rpc("authority", "call_remote", "reliable")
func add_message(message: String) -> void: pass

# TODO: fix error where white cards kind of... disappear...
# from the card scroller... when the scene changes...
@rpc("authority", "call_remote", "reliable")
func update_state(new_state: Dictionary) -> void:
	game_state.player_role = new_state.player_role
	game_state.current_game_state = new_state.current_game_state
	game_state.black_cards = new_state.black_cards
	game_state.choice_groups = new_state.choice_groups
	%ConnectingPanel.toggle_visible(false)
	print(new_state)
	state_updated.emit()

@rpc("authority", "call_remote", "reliable")
func update_player_list(new_players: Array[Dictionary]) -> void: pass
#endregion CLIENT RPC


#region SERVER RPC
@rpc("any_peer", "call_remote", "reliable")
func name_changed(_new_name: String) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func message_sent(_message: String) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func choose_black(black_card: Dictionary) -> void: pass
#endregion SERVER RPC


#region MULTIPLAYER CALLBACKS
func _on_peer_connected(peer_id: int) -> void:
	print("Client: Peer connected: %d" % peer_id)
	if peer_id == 1:
		name_changed.rpc_id(1, Global.USERNAME)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Client: Peer disconnected: %d" % peer_id)

func _on_connected_ok() -> void:
	print("Client: Connection ok!")

func _on_connected_fail() -> void:
	print("Client: Connection failed ;(")
	# TODO: handle connection failed

func _on_server_disconnected() -> void:
	print("Client: Server disconnected")
	# TODO: handle disconnect
#endregion MULTIPLAYER CALLBACKS
