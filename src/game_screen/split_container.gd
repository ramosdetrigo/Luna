extends VSplitContainer

var _offset_tween: Tween

func tween_offset(target: float, time: float = 0.5) -> void:
	if _offset_tween:
		_offset_tween.kill()
	_offset_tween = create_tween()
	_offset_tween.set_ease(Tween.EASE_OUT)
	_offset_tween.set_trans(Tween.TRANS_QUINT)
	_offset_tween.tween_property(self, "split_offset", target, time)
