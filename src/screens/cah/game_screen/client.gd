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
	if not %Chat.visible:
		%NotifyBall.show()
	%Chat.add_message(message)


@rpc("authority", "call_remote", "reliable")
func notify(message: String) -> void:
	add_message(message)


@rpc("authority", "call_remote", "reliable")
func update_state(new_state: Dictionary) -> void:
	game_state.current_judge = new_state.current_judge
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
	# plays sfx if connected or state changed to choose black
	if (game_state.previous_game_state == CAHState.STATE_CONNECTING
	or new_state.current_game_state == CAHState.STATE_CHOOSE_BLACK):
		Global.play_audio(Global.SFX[1])
	state_updated.emit()
	if %ConnectingPanel.visible:
		%ConnectingPanel.toggle_visible(false)


@rpc("authority", "call_remote", "reliable")
func update_player_list(_new_players: Array[Dictionary]) -> void: pass

@rpc("authority", "call_remote", "reliable")
func judge_flipped_group(card_group: Array[String]) -> void:
	for group in %JudgeScroller.get_card_list():
		if group is not CardGroup:
			continue
		var cards: Array[String] = []
		for card in group.get_cards():
			cards.push_back(card.text)
		if cards == card_group:
			group.set_flipped(false)
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

@rpc("any_peer", "call_remote", "reliable")
func flip_group(_card_group: Array[String]) -> void: pass
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
	disconnected.emit("A CONEXÃO FALHOU.")

func _on_server_disconnected() -> void:
	print("Client: Server disconnected")
	disconnected.emit("DESCONECTADO.")
#endregion MULTIPLAYER CALLBACKS


# When the user sends a message via the chat screen
func _on_message_sent(message: String) -> void:
	message_sent.rpc_id(1, message)


func _on_reset_cards_button_pressed() -> void:
	%ConfirmPanel.set_text("Deseja trocar todas as suas cartas?")
	%ConfirmPanel.fade(false, false)
	%ConfirmPanel.ok_pressed.connect(send_card_reset_request, CONNECT_ONE_SHOT)


func send_card_reset_request() -> void:
	%ConfirmPanel.fade(true, false)
	if game_state.current_game_state == CAHState.STATE_CHOOSE_WHITE:
		%BottomButton.set_pressed(false)
		%BBControl.toggle_button(false)
		for card in %WhiteCardHolder.get_cards():
			%WhiteCardHolder.remove_card(card)
	for card in %CardScroller.get_card_list():
		if card is not Card: continue
		%CardScroller.remove_card(card)
	new_cards_request.rpc_id(1, 10)
