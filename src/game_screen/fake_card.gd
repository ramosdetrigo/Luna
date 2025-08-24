extends AspectRatioContainer

@export
var glowing: bool = false

var _edge_modulate_tween: Tween

func toggle_glow(enable: bool) -> Tween:
	glowing = enable
	if _edge_modulate_tween:
		_edge_modulate_tween.kill()
	_edge_modulate_tween = %FakeCardEdge.create_tween().set_trans(Tween.TRANS_QUAD)
	_edge_modulate_tween.set_ease(Tween.EASE_OUT)
	if enable:
		%FakeCardEdge.show()
		_edge_modulate_tween.tween_property(%FakeCardEdge, "modulate", Color.WHITE, 0.5)
	else:
		_edge_modulate_tween.tween_property(%FakeCardEdge, "modulate", Color.TRANSPARENT, 0.5)
		_edge_modulate_tween.finished.connect(%FakeCardEdge.hide)
	return _edge_modulate_tween

func _ready() -> void:
	toggle_glow(glowing)
