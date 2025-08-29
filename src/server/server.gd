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
	var choice_black: Dictionary = {}
	# White cards sent or judge choice
	var choice_white: Dictionary = {}
	# if the player is ready or not
	var ready: bool
	# player chat color (in hex)
	var color: String = "ffffff"

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
	
	#print(random_black())
	#print(random_white())


#region HELPER
func create_server() -> Error:
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(Global.CONFIGS.port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	print("Server created!")
	return OK

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

func send_players_to_all() -> void:
	var players_array: Array[Dictionary] = []
	for player: Player in player_list.values():
		players_array.push_back({
			"username": player.username,
			"role": player.role
		})
	update_player_list.rpc(players_array)

func all_category_players_ready(category: Dictionary[int, Player]) -> bool:
	for player: Player in category.values():
		if not player.ready:
			return false
	return true

func set_all_players_ready(r: bool) -> void:
	for player: Player in player_list.values():
		player.ready = r

func get_highest_voted_white() -> Dictionary:
	var counting_dict: Dictionary[String, int] = {}
	var reverse_dict: Dictionary[String, Dictionary] = {}
	for judge: Player in role_judges.values():
		var key = str(judge.choice_white)
		if counting_dict.get(key) == null:
			counting_dict.set(key, 0) # set serialized dict as key
			reverse_dict.set(key, judge.choice_white)
		counting_dict[key] += 1
	
	var max_count = 0
	var max_group = {}
	for key in counting_dict.keys():
		var count = counting_dict[key]
		if count > max_count:
			max_count = count
			max_group = reverse_dict[key]
	return max_group

func get_highest_voted_black() -> Dictionary:
	var counting_dict: Dictionary[String, int] = {}
	var reverse_dict: Dictionary[String, Dictionary] = {}
	for judge: Player in role_judges.values():
		var key = str(judge.choice_black)
		if counting_dict.get(key) == null:
			counting_dict.set(key, 0) # set serialized dict as key
			reverse_dict.set(key, judge.choice_black)
		counting_dict[key] += 1
	
	var max_count = 0
	var max_group = {}
	for key in counting_dict.keys():
		var count = counting_dict[key]
		if count > max_count:
			max_count = count
			max_group = reverse_dict[key]
	return max_group
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
			# Takes the next judge from the queue and puts it back at the end
			var new_judge = judge_queue.pop_front()
			judge_queue.push_back(new_judge)
			game_state.current_judge = new_judge.username
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
				game_state.choice_groups.push_back(player.choice_white)
		CAHState.STATE_WINNER:
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]

func dict_from_state(player_role: CAHState.PlayerRole) -> Dictionary:
	return {
		"current_judge": game_state.current_judge,
		"player_role": player_role,
		"current_game_state": game_state.current_game_state,
		"black_cards": game_state.black_cards,
		"choice_groups": game_state.choice_groups,
	}

func send_state_to_all() -> void:
	for player: Player in player_list.values():
		update_state.rpc_id(player.id, dict_from_state(player.role))
#endregion STATE


#region SERVER RPC
# This function both handles new connections and name changes
# (new connections require the name to be set up, etc.)
@rpc("any_peer", "call_remote", "reliable")
func name_changed(new_name: String) -> void:
	var id = multiplayer.get_remote_sender_id()
	# If player is already in player list, just change its name
	if id in player_list.keys():
		player_list[id].name = new_name
		# TODO: update player list
		return
	# Else, the player just joined. Create a new player!
	var player = Player.new()
	player.id = id
	player.username = new_name
	change_role(player, CAHState.ROLE_PLAYER)
	# Adds player to queue of next judges
	if len(judge_queue) == 1:
		# Prevents a player from being judge twice in a row
		judge_queue.push_front(player)
	else:
		judge_queue.push_back(player)
	# ignore spectators
	if len(role_judges) == 0:
		set_game_state(CAHState.STATE_CHOOSE_BLACK)
	# Adds player to player list
	player_list.set(id, player)
	# Generates their new cards
	var new_cards = []
	for i in range(10):
		new_cards.push_back(random_white())
	# Sends the info to the player
	add_cards.rpc_id(id, new_cards)
	update_state.rpc_id(id, dict_from_state(player.role))
	# generates a chat color for the player
	var lgbt: Gradient = CAH.gradients[6]
	var color = lgbt.colors.get(randi_range(0, lgbt.get_point_count() - 1))
	var hex = color.to_html(false)
	player.color = hex
	# Notifies everyone that a player has joined
	notify.rpc("[code][color=#71b7ff]SERVER: %s entrou no jogo.[/color][/code]" % player.username)
	send_players_to_all()


@rpc("any_peer", "call_remote", "reliable")
func message_sent(message: String) -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player:
		add_message.rpc("[b][color=#%s]%s[/color][/b]: %s" % [player.color, player.username, message])


@rpc("any_peer", "call_remote", "reliable")
func choose_black(black_card: Dictionary) -> void:
	# TODO: modo democrático
	if game_state.current_game_state != CAHState.STATE_CHOOSE_BLACK:
		return
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player == null or player.role != CAHState.ROLE_JUDGE:
		return
	player.ready = true
	player.choice_black = black_card
	# Only continue if all judges are ready
	if all_category_players_ready(role_judges):
		set_all_players_ready(false)
		# Conta pra ver qual foi a carta preta mais escolhida
		var max_black = get_highest_voted_black()
		game_state.black_cards = [max_black]
		set_game_state(CAHState.STATE_CHOOSE_WHITE)
		send_state_to_all()


@rpc("any_peer", "call_remote", "reliable")
func choose_white(white_group: Dictionary) -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player == null:
		return
	# Checks if we're either in choose_white or judgement state
	var curr_state = game_state.current_game_state
	match curr_state:
		CAHState.STATE_CHOOSE_WHITE:
			if player.role != CAHState.ROLE_PLAYER:
				return
			player.ready = true
			player.choice_white = white_group
			if all_category_players_ready(role_players):
				set_all_players_ready(false)
				# The adding of player cards to choice_groups is already handled by set_game_State
				set_game_state(CAHState.STATE_JUDGEMENT)
				send_state_to_all()
		CAHState.STATE_JUDGEMENT:
			if player.role != CAHState.ROLE_JUDGE:
				return
			player.ready = true
			player.choice_white = white_group
			if all_category_players_ready(role_judges):
				set_all_players_ready(false)
				# Conta pra ver qual foi o grupo mais escolhido
				var max_group = get_highest_voted_white()
				# Move o mais votado pra frente
				var index = -1
				for i in range(len(game_state.choice_groups)):
					var cg = game_state.choice_groups[i]
					if cg == max_group:
						index = i
						break
				game_state.choice_groups.remove_at(index)
				game_state.choice_groups.push_front(max_group)
				set_game_state(CAHState.STATE_WINNER)
				# repõe as cartas lol eu esqueci
				for p in role_players.values():
					var new_cards = []
					for i in range(game_state.black_cards[0].pick):
						new_cards.push_back(random_white())
					add_cards.rpc_id(p.id, new_cards)
				send_state_to_all()
		_: return # Player calling in an invalid state


@rpc("any_peer", "call_remote", "reliable")
func winner_ready() -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player and game_state.current_game_state == CAHState.STATE_WINNER:
		player.ready = true
		if all_category_players_ready(role_judges) and all_category_players_ready(role_players):
			set_game_state(CAHState.STATE_CHOOSE_BLACK)
			send_state_to_all()


@rpc("any_peer", "call_remote", "reliable")
func cancel_ready() -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player and game_state.current_game_state != CAHState.STATE_WINNER:
		player.ready = false


@rpc("any_peer", "call_remote", "reliable")
func new_cards_request(card_num: int) -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player:
		var new_cards = []
		for i in range(card_num):
			new_cards.push_back(random_white())
		add_cards.rpc_id(player.id, new_cards)

@rpc("any_peer", "call_remote", "reliable")
func flip_group(card_group: Array[String]) -> void:
	var id = multiplayer.get_remote_sender_id()
	var player = player_list.get(id)
	if not player or player.role != CAHState.ROLE_JUDGE:
		return
	
	for p in player_list.values():
		if p == player:
			continue
		judge_flipped_group.rpc_id(p.id, card_group)
#endregion SERVER RPC

# TODO: toggle_spectator
#region CLIENT RPC
@rpc("authority", "call_remote", "reliable")
func add_cards(_new_cards: Array) -> void: pass

@rpc("authority", "call_remote", "reliable")
func add_message(_message: String) -> void: pass

@rpc("authority", "call_remote", "reliable")
func notify(_message: String) -> void: pass

@rpc("authority", "call_remote", "reliable")
func update_state(_new_state: Dictionary) -> void: pass

@rpc("authority", "call_remote", "reliable")
func update_player_list(_players: Array[Dictionary]) -> void: pass

@rpc("authority", "call_remote", "reliable")
func judge_flipped_group(_card_group: Array[String]) -> void: pass
#endregion CLIENT RPC


#region MULTIPLAYER CALLBACKS
func _on_peer_connected(peer_id: int) -> void:
	print("Server: Peer connected: %d" % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("Server: Peer disconnected: %d" % peer_id)
	var player = player_list.get(peer_id)
	if player == null:
		return
	var old_player_role = player.role
	# removes players from our lists
	change_role(player, CAHState.ROLE_CONNECTING) # erases player from role_lists
	player_list.erase(peer_id)
	judge_queue.erase(player)
	# the game will reset itself when someone joins.
	if len(role_judges) + len(role_players) == 0: # (ignore spectators)
		pass
	# resets the game if the player was the only remaining judge
	elif (old_player_role == CAHState.ROLE_JUDGE and len(role_judges) == 0
	and game_state.current_game_state != CAHState.STATE_WINNER):
		set_game_state(CAHState.STATE_CHOOSE_BLACK)
		send_state_to_all()
	notify.rpc("[code][color=#71b7ff]SERVER: %s saiu do jogo.[/color][/code]" % player.username)
#endregion
