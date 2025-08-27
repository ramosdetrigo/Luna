extends Control

signal music_pressed
signal audio_pressed

func _on_settings_pressed():
	if $Settings.is_toggled:
		$AnimationPlayer.play("show_icons")
	else:
		$AnimationPlayer.play_backwards("show_icons")


func _on_audio_pressed() -> void:
	audio_pressed.emit()


func _on_music_pressed() -> void:
	music_pressed.emit()
