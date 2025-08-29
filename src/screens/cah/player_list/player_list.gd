extends Screen

# Player: id, name, role, ready, win count, vote count, vote target
signal player_vote_kicked(id: int)
var player_list: Dictionary[int, PlayerEntry] = {}
const PLAYER_ENTRY: PackedScene = preload("res://src/screens/cah/player_list/player_entry.tscn")


func update_player_list(new_player_list: Array[Dictionary]) -> void:
	# Add new players and update old ones
	var id_list: Array[int] = []
	for new_player_data in new_player_list:
		id_list.push_back(new_player_data.id)
		var existing_player = player_list.get(new_player_data.id)
		if existing_player:
			set_player_data(existing_player, new_player_data)
		else:
			add_player(new_player_data)
	# Remove leaving players
	for player_id in player_list.keys():
		if player_id not in id_list:
			remove_player(player_id)


func set_player_data(player: PlayerEntry, player_data: Dictionary) -> void:
	player.set_player_id(player_data.id)
	player.set_player_name(player_data.username)
	player.set_player_role(player_data.role)
	player.set_player_win_count(player_data.win_count)
	player.set_player_kick_count(player_data.kick_vote_count, player_data.kick_vote_target)
	player.set_player_ready(player_data.ready)


func add_player(player_data: Dictionary) -> void:
	var new_player = PLAYER_ENTRY.instantiate()
	player_list.set(player_data.id, new_player)
	%PlayerList.add_child(new_player)
	set_player_data(new_player, player_data)
	new_player.vote_kicked.connect(_on_player_vote_kicked)


func _on_player_vote_kicked(id: int) -> void:
	player_vote_kicked.emit(id)


func remove_player(player_id: int) -> void:
	var player = player_list.get(player_id)
	if player:
		player_list.erase(player_id)
		%PlayerList.remove_child(player)


func _on_resized() -> void:
	var viewport_size = get_viewport_rect().size
	if viewport_size.y > 1080:
		var new_scale = viewport_size.y / 1080
		%ChatTopPanel.custom_minimum_size.y = 80 * new_scale
		%ChatBottomPanel.custom_minimum_size.y = 60 * new_scale + 40
	else:
		%ChatTopPanel.custom_minimum_size.y = 80
		%ChatBottomPanel.custom_minimum_size.y = 100
