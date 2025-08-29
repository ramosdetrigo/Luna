extends Screen


func _on_nickname_text_changed(new_text):
	Global.CONFIGS.username = new_text


func _on_ip_text_changed(new_text):
	Global.CONFIGS.ip = new_text


func _on_join_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[4])


func _on_back_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0])


func _on_nickname_focus_entered() -> void:
	Global.TEXT_EDIT_Y = %Nickname.global_position.y + %Nickname.size.y
