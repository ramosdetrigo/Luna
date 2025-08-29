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
