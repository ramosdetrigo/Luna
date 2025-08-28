extends Control

var _edge_modulate_tween: Tween

func toggle_button(enable: bool) -> Tween:
	if _edge_modulate_tween:
		_edge_modulate_tween.kill()
	_edge_modulate_tween = %BottomButton.create_tween().set_trans(Tween.TRANS_QUAD)
	_edge_modulate_tween.set_ease(Tween.EASE_OUT)
	%BottomButton.disabled = not enable
	if enable:
		%BottomButton.show()
		_edge_modulate_tween.tween_property(%BottomButton, "modulate", Color.WHITE, 0.5)
	else:
		_edge_modulate_tween.tween_property(%BottomButton, "modulate", Color.TRANSPARENT, 0.5)
		_edge_modulate_tween.finished.connect(%BottomButton.hide)
	return _edge_modulate_tween

func _ready() -> void:
	toggle_button(%BottomButton.visible)
