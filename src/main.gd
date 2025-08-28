extends Control

@onready
var music_player: AudioStreamPlayer = $MusicPlayer
var song_queue: Array[AudioStreamOggVorbis] = []
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
