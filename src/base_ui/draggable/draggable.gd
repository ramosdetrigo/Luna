class_name Draggable
extends Container

# Signals if the container was dropped after being dragged by the mouse
signal grabbed
signal dropped
# Signals if the container was clicked on
signal clicked

# Thresholds for card dragging
@export_range(0.0, 100.0)
var drag_threshold: float = 5.0
@export_range(0.0, 1.0, 0.05)
var drag_cos_threshold: float = 0.85

@export
var scale_transition: Tween.TransitionType = Tween.TRANS_BACK
@export
var position_transition: Tween.TransitionType = Tween.TRANS_BACK
@export
var modulate_transition: Tween.TransitionType = Tween.TRANS_QUAD

@export
var target_size: Vector2 = Vector2(1.0, 1.0)
@export
var clickable: bool = true

var _try_grab: bool
var _grabbed: bool
var _grab_position: Vector2

var _scale_tween: Tween
var _position_tween: Tween
var _modulate_tween: Tween

var _child: CanvasItem = null


#region HELPERS
func get_target_scale() -> Vector2:
	if target_size == Vector2(1.0, 1.0):
		return Vector2(1.0, 1.0)
	return size / target_size


func toggle_detached(detached: bool) -> void:
	var previous_coords = _child.global_position
	_child.top_level = detached
	_child.global_position = previous_coords
#endregion HELPERS


#region TWEENS
func tween_child_scale(sc: Vector2, time: float = 0.2) -> void:
	if _scale_tween:
		_scale_tween.kill()
	_scale_tween = create_tween()
	_scale_tween.set_ease(Tween.EASE_OUT)
	_scale_tween.set_trans(scale_transition)
	_scale_tween.tween_property(_child, "scale", sc, time)


func tween_child_position(pos: Vector2, time: float = 0.2) -> void:
	if _position_tween:
		_position_tween.kill()
	_position_tween = create_tween()
	_position_tween.set_ease(Tween.EASE_OUT)
	_position_tween.set_trans(position_transition)
	_position_tween.tween_property(_child, "position", pos, time)


func tween_child_modulate(color: Color, time: float = 0.2) -> void:
	if _modulate_tween:
		_modulate_tween.kill()
	_modulate_tween = create_tween()
	_modulate_tween.set_ease(Tween.EASE_OUT)
	_modulate_tween.set_trans(modulate_transition)
	_modulate_tween.tween_property(_child, "modulate", color, time)
#endregion TWEENS


#region INPUT HANDLING
func _input(event: InputEvent) -> void:
	if _child == null:
		return
	
	if ((_grabbed or _try_grab) and (event is InputEventMouseButton)
	and event.button_index == MOUSE_BUTTON_LEFT and event.is_released()):
		# Check if it was a click or a drag (signal if clicked)
		if _try_grab:
			clicked.emit(self)
		elif _grabbed:
			# Reattaches the image to its container.
			toggle_detached(false)
			# Go back to the container position
			tween_child_position(Vector2(0,0))
		# Signals that the card was dropped
		_grabbed = false
		_try_grab = false
		dropped.emit(self)
	
	if event is not InputEventMouseMotion and event is not InputEventScreenDrag:
		return
	
	if _try_grab:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var original_pos: Vector2 = _child.global_position + _grab_position
		var drag_distance = mouse_pos.distance_to(original_pos)
		
		var drag_vector: Vector2 = (mouse_pos-original_pos).normalized()
		var drag_cos: float = Vector2.RIGHT.dot(drag_vector)
		
		if drag_distance > drag_threshold:
			_try_grab = false
			if absf(drag_cos) < drag_cos_threshold:
				# Signals that the card was grabbed
				_grabbed = true
				grabbed.emit(self)
				toggle_detached(true)
	if _grabbed:
		# Updates card grab coords and starts a tween
		var target_pos = get_global_mouse_position() - _grab_position
		tween_child_position(target_pos)
		get_viewport().set_input_as_handled()


# TODO: oh shit oh fuck what about touch inputs oh no
func _on_gui_input(event: InputEvent) -> void:
	# is_pressed: card grabbed, is_released: card dropped
	if (_child and event.is_pressed() and event is InputEventMouseButton
	and event.button_index == MOUSE_BUTTON_LEFT):
		_try_grab = true
		tween_child_scale(get_target_scale()) # scale back down
		_grab_position = _child.get_local_mouse_position() - target_size/2.0*get_target_scale()
#endregion INPUT HANDLING


#region INPUT CALLBACKS
func _on_resized() -> void:
	if _child == null:
		return
	
	_child.size = size
	_child.pivot_offset = size/2.0

	if _scale_tween and not _scale_tween.is_running():
		_child.scale = get_target_scale()
	
	# Updates card position
	if _position_tween and not _position_tween.is_running():
		if _grabbed:
			_child.position = get_global_mouse_position() - _grab_position
		else:
			_child.position = Vector2(0,0)


# Grow and shrink if mouse entered
func _on_mouse_entered() -> void:
	if _child and clickable and not _grabbed:
		tween_child_scale(get_target_scale()*1.05)

func _on_mouse_exited() -> void:
	# we need to check _child because if the node is queue_free()'d
	# the child will be null and this will throw a fatal error
	if _child and clickable:
		tween_child_scale(get_target_scale())


# Change _child if necessary
func _on_child_entered_tree(node: Node) -> void:
	if _child == null:
		_child = node
		_child.position = Vector2(0,0)
		_child.size = size
		_child.pivot_offset = size/2.0
		_child.scale = get_target_scale()

func _on_child_exiting_tree(_node: Node) -> void:
	_child = get_child(0)
#endregion CALLBACKS
