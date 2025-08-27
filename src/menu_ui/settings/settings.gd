extends Control


func _on_settings_pressed():
	if $Settings.is_toggled:
		$AnimationPlayer.play("show_icons")
	else:
		$AnimationPlayer.play_backwards("show_icons")
