extends Screen

func _ready():
	%Nickname.visible = %AskJoin.is_toggled
	%Nickname.text = Global.CONFIGS.username
	if Global.SERVER_NODE:
		%Close.show()
	else:
		%Close.hide()

func _on_back_pressed():
	#TODO: disable_interactive()
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0], 1)



func _on_ask_join_pressed():
	%Nickname.visible = %AskJoin.is_toggled
	Global.CONFIGS.join = %AskJoin.is_toggled


func _on_nickname_text_changed(new_text):
	Global.CONFIGS.username = new_text


func close_server() -> void:
	%Close.hide()
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
	server.create_server()
	
	scale_fade(true)
	if Global.CONFIGS.join:
		change_scene.emit(Global.SCREENS[3], 1)
	else:
		change_scene.emit(Global.SCREENS[0], 1)
