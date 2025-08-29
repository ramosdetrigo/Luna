class_name Server
extends Node

class Player:
	## The player's peer_id
	var id = 0
	## The player's role
	var role: CAHState.PlayerRole = CAHState.ROLE_CONNECTING
	## The player's username
	var username: String = ""
	## Black card chosen
	var choice_black: Dictionary = {}
	## White cards sent or judge choice
	var choice_white: Dictionary = {}
	## If the player is ready or not
	var ready: bool
	## Player chat color (in hex)
	var color: String = "ffffff"
	## ID's of people who vote kicked the player
	var kick_votes: Array[int] = []
	## How many votes are necessary to kick the player.
	## (equals half the player list size when the voting has started)
	var kick_vote_target: int = 0
	## If the player isn't kicked in one minute, reset the kick votes
	var votekick_timer: SceneTreeTimer
	## How many times the player has won
	var win_count: int = 0
	
	func into_dict() -> Dictionary:
		return {
			"id": id,
			"role": role,
			"username": username,
			"win_count": win_count,
			"kick_vote_count": len(kick_votes),
			"kick_vote_target": kick_vote_target,
			"ready": ready
		}


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
var flipped_cards = [] # really stupid fix for players who join during judgement

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


func all_category_players_ready(category: Dictionary[int, Player]) -> bool:
	for player: Player in category.values():
		if not player.ready:
			return false
	return true

func set_all_players_ready(r: bool) -> void:
	for player: Player in player_list.values():
		player.ready = r

func get_highest_voted_whites(ignore_draws: bool = false) -> Array[Dictionary]:
	var counting_dict: Dictionary[String, int] = {}
	var reverse_dict: Dictionary[String, Dictionary] = {}
	for judge: Player in role_judges.values():
		var key = str(judge.choice_white)
		if counting_dict.get(key) == null:
			counting_dict.set(key, 0) # set serialized dict as key
			reverse_dict.set(key, judge.choice_white)
		counting_dict[key] += 1
	
	# TODO: segundo turno
	var max_count = 0
	var max_groups: Array[Dictionary] = []
	var keys = counting_dict.keys()
	keys.shuffle() # helps with random choice if it's a draw
	for key in keys:
		var count = counting_dict[key]
		if count > max_count:
			max_count = count
			max_groups = [reverse_dict[key]]
		elif count == max_count and not ignore_draws:
			max_groups.push_back(reverse_dict[key])
	return max_groups

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
	var keys = counting_dict.keys()
	keys.shuffle() # helps with random choice if it's a draw
	for key in keys:
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
	flipped_cards.clear()
	
	match state:
		CAHState.STATE_CHOOSE_BLACK:
			game_state.choice_groups = []
			game_state.black_cards = [random_black(), random_black()]
			# Changes everyone back into a player and chooses a new judge
			if game_state.vote_mode:
				for player in role_players.values():
					change_role(player, CAHState.ROLE_JUDGE)
					game_state.current_judge = "todos"
			else:
				for judge: Player in role_judges.values():
					change_role(judge, CAHState.ROLE_PLAYER)
				# Takes the next judge from the queue and puts it back at the end
				var new_judge = judge_queue.pop_front()
				judge_queue.push_back(new_judge)
				game_state.current_judge = new_judge.username
				change_role(new_judge, CAHState.ROLE_JUDGE)
		CAHState.STATE_CHOOSE_WHITE:
			if game_state.vote_mode:
				for player in role_judges.values():
					change_role(player, CAHState.ROLE_PLAYER)
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]
			game_state.choice_groups = []
		CAHState.STATE_JUDGEMENT:
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]
			game_state.choice_groups = []
			for player: Player in role_players.values():
				game_state.choice_groups.push_back(player.choice_white)
			game_state.choice_groups.shuffle()
			if game_state.vote_mode:
					for player in role_players.values():
						change_role(player, CAHState.ROLE_JUDGE)
		CAHState.STATE_WINNER:
			if game_state.vote_mode:
				for player in role_players.values():
					change_role(player, CAHState.ROLE_PLAYER)
			# We define the first one as the one that has been selected
			game_state.black_cards = [game_state.black_cards[0]]
			# The selected white group is already defined on the choose_white function

func dict_from_state(player_role: CAHState.PlayerRole) -> Dictionary:
	return {
		"draw": game_state.draw,
		"vote_mode": game_state.vote_mode,
		"edit_all_black": game_state.edit_all_black,
		"edit_all_white": game_state.edit_all_white,
		"current_judge": game_state.current_judge,
		"player_role": player_role,
		"current_game_state": game_state.current_game_state,
		"black_cards": game_state.black_cards,
		"choice_groups": game_state.choice_groups,
	}

func send_state_to_all() -> void:
	var state = dict_from_state(CAHState.ROLE_CONNECTING)
	for player: Player in player_list.values():
		state.player_role = player.role
		update_state.rpc_id(player.id, state)

func send_player_list(to_id: int = -1) -> void:
	var list: Array[Dictionary] = []
	for player: Player in player_list.values():
		list.push_back(player.into_dict())
	if to_id == -1:
		update_player_list.rpc(list)
	else:
		update_player_list.rpc_id(to_id, list)
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
		send_player_list()
		return
	# Else, the player just joined. Create a new player!
	var player = Player.new()
	player.id = id
	player.username = new_name
	# Adds player to queue of next judges
	if len(judge_queue) == 1:
		# Prevents a player from being judge twice in a row
		judge_queue.push_front(player)
	else:
		judge_queue.push_back(player)
	# ignore spectators
	# Adds player to player list
	player_list.set(id, player)
	
	# Sends the info to the player
	if len(role_judges) == 0:
		# Se não for modo voto ou se for e não tiver jogadores, reseta
		if not game_state.vote_mode or len(role_players) == 0:
			change_role(player, CAHState.ROLE_PLAYER)
			set_game_state(CAHState.STATE_CHOOSE_BLACK)
			send_state_to_all()
		# Caso contrário, vira player (modo voto em winner ou choose_white)
		else:
			change_role(player, CAHState.ROLE_PLAYER)
			update_state.rpc_id(id, dict_from_state(player.role))
	# Caso já exista juiz e seja modo votação
	elif (game_state.vote_mode and game_state.current_game_state in
	[CAHState.STATE_CHOOSE_BLACK, CAHState.STATE_JUDGEMENT]):
		change_role(player, CAHState.ROLE_JUDGE)
		update_state.rpc_id(id, dict_from_state(player.role))
	# Caso contrário (modo normal e já tem juiz)
	else:
		change_role(player, CAHState.ROLE_PLAYER)
		update_state.rpc_id(id, dict_from_state(player.role))
	
	# Generates their new cards
	var new_cards = []
	for i in range(10):
		new_cards.push_back(random_white())
	add_cards.rpc_id(id, new_cards)

	if game_state.current_game_state == CAHState.STATE_JUDGEMENT:
		for card_group in flipped_cards:
			judge_flipped_group.rpc_id(player.id, card_group)
	# generates a chat color for the player
	var lgbt: Gradient = CAH.gradients[6]
	var color = lgbt.sample(randf())
	var hex = color.to_html(false)
	player.color = hex
	# Notifies everyone that a player has joined
	notify.rpc("[code][color=#71b7ff]SERVER: %s entrou no jogo.[/color][/code]" % player.username)
	send_player_list()


@rpc("any_peer", "call_remote", "reliable")
func message_sent(message: String) -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player:
		add_message.rpc("[b][color=#%s]%s[/color][/b]: %s" % [player.color, player.username, message])


@rpc("any_peer", "call_remote", "reliable")
func choose_black(black_card: Dictionary) -> void:
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
	send_player_list()


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
			send_player_list()
			player.choice_white = white_group
			if all_category_players_ready(role_players):
				set_all_players_ready(false)
				# The adding of player cards to choice_groups is already handled by set_game_State
				set_game_state(CAHState.STATE_JUDGEMENT)
				send_state_to_all()
			send_player_list()
		CAHState.STATE_JUDGEMENT:
			if player.role != CAHState.ROLE_JUDGE:
				return
			player.ready = true
			player.choice_white = white_group
			if all_category_players_ready(role_judges):
				set_all_players_ready(false)
				# Conta pra ver qual foi o grupo mais escolhido
				# (ignora empates se já teve segundo turno)
				var max_groups = get_highest_voted_whites(game_state.draw)
				if len(max_groups) == 1:
					# Move o mais votado pra frente
					var highest_group = max_groups[0]
					var index = -1
					for i in range(len(game_state.choice_groups)):
						var cg = game_state.choice_groups[i]
						if cg == highest_group:
							index = i
							break
					game_state.choice_groups.remove_at(index)
					game_state.choice_groups.push_front(max_groups)
					# repõe as cartas lol eu esqueci
					for p in role_players.values():
						var new_cards = []
						for i in range(game_state.black_cards[0].pick):
							new_cards.push_back(random_white())
						add_cards.rpc_id(p.id, new_cards)
					game_state.draw = false
				else:
					game_state.choice_groups = max_groups
					game_state.draw = true
				set_game_state(CAHState.STATE_WINNER)
				send_state_to_all()
			send_player_list()
		_: return # Player calling in an invalid state


@rpc("any_peer", "call_remote", "reliable")
func winner_ready() -> void:
	var player = player_list.get(multiplayer.get_remote_sender_id())
	if player and game_state.current_game_state == CAHState.STATE_WINNER:
		player.ready = true
	if all_category_players_ready(role_judges) and all_category_players_ready(role_players):
		if game_state.draw: # empate!
			set_game_state(CAHState.STATE_CHOOSE_WHITE)
		else:
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
	flipped_cards.push_back(card_group)
	
	for p in player_list.values():
		if p == player:
			continue
		judge_flipped_group.rpc_id(p.id, card_group)

@rpc("any_peer", "call_remote", "reliable")
func vote_for_kicking_player(player_id: int) -> void:
	var player: Player = player_list.get(player_id)
	if not player:
		return
	# Checks if player already voted
	var voter_id = multiplayer.get_remote_sender_id()
	if voter_id in player.kick_votes:
		return
	player.kick_votes.push_back(voter_id)
	
	if not player.votekick_timer:
		player.kick_vote_target = max(floor(len(player_list) / 2.0), 1.0)
		notify.rpc("[code][color=#71b7ff]SERVER: Um votekick para %s iniciou: %d/%d[/color][/code]"
		% [player.username, len(player.kick_votes), player.kick_vote_target])
		
		player.votekick_timer = get_tree().create_timer(60.0)
		player.votekick_timer.timeout.connect(func():
			if not player:
				return
			player.votekick_timer = null
			player.kick_votes.clear()
			player.kick_vote_target = 0
			notify.rpc("Votekick encerrado. %s não foi expulso." % player.username)
			send_player_list()
		)
	else:
		notify.rpc("[code][color=#71b7ff]SERVER: Votekick %s: %d/%d[/color][/code]"
		% [player.username, len(player.kick_votes), player.kick_vote_target])
	
	if len(player.kick_votes) >= player.kick_vote_target:
		# tells the player it was kicked
		kicked.rpc_id(player.id)
		# Disconnects the votekick timer
		var f = player.votekick_timer.timeout.get_connections()[0].callable
		player.votekick_timer.timeout.disconnect(f)
		# erases player early
		_on_peer_disconnected(player.id)
		# force kicks the player after 2s.
		get_tree().create_timer(2.0).timeout.connect(func():
			if player.id in multiplayer.get_peers():
				multiplayer.multiplayer_peer.disconnect_peer(player.id)
		)
	send_player_list()


@rpc("any_peer", "call_remote", "reliable")
func toggle_spectator(toggle: bool) -> void:
	var id = multiplayer.get_remote_sender_id()
	var player = player_list.get(id)
	if toggle:
		var old_player_role = player.role
		change_role(player, CAHState.ROLE_SPECTATOR)
		
		# the game will reset itself when someone joins.
		if len(role_judges) + len(role_players) == 0: # (ignore spectators)
			update_state.rpc_id(player.id, dict_from_state(player.role))
		# resets the game if the player was the only remaining judge
		elif (old_player_role == CAHState.ROLE_JUDGE and len(role_judges) == 0
		and game_state.current_game_state != CAHState.STATE_WINNER):
			set_game_state(CAHState.STATE_CHOOSE_BLACK)
			send_state_to_all()
		# just change the role already
		else:
			update_state.rpc_id(player.id, dict_from_state(player.role))
	else:
		change_role(player, CAHState.ROLE_PLAYER)
		if len(role_judges) == 0:
			set_game_state(CAHState.STATE_CHOOSE_BLACK)
			send_state_to_all()
		else:
			update_state.rpc_id(player.id, dict_from_state(player.role))
	send_player_list()
#endregion SERVER RPC


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

@rpc("authority", "call_remote", "reliable")
func kicked() -> void: pass
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
	send_player_list()
#endregion
