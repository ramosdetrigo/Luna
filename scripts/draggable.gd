class_name Draggable
extends Control

signal pressed
signal drag_started
signal drag_stopped

@export var drag_target: Control
@export_range(0.0, 1.0) var min_drag_cos: float = 0.0
@export_range(0.0, 1.0) var max_drag_cos: float = 1.0
@export var drag_threshold: float = 20.0
@export var rotation_amount: float = 0.25
@export var rotation_min_speed: float = 250.0

var trying_drag: bool = false
var dragging: bool = false
var drag_anchor: Vector2 = Vector2(0.0, 0.0)
var previous_mouse_position: Vector2 = Vector2(0.0, 0.0)
var pos_tween: Tween
var rot_tween: Tween


static func _sigmoid(x: float) -> float:
	return (2.0 / 1.0 + pow(2.0, -x)) - 1


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	previous_mouse_position = get_local_mouse_position()


func _process(_delta: float) -> void:
	if dragging:
		# Applies a small rotation to the card depending on drag speed
		var drag_dx: float = get_local_mouse_position().x - previous_mouse_position.x;
		var s: float = sign(drag_dx)
		var amount: float = abs(drag_dx) / rotation_min_speed
		tween_rotation( clamp(amount, 0.0, rotation_amount) * s )
	previous_mouse_position = get_local_mouse_position()


func tween_position(target: Vector2, time: float = 0.2) -> void:
	if pos_tween:
		pos_tween.kill()
	pos_tween = create_tween()
	pos_tween.set_ease(Tween.EASE_OUT)
	pos_tween.set_trans(Tween.TRANS_BACK)
	pos_tween.tween_property(drag_target, "position", target, time)


# TODO: card rotation?
func tween_rotation(target: float, time: float = 0.2) -> void:
	if rot_tween:
		rot_tween.kill()
	rot_tween = create_tween()
	rot_tween.set_ease(Tween.EASE_OUT)
	rot_tween.set_trans(Tween.TRANS_BACK)
	rot_tween.tween_property(drag_target, "rotation", target, time)


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
			tween_rotation(0.0)
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
		if not dragging:
			return
		tween_position(drag_vector)
