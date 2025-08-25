extends VSplitContainer

var _offset_tween: Tween

var expanded: bool = false
var expanded_offset: int = 250
var normal_offset: int = 55

func tween_offset(target: float, time: float = 0.5) -> void:
	if _offset_tween:
		_offset_tween.kill()
	_offset_tween = create_tween()
	_offset_tween.set_ease(Tween.EASE_OUT)
	_offset_tween.set_trans(Tween.TRANS_QUINT)
	_offset_tween.tween_property(self, "split_offset", target, time)


func set_expanded(toggle: bool) -> Tween:
	expanded = toggle
	if expanded:
		tween_offset(expanded_offset)
	else:
		tween_offset(normal_offset)
	return _offset_tween


func update_offset() -> void:
	if expanded:
		split_offset = expanded_offset
	else:
		split_offset = normal_offset
