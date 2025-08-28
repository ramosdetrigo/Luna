extends Screen

var target_animation: String = "show_icons"

func _ready() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%Fullscreen.set_toggled(true)
	else:
		%Fullscreen.set_toggled(false)
	
	# Don't show fullscreen icon in android
	if OS.get_name() == "Android":
		target_animation = "show_icons_mobile"
	else:
		target_animation = "show_icons"
	
	# Set sliders to initial config
	%AudioSlider.value = Global.CONFIGS.audio_volume
	%MusicSlider.value = Global.CONFIGS.music_volume


func _on_settings_pressed():
	if %Settings.is_toggled:
		$AnimationPlayer.play(target_animation)
	else:
		$AnimationPlayer.play_backwards(target_animation)


func _on_audio_toggled(toggled: bool) -> void:
	if toggled:
		%AudioSlider.value = 1.0
	else:
		%AudioSlider.value = 0.0


func _on_music_toggled(toggled) -> void:
	if toggled:
		%MusicSlider.value = 1.0
	else:
		%MusicSlider.value = 0.0


func _on_fullscreen_toggled(toggled: bool) -> void:
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#get_tree().create_timer(0.1).timeout.connect(func():
		#$AnimationPlayer.seek(0.25, true, true))


func _on_control_resized() -> void:
	if %Settings.is_toggled:
		$AnimationPlayer.seek(0.25, true, true)
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%Fullscreen.set_toggled(true)
	else:
		%Fullscreen.set_toggled(false)


func _on_music_slider_value_changed(value: float) -> void:
	if value == 0.0:
		%Music.set_toggled(false)
	else:
		%Music.set_toggled(true)
	Global.set_music_volume(value)


func _on_audio_slider_value_changed(value: float) -> void:
	if value == 0.0:
		%Audio.set_toggled(false)
	else:
		%Audio.set_toggled(true)
	Global.set_audio_volume(value)
