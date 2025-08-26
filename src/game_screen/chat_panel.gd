extends Panel

var _modulate_tween: Tween

func toggle_visible(enable: bool) -> Tween:
	if _modulate_tween:
		_modulate_tween.kill()
	_modulate_tween = create_tween()
	_modulate_tween.set_ease(Tween.EASE_OUT)
	_modulate_tween.set_trans(Tween.TRANS_QUAD)
	if enable and not visible:
		visible = true
		_modulate_tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	# Só fazer o tween se estiver visível
	elif not enable and visible:
		_modulate_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
		_modulate_tween.finished.connect(hide)
	return _modulate_tween
