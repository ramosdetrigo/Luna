extends Screen

signal message_sent(message: String)


func add_message(message: String) -> void:
	%ChatText.text += "\n" + message


func _on_chat_text_edit_text_submitted(_new_text: String) -> void:
	_on_chat_send_button_pressed()


func _on_chat_send_button_pressed() -> void:
	var message: String = %ChatTextEdit.text
	if message.lstrip(" ").is_empty(): # don't send message if only spaces
		return
	%ChatTextEdit.clear()
	message_sent.emit(message)


func _on_resized() -> void:
	var viewport_size = get_viewport_rect().size
	if viewport_size.y > 1080:
		var new_scale = viewport_size.y / 1080
		%ChatTopPanel.custom_minimum_size.y = 80 * new_scale
		%ChatBottomPanel.custom_minimum_size.y = 60 * new_scale + 40
		%ChatSendButton.custom_minimum_size = Vector2(60.0, 60.0) * new_scale
		var edit_font_size = 28 * new_scale
		%ChatTextEdit.add_theme_font_size_override("font_size", edit_font_size)
	else:
		%ChatTopPanel.custom_minimum_size.y = 80
		%ChatBottomPanel.custom_minimum_size.y = 100
		%ChatSendButton.custom_minimum_size = Vector2(60.0, 60.0)
		%ChatTextEdit.add_theme_font_size_override("font_size", 28)


func _on_chat_text_edit_focus_entered() -> void:
	Global.TEXT_EDIT_Y = %ChatBottomPanel.global_position.y + %ChatBottomPanel.size.y
