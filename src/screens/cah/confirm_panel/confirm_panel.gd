extends Screen

signal ok_pressed
signal cancel_pressed

func set_text(text: String) -> void:
	%Text.text = text


func _on_sim_pressed() -> void:
	ok_pressed.emit()


func _on_não_pressed() -> void:
	cancel_pressed.emit()


func _on_resized() -> void:
	%"Não".pivot_offset = %"Não".size / 2.0
	%Sim.pivot_offset = %Sim.size / 2.0
	
	var new_scale = size / Vector2(1280, 720)
	new_scale = Vector2(new_scale.y, new_scale.y)
	var viewport_size = get_viewport_rect().size
	if new_scale.y * 480.0 > viewport_size.x * 0.66:
		new_scale = Vector2(viewport_size.x / 480.0, viewport_size.x / 480.0) * 0.66
	$VBoxContainer.scale = new_scale
