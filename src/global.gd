extends Node

const SAVE_FILE_NAME: String = "user://configs.json"
var SERVER_NODE: Server

signal audio_volume_changed(new_volume: float)
signal music_volume_changed(new_volume: float)
var save_timer: Timer

var DISCONNECT_REASON: String = "DESCONECTADO"
var SCREENS : Array[PackedScene] = [
	load("res://src/screens/menu/menu.tscn"),                      # 0
	load("res://src/screens/host_menu/host_menu.tscn"),            # 1
	load("res://src/screens/join_menu/join_menu.tscn"),            # 2
	load("res://src/screens/game_screen/game_screen.tscn"),                # 3
	load("res://src/screens/disconnected_menu/disconnected.tscn"), # 4
]
var CONFIGS : Dictionary = {
	join = true,
	username = "",
	ip = "",
	port = 12112,
	audio_volume = 1.0,
	music_volume = 1.0
}
const MUSIC : Array[AudioStreamOggVorbis] = [
	preload("res://assets/audio/music/Clean soul.ogg"), # 0
	preload("res://assets/audio/music/Cool vibes.ogg"), # 1
	preload("res://assets/audio/music/Morfin.ogg"),     # 2
	preload("res://assets/audio/music/Sincerely.ogg"),  # 3
	preload("res://assets/audio/music/slowly.ogg"),     # 4
	preload("res://assets/audio/music/something.ogg"),  # 5
]
const SFX : Array[AudioStreamOggVorbis] = [
	preload("res://assets/audio/sfx/click.ogg"),   # 0 click
	preload("res://assets/audio/sfx/alert.ogg"),   # 1 server entered
	preload("res://assets/audio/sfx/error.ogg"),   # 2 disconnected
	preload("res://assets/audio/sfx/exit.ogg"),    # 3 exit server
	preload("res://assets/audio/sfx/victory.ogg"), # 4 victory
]


func play_audio(audio: AudioStreamOggVorbis) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = audio
	player.volume_linear = CONFIGS.audio_volume
	player.play()
	var f = func(volume: float):
		player.volume_linear = volume
	audio_volume_changed.connect(f)
	player.finished.connect(func():
		audio_volume_changed.disconnect(f)
		player.queue_free())


func save_configs() -> void:
	var save_file = FileAccess.open(SAVE_FILE_NAME, FileAccess.WRITE)
	var save_data = {
		"username" = CONFIGS.username,
		"audio_volume" = CONFIGS.audio_volume,
		"music_volume" = CONFIGS.music_volume,
	}
	var save_json_string = JSON.stringify(save_data)
	save_file.store_line(save_json_string)


func set_username(new_username: String):
	CONFIGS.username = new_username


func set_audio_volume(volume: float):
	CONFIGS.audio_volume = volume
	audio_volume_changed.emit(volume)
	save_timer.start()


func set_music_volume(volume: float):
	CONFIGS.music_volume = volume
	music_volume_changed.emit(volume)
	save_timer.start()


func _ready() -> void:
	save_timer = Timer.new()
	add_child(save_timer)
	save_timer.timeout.connect(save_configs)
	save_timer.autostart = false
	save_timer.one_shot = true
	save_timer.wait_time = 1.0
	
	load_save()
	save_timer.start() # Only save using save_timer and its timeout


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_FILE_NAME):
		return
	
	# safely sets username, audio volume and music volume from save data
	var save_data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE_NAME))
	if save_data:
		var username = save_data.get("username")
		if username and username is String:
			set_username(username)
		var audio_volume = save_data.get("audio_volume")
		if audio_volume and audio_volume is float:
			set_audio_volume(clamp(audio_volume, 0.0, 1.0))
		var music_volume = save_data.get("music_volume")
		if music_volume and music_volume is float:
			set_music_volume(clamp(music_volume, 0.0, 1.0))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_configs()
		get_tree().quit()
