@tool
extends Control

const CARD_SIZE: Vector2 = Vector2(646, 896)

@onready var card_texture: Sprite2D = %CardTexture

var dragging: bool
var drag_anchor: Vector2 = Vector2(0.0, 0.0)
var pos_tween: Tween


@export_range(0.0, PI) var min_drag_angle: float = 0.0

func _ready() -> void:
	_on_resized()


func _on_resized() -> void:
	var scale_target = size.x / CARD_SIZE.x
	card_texture.scale = Vector2(scale_target, scale_target)


func tween_position(target: Vector2, time: float = 0.2) -> void:
	if pos_tween: pos_tween.kill()
	pos_tween = create_tween()
	pos_tween.set_ease(Tween.EASE_OUT)
	pos_tween.set_trans(Tween.TRANS_BACK)
	pos_tween.tween_property(card_texture, "position", target, time)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		dragging = event.pressed
		if dragging:
			drag_anchor = get_local_mouse_position()
		else:
			tween_position(Vector2.ZERO)
	elif event is InputEventMouseMotion:
		if not dragging:
			tween_position(Vector2.ZERO)
			return
		tween_position(get_local_mouse_position() - drag_anchor)
