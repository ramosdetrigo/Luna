@tool
class_name CardTextureContainer
extends Draggable

const CARD_SIZE: Vector2 = Vector2(646, 896)
var scale_target: float = 1.0

func _on_resized() -> void:
	scale_target = size.x / CARD_SIZE.x
	drag_target.scale = Vector2(scale_target, scale_target)
