class_name Server
extends Node

class Player:
	# The players peer_id
	var id = 0
	# The players role
	var role: CAHState.PlayerRole = CAHState.ROLE_CONNECTING
	# The player's username
	var username: String = ""
	# Black card chosen
	var choice_black: String = ""
	# White cards sent or judge choice
	var choice_white: Dictionary

# All cards from the cards.json file
# whiteCards: [string]
# blackCards: [{text: string, pick: number}]
var CARDS: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards.json"))
var white_cards_pile: Array = []
var black_cards_pile: Array = []

var player_list: Dictionary[int, Player] = {}
var role_judges: Dictionary[int, Player] = {}
var role_players: Dictionary[int, Player] = {}
var role_spectators: Dictionary[int, Player] = {}
var judge_queue = []

var game_state: CAHState = CAHState.new()

func _ready() -> void:
	# We work by shuffling the arrays and taking cards from the top.
	# When we reach a threshold, we shuffle everything again
	white_cards_pile = CARDS.whiteCards.duplicate()
	black_cards_pile = CARDS.blackCards.duplicate()
	white_cards_pile.shuffle()
	black_cards_pile.shuffle()
	
	var interface = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(interface, get_path())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	#
	#print(random_black())
	#print(random_white())


#region HELPER
func create_server() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(Global.PORT)
	if error:
		print(error)
	multiplayer.multiplayer_peer = peer
	print("Server created!")

# returns the dictionary associated with a specific role
func get_role_dict(role: CAHState.PlayerRole) -> Dictionary[int, Player]:
	match role:
		CAHState.ROLE_JUDGE:
			return role_judges
		CAHState.ROLE_PLAYER:
			return role_players
		CAHState.ROLE_SPECTATOR:
			return role_spectators
	# unreachable unless role_connecting (it shouldn't happen.)
	return player_list

# changes the player role adding & removing it from the player dicts
func change_role(player: Player, new_role: CAHState.PlayerRole) -> void:
	match player.role:
		CAHState.ROLE_JUDGE:
			role_judges.erase(player.id)
		CAHState.ROLE_PLAYER:
			role_players.erase(player.id)
		CAHState.ROLE_SPECTATOR:
			role_spectators.erase(player.id)
	
	match new_role:
		CAHState.ROLE_JUDGE:
			role_judges.set(player.id, player)
		CAHState.ROLE_PLAYER:
			role_players.set(player.id, player)
		CAHState.ROLE_SPECTATOR:
			role_spectators.set(player.id, player)
	player.role = new_role

# gets a random black card from the pile
func random_black() -> Dictionary:
	# re-shuffles the used cards if necessary.
	if len(black_cards_pile) == 0:
		black_cards_pile = CARDS.black_cards.duplicate()
		black_cards_pile.shuffle()
	return black_cards_pile.pop_back()

# gets a random white card from the pile
func random_white() -> String:
	# re-shuffles the used cards if necessary.
	if len(white_cards_pile) == 0:
		white_cards_pile = CARDS.white_cards.duplicate()
		white_cards_pile.shuffle()
	return white_cards_pile.pop_back()
#endregion HELPER


#region STATE
func set_game_state(state: CAHState.GameState) -> void:
	var previous_game_state = game_state.current_game_state
	game_state.previous_game_state = previous_game_state
	game_state.current_game_state = state
	
	match state:
		CAHState.STATE_CHOOSE_BLACK:
			game_state.choice_groups = []
			game_state.black_cards = [random_black(), random_black()]
			# Changes everyone back into a player and chooses a new judge
			for judge: Player in role_judges.values():
				change_role(judge, CAHState.ROLE_PLAYER)
			# Takes the next from the queue and puts it back at the end
			var new_judge = judge_queue.pop_front()
			judge_queue.push_back(new_judge)
			change_role(new_judge, CAHState.ROLE_JUDGE)
		CAHState.STATE_CHOOSE_WHITE:
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]
			game_state.choice_groups = []
		CAHState.STATE_JUDGEMENT:
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]
			game_state.choice_groups = []
			for player: Player in role_players.values():
				game_state.choice_groups.append(player.choice_white)
		CAHState.STATE_WINNER:
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]
			game_state.choice_groups = [game_state.choice_groups[0]]

func dict_from_state(player_role: CAHState.PlayerRole) -> Dictionary:
	return {
		"player_role": player_role,
		"current_game_state": game_state.current_game_state,
		"black_cards": game_state.black_cards,
		"choice_groups": CAHState.new_choice_group(["1"], "p"),
	}
#endregion STATE


#region SERVER RPC
# This function both handles new connections and name changes
# (new connections require the name to be set up, etc.)
@rpc("any_peer", "call_remote", "reliable")
func name_changed(new_name: String) -> void:
	var id = multiplayer.get_remote_sender_id()
	# If player is already in player list, just change its name
	print(id)
	if id in player_list.keys():
		player_list[id].name = new_name
		# TODO: update player list
		return
	# Else, the player just joined. Create a new player!
	
	var player = Player.new()
	player.id = id
	player.username = new_name
	change_role(player, CAHState.ROLE_PLAYER)
	judge_queue.push_back(player)
	if len(role_judges) == 0:
		set_game_state(CAHState.STATE_CHOOSE_BLACK)
	player_list.set(id, player)
	var new_cards = []
	for i in range(10):
		new_cards.push_back(random_white())
	add_cards.rpc_id(id, new_cards)
	update_state.rpc_id(id, dict_from_state(player.role))


@rpc("any_peer", "call_remote", "reliable")
func message_sent(message: String) -> void:
	add_message.rpc(message)


@rpc("any_peer", "call_remote", "reliable")
func choose_black(black_card: Dictionary) -> void:
	# TODO: modo democrático
	game_state.black_cards[0] = black_card
	set_game_state(CAHState.STATE_CHOOSE_WHITE)
	for player: Player in player_list.values():
		update_state.rpc_id(player.id, dict_from_state(player.role))
#endregion SERVER RPC


#region CLIENT RPC
@rpc("authority", "call_remote", "reliable")
func add_cards(_new_cards: Array) -> void: pass

@rpc("authority", "call_remote", "reliable")
func add_message(_message: String) -> void: pass

@rpc("authority", "call_remote", "reliable")
func update_state(_new_state: Dictionary) -> void: pass

@rpc("authority", "call_remote", "reliable")
func update_player_list(_new_players: Array[Dictionary]) -> void: pass
#endregion CLIENT RPC


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
