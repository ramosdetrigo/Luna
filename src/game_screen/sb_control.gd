extends Control

var _edge_modulate_tween: Tween

func toggle_button(enable: bool) -> Tween:
	if _edge_modulate_tween:
		_edge_modulate_tween.kill()
	_edge_modulate_tween = %SendButton.create_tween().set_trans(Tween.TRANS_QUAD)
	_edge_modulate_tween.set_ease(Tween.EASE_OUT)
	if enable:
		%SendButton.show()
		_edge_modulate_tween.tween_property(%SendButton, "modulate", Color.WHITE, 0.5)
	else:
		_edge_modulate_tween.tween_property(%SendButton, "modulate", Color.TRANSPARENT, 0.5)
		_edge_modulate_tween.finished.connect(%SendButton.hide)
	return _edge_modulate_tween

func _ready() -> void:
	toggle_button(%SendButton.visible)
