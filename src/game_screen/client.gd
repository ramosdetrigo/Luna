extends Node
class_name Client

signal state_updated
signal disconnected(reason: String)
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
	var ip = Global.CONFIGS.ip
	if Global.CONFIGS.ip == "":
		ip = "localhost"
	var error = peer.create_client("ws://%s:%d" % [ip, Global.CONFIGS.port])
	if error:
		print(error)
		disconnected.emit(str(error))
	multiplayer.multiplayer_peer = peer
	print("Client created!")


#region CLIENT RPC
@rpc("authority", "call_remote", "reliable")
func add_cards(new_cards: Array) -> void:
	var card_nodes: Array[Card] = []
	for card_text in new_cards:
		var card = CAH.CARD_SCENE.instantiate()
		card.text = card_text
		%CardScroller.add_child(card)
		%CardScroller.add_card(card)
		card_nodes.push_back(card)
	new_cards_added.emit(card_nodes)


@rpc("authority", "call_remote", "reliable")
func add_message(message: String) -> void:
	if not %ChatPanel.visible:
		%NotifyBall.show()
	%ChatText.text += "\n%s" % message


@rpc("authority", "call_remote", "reliable")
func notify(message: String) -> void:
	add_message(message)


@rpc("authority", "call_remote", "reliable")
func update_state(new_state: Dictionary) -> void:
	game_state.previous_game_state = game_state.current_game_state
	game_state.current_game_state = new_state.current_game_state
	
	# if the game state changed to black suddenly, we need to take the cards
	# back from the white holder. really stupid fix but oh well, it's needed ig.
	if (game_state.current_game_state == CAHState.STATE_CHOOSE_BLACK
	and game_state.previous_game_state == CAHState.STATE_CHOOSE_WHITE
	and game_state.player_role == CAHState.ROLE_PLAYER):
		for card in %WhiteCardHolder.get_cards():
			%WhiteCardHolder.remove_card(card)
			%CardScroller.add_card(card)
	
	game_state.player_role = new_state.player_role
	game_state.black_cards = new_state.black_cards
	game_state.choice_groups = new_state.choice_groups
	state_updated.emit()
	if %ConnectingPanel.visible:
		%ConnectingPanel.toggle_visible(false)


@rpc("authority", "call_remote", "reliable")
func update_player_list(_new_players: Array[Dictionary]) -> void: pass
#endregion CLIENT RPC


#region SERVER RPC
@rpc("any_peer", "call_remote", "reliable")
func name_changed(_new_name: String) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func message_sent(_message: String) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func choose_black(_black_card: Dictionary) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func choose_white(_white_group: Dictionary) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func winner_ready() -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func cancel_ready() -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func new_cards_request(_card_num: int) -> void: pass
#endregion SERVER RPC


#region MULTIPLAYER CALLBACKS
func _on_peer_connected(peer_id: int) -> void:
	print("Client: Peer connected: %d" % peer_id)
	if peer_id == 1: # only accept from server
		name_changed.rpc_id(1, Global.CONFIGS.username)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Client: Peer disconnected: %d" % peer_id)

func _on_connected_ok() -> void:
	print("Client: Connection ok!")

func _on_connected_fail() -> void:
	print("Client: Connection failed ;(")
	disconnected.emit("Connection failed.")

func _on_server_disconnected() -> void:
	print("Client: Server disconnected")
	disconnected.emit("Disconnected.")
#endregion MULTIPLAYER CALLBACKS


func _on_chat_send_button_pressed() -> void:
	if len(%ChatTextEdit.text) > 0:
		message_sent.rpc_id(1, %ChatTextEdit.text)
		%ChatTextEdit.clear()


func _on_chat_text_edit_text_submitted(_new_text: String) -> void:
	_on_chat_send_button_pressed()


func _on_reset_cards_button_pressed() -> void:
	for card in %CardScroller.get_card_list():
		if card is not Card: continue
		%CardScroller.remove_card(card)
	new_cards_request.rpc_id(1, 10)
