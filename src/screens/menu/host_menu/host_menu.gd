extends Screen


var rules_fade_tween: Tween
var host_fade_tween: Tween


func _ready():
	%Nickname.visible = %AskJoin.is_toggled
	%Nickname.text = Global.CONFIGS.username
	toggle_hosting_visibility()


func toggle_hosting_visibility() -> void:
	if Global.SERVER_NODE and %HostLocal.button_pressed:
		%Close.show()
		%Host.hide()
		%Configs.hide()
	else:
		%Close.hide()
		%Host.show()
		%Configs.show()


func _on_back_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0])



func _on_ask_join_pressed():
	%Nickname.visible = %AskJoin.is_toggled
	Global.CONFIGS.join = %AskJoin.is_toggled


func _on_nickname_text_changed(new_text):
	Global.set_username(new_text)


func close_server() -> void:
	if Global.SERVER_NODE:
		Global.SERVER_NODE.multiplayer.multiplayer_peer.close()
		Global.SERVER_NODE.multiplayer.multiplayer_peer = null
		Global.remove_child(Global.SERVER_NODE)
		Global.SERVER_NODE.queue_free()
		Global.SERVER_NODE = null
	toggle_hosting_visibility()


func _on_host_pressed() -> void:
	if %HostLocal.is_toggled: # Host local
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
			Global.SERVER_NODE.queue_free()
			Global.SERVER_NODE = null
			%ErrorText.text = "Erro criando servidor."
			%Error.show()
			return
		
		toggle_hosting_visibility()
		if Global.CONFIGS.join:
			scale_fade(true)
			change_scene.emit(Global.SCREENS[4])
	else: # Open room
		# O nome não pode ser vazio
		if %RoomName.text.strip_edges() == "":
			%Error.show()
			%ErrorText.text = "Nome inválido."
			return
		Global.CONFIGS.ip = Global.REMOTE_SERVER_IP
		%Host.disabled = true
		%Back.disabled = true
		# Creates client
		var client = Client.new()
		add_child(client)
		client.create_client()
		# If the connection failed delete the client and tell the player
		client.multiplayer.connection_failed.connect(func():
			client.queue_free()
			%Error.show()
			%ErrorText.text = "A conexão falhou."
			%Host.disabled = false
			%Back.disabled = false)
		# If the client connected, ask the server. Else, delete the client.
		client.multiplayer.connected_to_server.connect(func():
			var rules: Dictionary[String, bool] = {
				"vote_mode": %VoteMode.is_toggled,
				"edit_all_black": %EditBlack.is_toggled,
				"edit_all_white": %EditWhite.is_toggled
			}
			client.server_create_room.rpc_id(1, %RoomName.text, %Password.text, rules)
			# Awaits for the room to be created
			client.room_created.connect(func():
				client.queue_free()
				%Host.disabled = false
				%Back.disabled = false
				if Global.CONFIGS.join:
					Global.CONFIGS.ip = Global.REMOTE_SERVER_IP
					Global.CONFIGS.room_name = %RoomName.text
					Global.CONFIGS.room_password = %Password.text
					scale_fade(true)
					change_scene.emit(Global.SCREENS[4]))
			# If the room is invalid tell the player
			client.invalid_room_name.connect(func(reason: String):
				%Error.show()
				%ErrorText.text = reason
				%Host.disabled = false
				%Back.disabled = false
				client.queue_free())
			# Deletes the client if no response in 3s
			get_tree().create_timer(3.0).timeout.connect(func():
				%Host.disabled = false
				%Back.disabled = false
				if client:
					client.queue_free()))


func _on_error_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		%Error.hide()


func _on_nickname_focus_entered() -> void:
	Global.TEXT_EDIT_Y = %Nickname.global_position.y + %Nickname.size.y


func _on_back_rules_pressed() -> void:
	fade_rules(false)

func _on_rules_pressed() -> void:
	fade_rules(true)

func fade_rules(toggle: bool) -> void:
	if rules_fade_tween:
		rules_fade_tween.kill()
	if host_fade_tween:
		host_fade_tween.kill()
	rules_fade_tween = create_tween()
	rules_fade_tween.set_ease(Tween.EASE_OUT)
	rules_fade_tween.set_trans(Tween.TRANS_QUAD)
	host_fade_tween = create_tween()
	host_fade_tween.set_ease(Tween.EASE_OUT)
	host_fade_tween.set_trans(Tween.TRANS_QUAD)
	if toggle:
		%RulesScreen.show()
		rules_fade_tween.tween_property(%RulesScreen, "modulate", Color.WHITE, 0.25)
		host_fade_tween.tween_property(%CreateScreen, "modulate", Color.TRANSPARENT, 0.25)
		host_fade_tween.tween_callback(%CreateScreen.hide)
	else:
		%CreateScreen.show()
		host_fade_tween.tween_property(%CreateScreen, "modulate", Color.WHITE, 0.25)
		rules_fade_tween.tween_property(%RulesScreen, "modulate", Color.TRANSPARENT, 0.25)
		rules_fade_tween.tween_callback(%RulesScreen.hide)


func _on_resized() -> void:
	var new_scale = size / Vector2(1280, 720)
	new_scale = Vector2(new_scale.y, new_scale.y)
	var viewport_size = get_viewport_rect().size
	if new_scale.y * 350 > viewport_size.x * 0.66:
		new_scale = Vector2(viewport_size.x / 350, viewport_size.x / 350) * 0.66
	$RulesScreen.scale = new_scale
	$CreateScreen.scale = new_scale


func _on_host_local_pressed() -> void:
	var toggled_on = %HostLocal.button_pressed
	%RoomName.visible = not toggled_on
	%Password.visible = not toggled_on
	toggle_hosting_visibility()
