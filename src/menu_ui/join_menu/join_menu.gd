extends Screen


func _on_nickname_text_changed(new_text):
	Global.CONFIGS.username = new_text


func _on_ip_text_changed(new_text):
	Global.CONFIGS.ip = new_text


func _on_join_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[3], 1)


func _on_back_pressed():
	#TODO: disable_interactive()
	scale_fade(true)
	emit_signal("change_scene", Global.SCREENS[0], 1)
