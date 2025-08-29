extends Screen

func _ready():
	%Nickname.visible = %AskJoin.is_toggled
	%Nickname.text = Global.CONFIGS.username
	if Global.SERVER_NODE:
		%Close.show()
		%Host.hide()
	else:
		%Host.show()
		%Close.hide()

func _on_back_pressed():
	#TODO: disable_interactive()
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0])



func _on_ask_join_pressed():
	%Nickname.visible = %AskJoin.is_toggled
	Global.CONFIGS.join = %AskJoin.is_toggled


func _on_nickname_text_changed(new_text):
	Global.CONFIGS.username = new_text


func close_server() -> void:
	%Close.hide()
	%Host.show()
	if Global.SERVER_NODE:
		Global.SERVER_NODE.multiplayer.multiplayer_peer.close()
		Global.SERVER_NODE.multiplayer.multiplayer_peer = null
		Global.remove_child(Global.SERVER_NODE)
		Global.SERVER_NODE.queue_free()
		Global.SERVER_NODE = null


func _on_host_pressed() -> void:
	close_server()
	
	var server: Server = Server.new()
	Global.add_child(server)
	Global.SERVER_NODE = server
	Global.CONFIGS.ip = ""
	
	var error = server.create_server()
	if error:
		%Error.show()
		return
	
	if Global.CONFIGS.join:
		scale_fade(true)
		change_scene.emit(Global.SCREENS[4])
		%Close.show()
		%Host.hide()


func _on_resized() -> void:
	var new_scale = size / Vector2(1280, 720)
	new_scale = Vector2(new_scale.y, new_scale.y)
	var viewport_size = get_viewport_rect().size
	if new_scale.y * 350 > viewport_size.x:
		new_scale = Vector2(viewport_size.x / 350, viewport_size.x / 350) * 0.75
	$VBoxContainer.scale = new_scale


func _on_error_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		%Error.hide()
