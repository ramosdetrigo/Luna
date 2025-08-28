extends Screen


func _on_nickname_text_changed(new_text):
	Global.CONFIGS.username = new_text


func _on_ip_text_changed(new_text):
	Global.CONFIGS.ip = new_text


func _on_join_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[3])


func _on_back_pressed():
	#TODO: disable_interactive()
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0])


func _on_resized() -> void:
	var new_scale = size / Vector2(1280, 720)
	new_scale = Vector2(new_scale.y, new_scale.y)
	var viewport_size = get_viewport_rect().size
	if new_scale.y * 350 > viewport_size.x:
		new_scale = Vector2(viewport_size.x / 350, viewport_size.x / 350) * 0.75
	$VBoxContainer.scale = new_scale
