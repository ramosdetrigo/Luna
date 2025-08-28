extends VSplitContainer

# if it isnt up its down ig
# up = judge_scroller down = card_scroller
@export
var up: bool = true
var _offset_tween: Tween


func _ready() -> void:
	update_offset(up)


func update_offset(is_up: bool = up) -> void:
	if _offset_tween:
		_offset_tween.kill()
	up = is_up
	var offset = size.y/2
	if up:
		@warning_ignore("narrowing_conversion")
		split_offset = offset
	else:
		@warning_ignore("narrowing_conversion")
		split_offset = -offset


func tween_offset(is_up: bool = up, time: float = 0.5) -> Tween:
	up = is_up
	var target = size.y/2
	if not up:
		target = -target
	
	if _offset_tween:
		_offset_tween.kill()
	_offset_tween = create_tween()
	_offset_tween.set_ease(Tween.EASE_OUT)
	_offset_tween.set_trans(Tween.TRANS_QUINT)
	_offset_tween.tween_property(self, "split_offset", target, time)
	return _offset_tween
