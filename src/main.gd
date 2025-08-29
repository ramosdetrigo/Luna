extends Control

@onready
var music_player: AudioStreamPlayer = $MusicPlayer
var song_queue: Array[AudioStreamOggVorbis] = []
@onready
var has_virtual_keyboard: bool = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)


func _ready() -> void:
	%Menu.scale_fade(false)
	for song in Global.MUSIC:
		song_queue.push_back(song)
	song_queue.shuffle()
	
	Global.music_volume_changed.connect(func(volume: float):
		music_player.volume_linear = volume)
	
	music_player.volume_linear = Global.CONFIGS.music_volume
	next_song()
	update_children_pivot()


func update_children_pivot() -> void:
	for node: Control in %ScreenHolder.get_children():
		node.pivot_offset = node.size / 2.0


func _on_resized() -> void:
	update_children_pivot()
	%BackgroundParticles.emission_rect_extents = size/2


func _process(_delta: float) -> void:
	if has_virtual_keyboard:
		var mobile_keyboard_height = DisplayServer.virtual_keyboard_get_height()
		if mobile_keyboard_height > 0:
			var text_height = size.y - Global.TEXT_EDIT_Y
			if text_height < mobile_keyboard_height:
				# offset position ye
				position.y = text_height - mobile_keyboard_height
		else:
			position.y = 0


func _on_change_scene(scene: PackedScene) -> void:
	var scene_node: Screen = scene.instantiate()
	scene_node.change_scene.connect(_on_change_scene)
	%ScreenHolder.add_child(scene_node)
	scene_node.scale_fade(false)
	update_children_pivot()


func next_song() -> void:
	var new_song = song_queue.pop_front()
	song_queue.push_back(new_song)
	
	music_player.stream = new_song
	music_player.play()
