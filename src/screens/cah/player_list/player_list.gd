extends Control

# Player: id, name, role, ready, win count, vote count, vote target
var player_list: Dictionary[int, PlayerEntry] = {}
const PLAYER_ENTRY: PackedScene = preload("res://src/screens/cah/player_list/player_entry.tscn")


func add_player(player_data: Dictionary) -> void:
	var new_player = PLAYER_ENTRY.instantiate()
	player_list.set(player_data.id, new_player)
	%PlayerList.add_child(new_player)


func remove_player(player_id: int) -> void:
	var player = player_list.get(player_id)
	if player:
		player_list.erase(player_id)
		%PlayerList.remove_child(player)
