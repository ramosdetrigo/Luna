extends Node

var SERVER_NODE: Server

var SCREENS : Array[PackedScene] = [
	load("res://src/menu_ui/menu/menu.tscn"),           # 0
	load("res://src/menu_ui/host_menu/host_menu.tscn"), # 1
	load("res://src/menu_ui/join_menu/join_menu.tscn"), # 2
	load("res://src/game_screen/game_screen.tscn")      # 3
]
var CONFIGS : Dictionary = {
	join = true,
	username = "",
	ip = "",
	port = 12112
}
const MUSIC : Array[AudioStreamOggVorbis] = [
	preload("res://assets/audio/music/Clean soul.ogg"), # 0
	preload("res://assets/audio/music/Cool vibes.ogg"), # 1
	preload("res://assets/audio/music/Morfin.ogg"),     # 2
	preload("res://assets/audio/music/Sincerely.ogg"),  # 3
	preload("res://assets/audio/music/slowly.ogg"),     # 4
	preload("res://assets/audio/music/something.ogg"),  # 5
]
