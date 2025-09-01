extends Node
class_name Client

signal state_updated
signal room_created
signal invalid_room_name(reason: String)
signal disconnected(reason: String)
signal new_cards_added(card: Array[Card])
signal rooms_refreshed(rooms: Array[Dictionary])
var game_state: CAHState = CAHState.dummy_state()


func _ready() -> void:
	var interface = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(interface, get_path())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _exit_tree() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null


func create_client() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	var ip = Global.CONFIGS.ip
	if Global.CONFIGS.ip.strip_edges() == "":
		ip = "localhost"
	var error = peer.create_client("ws://%s:%d" % [ip, Global.CONFIGS.port])
	if error:
		disconnected.emit(str(error))
	multiplayer.multiplayer_peer = peer
	print(ip)
	print("Client created!")


func join_server() -> void:
	server_join_room.rpc_id(1, Global.CONFIGS.username, Global.CONFIGS.room_name, Global.CONFIGS.room_password)


#region CLIENT RPC
@rpc("authority", "call_remote", "reliable")
func client_add_cards(new_cards: Array) -> void:
	var card_nodes: Array[Card] = []
	for card_text in new_cards:
		var card = CAH.CARD_SCENE.instantiate()
		card.text = card_text
		%CardScroller.add_child(card)
		%CardScroller.add_card(card)
		card_nodes.push_back(card)
		# Modo "edite todas as brancas" etc
		if game_state.edit_all_white:
			card.set_edit_visible(true)
	new_cards_added.emit(card_nodes)


@rpc("authority", "call_remote", "reliable")
func client_add_message(message: String) -> void:
	if not %Chat.visible:
		%NotifyBall.show()
	%Chat.add_message(message)


@rpc("authority", "call_remote", "reliable")
func client_update_state(new_state: Dictionary) -> void:
	game_state.draw = new_state.draw
	game_state.vote_mode = new_state.vote_mode
	game_state.edit_all_black = new_state.edit_all_black
	game_state.edit_all_white = new_state.edit_all_white
	game_state.current_judge = new_state.current_judge
	game_state.previous_game_state = game_state.current_game_state
	game_state.current_game_state = new_state.current_game_state
	
	# if the game state changed to black suddenly, we need to take the cards
	# back from the white holder. really stupid fix but oh well, it's needed ig.
	if (game_state.current_game_state == CAHState.STATE_CHOOSE_BLACK
	and game_state.previous_game_state == CAHState.STATE_CHOOSE_WHITE
	and game_state.player_role == CAHState.ROLE_PLAYER):
		for card in %WhiteCardHolder.get_cards():
			if card.is_editable():
				card.set_edit_visible(true)
			%WhiteCardHolder.remove_card(card)
			%CardScroller.add_card(card)
	
	if (game_state.current_game_state == CAHState.STATE_CHOOSE_WHITE
	and game_state.player_role == CAHState.ROLE_PLAYER
	and new_state.player_role == CAHState.ROLE_SPECTATOR):
		%BottomButton.set_pressed(false)
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
func client_update_player_list(player_list: Array[Dictionary]) -> void:
	%PlayerList.update_player_list(player_list)


@rpc("authority", "call_remote", "reliable")
func client_group_flipped(card_group: Array[String]) -> void:
	for group in %JudgeScroller.get_card_list():
		if group is not CardGroup:
			continue
		var cards: Array[String] = []
		for card in group.get_cards():
			cards.push_back(card.text)
		if cards == card_group:
			group.set_flipped(false)

# the player is kicked anyways. this is just for a pretty message in the disconnect screen lol
@rpc("authority", "call_remote", "reliable")
func client_disconnect(reason: String) -> void:
	disconnected.emit(reason)


@rpc("authority", "call_remote", "reliable")
func client_get_rooms(rooms: Array[Dictionary]) -> void:
	rooms_refreshed.emit(rooms)


@rpc("authority", "call_remote", "reliable")
func client_invalid_room_name(reason: String) -> void:
	invalid_room_name.emit(reason)


@rpc("authority", "call_remote", "reliable")
func client_room_created() -> void:
	room_created.emit()

@rpc("authority", "call_remote", "reliable")
func client_ping() -> void:
	server_pong.rpc_id(1)
#endregion CLIENT RPC


#region SERVER RPC
@rpc("any_peer", "call_remote", "reliable")
func server_join_room(_username: String, _room_name: String, _password: String) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_message_sent(_message: String) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_player_chose_black(_black_card: Dictionary) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_player_chose_white(_white_group: Dictionary) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
# Only used on winner screen
func server_player_ready() -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_cancel_ready() -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_cards_request(_card_num: int) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_group_flipped(_card_group: Array[String]) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_kick_vote(_target_id: int) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_toggle_spectator(_toggle: bool) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_get_rooms() -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_create_room(_room_name: String, _password: String, _rules: Dictionary[String, bool]) -> void: pass

@rpc("any_peer", "call_remote", "reliable")
func server_pong() -> void: pass
#endregion SERVER RPC


#region MULTIPLAYER CALLBACKS
func _on_peer_connected(peer_id: int) -> void:
	print("Client: Peer connected: %d" % peer_id)

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
	server_message_sent.rpc_id(1, message)


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
	server_cards_request.rpc_id(1, 10)


func _on_player_list_player_vote_kicked(id: int) -> void:
	server_kick_vote.rpc_id(1, id)


func _on_spectate_button_pressed() -> void:
	if %SpectateButton.is_toggled:
		%ConfirmPanel.set_text("Deseja sair do modo espectador?")
	else:
		%ConfirmPanel.set_text("Deseja entrar no modo espectador?")
	
	%ConfirmPanel.fade(false, false)
	%ConfirmPanel.ok_pressed.connect(func():
		%SpectateButton.set_toggled(not %SpectateButton.is_toggled)
		server_toggle_spectator.rpc_id(1, %SpectateButton.is_toggled)
		%ConfirmPanel.fade(true, false)
	, CONNECT_ONE_SHOT)
