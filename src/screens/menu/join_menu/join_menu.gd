extends Screen


var selected_room: RoomEntry
const ROOM_ENTRY_SCENE: PackedScene = preload("res://src/screens/menu/join_menu/room_entry.tscn")
var client: Client


func _ready() -> void:
	%Nickname.text = Global.CONFIGS.username
	refresh_rooms()
	Global.CONFIGS.room_password = ""


func refresh_rooms() -> void:
	# Remove previous rooms from the list
	Global.CONFIGS.ip = Global.REMOTE_SERVER_IP
	for child in %RoomList.get_children():
		%RoomList.remove_child(child)
	# Creates client
	client = Client.new()
	add_child(client)
	client.create_client()
	var refreshing = Label.new()
	refreshing.text = "..."
	refreshing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	%RoomList.add_child(refreshing)
	# If the client connected, ask the server. Else, delete the client.
	client.multiplayer.connected_to_server.connect(func():
		# Requests room list to the server
		client.server_get_rooms.rpc_id(1)
		# Awaits for the rooms to be refreshed
		client.rooms_refreshed.connect(func(rooms: Array[Dictionary]):
			%RoomList.remove_child(refreshing)
			add_rooms(rooms)
			client.queue_free())
		# Deletes the client if no response in 3s
		get_tree().create_timer(3.0).timeout.connect(func():
			if client:
				client.queue_free()))
	# If the connection failed
	client.multiplayer.connection_failed.connect(func():
		%RoomList.remove_child(refreshing)
		client.queue_free())


func add_rooms(rooms: Array[Dictionary]) -> void:
	for room in rooms:
		var new_entry = ROOM_ENTRY_SCENE.instantiate()
		new_entry.has_password = room.has_password
		new_entry.player_count = room.player_count
		new_entry.room_name = room.room_name
		new_entry.clicked.connect(_on_room_entry_clicked.bind(new_entry))
		%RoomList.add_child(new_entry)


func _on_room_entry_clicked(toggled: bool, room_entry: RoomEntry) -> void:
	if toggled:
		if selected_room and selected_room != room_entry:
			selected_room.set_selected(false)
		selected_room = room_entry
		if selected_room.has_password:
			%Password.show()
		else:
			%Password.hide()
		%Join.show()
		Global.CONFIGS.room_name = selected_room.room_name
	else:
		%Password.hide()
		%Join.hide()


func _on_nickname_text_changed(new_text):
	Global.set_username(new_text)


func _on_join_pressed():
	if not %IPCheck.is_toggled:
		Global.CONFIGS.ip = Global.REMOTE_SERVER_IP
	else:
		Global.CONFIGS.ip = %IP.text
	if client:
		client.multiplayer.multiplayer_peer = null
		client.queue_free()
		client = null
	scale_fade(true)
	change_scene.emit(Global.SCREENS[4])


func _on_back_pressed():
	scale_fade(true)
	change_scene.emit(Global.SCREENS[0])


func _on_nickname_focus_entered() -> void:
	Global.TEXT_EDIT_Y = %Nickname.global_position.y + %Nickname.size.y


func _on_create_room_button_pressed() -> void:
	scale_fade(true)
	change_scene.emit(Global.SCREENS[1])


func _on_refresh_button_pressed() -> void:
	refresh_rooms()


func _on_password_text_changed(new_text: String) -> void:
	Global.CONFIGS.room_password = new_text


func _on_password_focus_entered() -> void:
	Global.TEXT_EDIT_Y = %Password.global_position.y + %Password.size.y


func _on_ip_check_pressed() -> void:
	var toggled_on = %IPCheck.button_pressed
	if toggled_on:
		%PanelContainer.hide()
		%IP.show()
		%Password.hide()
		%Join.show()
	else:
		%PanelContainer.show()
		%IP.hide()
		if selected_room:
			%Join.show()
			if selected_room.has_password:
				%Password.show()
			else:
				%Password.hide()
