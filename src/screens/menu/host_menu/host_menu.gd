extends Screen

func _ready():
	%Nickname.visible = %AskJoin.is_toggled
	%Nickname.text = Global.CONFIGS.username
	if Global.SERVER_NODE:
		%Close.show()
		%Host.hide()
		%EditBlack.hide()
		%EditWhite.hide()
		%VoteMode.hide()
	else:
		%Host.show()
		%EditBlack.show()
		%EditWhite.show()
		%VoteMode.show()
		%Close.hide()

func _on_back_pressed():
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
	%EditBlack.show()
	%EditWhite.show()
	%VoteMode.show()
	if Global.SERVER_NODE:
		Global.SERVER_NODE.multiplayer.multiplayer_peer.close()
		Global.SERVER_NODE.multiplayer.multiplayer_peer = null
		Global.remove_child(Global.SERVER_NODE)
		Global.SERVER_NODE.queue_free()
		Global.SERVER_NODE = null


func _on_host_pressed() -> void:
	close_server()
	
	var server: Server = Server.new()
	server.game_state.edit_all_black = %EditBlack.is_toggled
	server.game_state.edit_all_white = %EditWhite.is_toggled
	server.game_state.vote_mode = %VoteMode.is_toggled
	Global.add_child(server)
	Global.SERVER_NODE = server
	Global.CONFIGS.ip = ""
	
	var error = server.create_server()
	if error:
		%Error.show()
		return
	
	%Close.show()
	%Host.hide()
	%EditBlack.hide()
	%EditWhite.hide()
	%VoteMode.hide()
	if Global.CONFIGS.join:
		scale_fade(true)
		change_scene.emit(Global.SCREENS[4])


func _on_error_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		%Error.hide()


func _on_vote_mode_toggled(_toggled_on: bool) -> void:
	pass
	#%EditBlack.visible = not toggled_on
	#%EditBlack.set_toggled(false)


func _on_nickname_focus_entered() -> void:
	Global.TEXT_EDIT_Y = %Nickname.global_position.y + %Nickname.size.y
