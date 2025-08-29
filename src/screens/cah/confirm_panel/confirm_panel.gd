extends Screen

signal ok_pressed
signal cancel_pressed

func set_text(text: String) -> void:
	%Text.text = text


func _on_sim_pressed() -> void:
	ok_pressed.emit()


func _on_não_pressed() -> void:
	cancel_pressed.emit()
