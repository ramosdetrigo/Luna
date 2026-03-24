class_name Draggable
extends Control

signal pressed
signal drag_started
signal drag_stopped

@export var drag_target: CanvasItem

@export_range(0.0, 1.0) var min_drag_cos: float = 0.0
@export_range(0.0, 1.0) var max_drag_cos: float = 1.0
@export var drag_threshold: float = 20.0

var trying_drag: bool = false
var dragging: bool = false
var drag_anchor: Vector2 = Vector2(0.0, 0.0)

var pos_tween: Tween

func tween_position(target: Vector2, time: float = 0.2) -> void:
	if pos_tween: pos_tween.kill()
	pos_tween = create_tween()
	pos_tween.set_ease(Tween.EASE_OUT)
	pos_tween.set_trans(Tween.TRANS_BACK)
	pos_tween.tween_property(drag_target, "position", target, time)


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		trying_drag = event.pressed
		if trying_drag:
			drag_anchor = get_local_mouse_position()
		else:
			if not dragging:
				pressed.emit()
			dragging = false
			drag_stopped.emit()
			tween_position(Vector2.ZERO)
	elif event is InputEventMouseMotion:
		var drag_vector: Vector2 = get_local_mouse_position() - drag_anchor
		var drag_cos: float = absf(drag_vector.normalized().dot(Vector2.RIGHT))
		if not dragging and trying_drag and drag_vector.length() >= drag_threshold:
			# Stop the drag attempt if the angle is bad
			if drag_cos < min_drag_cos or drag_cos > max_drag_cos:
				trying_drag = false
			else:
				dragging = true
				drag_started.emit()
		if not dragging: return
		tween_position(drag_vector)
