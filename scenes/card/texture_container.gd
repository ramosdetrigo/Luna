@tool
extends Draggable

const CARD_SIZE: Vector2 = Vector2(646, 896)

func _on_resized() -> void:
	var scale_target = size.x / CARD_SIZE.x
	drag_target.scale = Vector2(scale_target, scale_target)
