class_name Draggable
extends Container

# Signals if the container was dropped after being dragged by the mouse
signal grabbed
signal dropped
# Signals if the container was clicked on
signal clicked

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

# Thresholds for card dragging
var drag_threshold: float = 10.0 if OS.get_name() == "Android" else 10.0
var drag_cos_threshold: float = 0.85 if OS.get_name() == "Android" else 1.0

var _try_grab: bool
var _grabbed: bool
var _grab_position: Vector2

var _scale_tween: Tween
var _position_tween: Tween
var _modulate_tween: Tween

var _child: CanvasItem = null


#region HELPERS
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


func set_child_scale(sc: Vector2):
	_child.scale = sc


func set_child_position(pos: Vector2):
	_child.position = pos


func set_child_modulate(color: Color):
	_child.modulate = color
#endregion TWEENS


#region INPUT HANDLING
func _input(event: InputEvent) -> void:
	if _child == null:
		return
	
	if ((_grabbed or _try_grab) and (event is InputEventMouseButton)
	and event.button_index == MOUSE_BUTTON_LEFT and event.is_released()):
		# Check if it was a click or a drag (signal if clicked)
		if _try_grab:
			clicked.emit()
		elif _grabbed:
			# Reattaches the image to its container.
			toggle_detached(false)
			# Go back to the container position
			tween_child_position(Vector2(0,0))
		# Signals that the card was dropped
		_grabbed = false
		_try_grab = false
		dropped.emit()
	
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
			if absf(drag_cos) <= drag_cos_threshold:
				# Signals that the card was grabbed
				_grabbed = true
				grabbed.emit()
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
		tween_child_scale(Vector2(1.0, 1.0)) # scale back down
		_grab_position = _child.get_local_mouse_position()
#endregion INPUT HANDLING


#region CALLBACKS
func _on_resized() -> void:
	if _child == null:
		return
	
	if _child is Control:
		_child.size = size
		_child.pivot_offset = size/2.0 # fixes scaling

	if _scale_tween and not _scale_tween.is_running():
		_child.scale = Vector2(1.0, 1.0)
	
	# Updates card position
	if _position_tween and not _position_tween.is_running():
		if _grabbed:
			_child.position = get_global_mouse_position() - _grab_position
		else:
			_child.position = Vector2(0,0)


# Grow and shrink if mouse entered
func _on_mouse_entered() -> void:
	if _child and clickable and not _grabbed:
		tween_child_scale(Vector2(1.0, 1.0)*1.05)

func _on_mouse_exited() -> void:
	# we need to check _child because if the node is queue_free()'d
	# the child will be null and this will throw a fatal error
	if _child and clickable:
		tween_child_scale(Vector2(1.0, 1.0))
#endregion


func _update_child(_node: Node) -> void:
	if get_child_count() == 0:
		_child = null
		return
	
	_child = get_child(0)
	#_child.position = Vector2(0,0)
	if _child is Control:
		_child.size = size
		_child.pivot_offset = size/2.0 # fixes scaling
	_child.scale = Vector2(1.0, 1.0)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	resized.connect(_on_resized)
	# Change _child if necessary
	child_entered_tree.connect(_update_child)
	child_exiting_tree.connect(_update_child)
	_update_child(null)


func _exit_tree() -> void:
	var old_pos = global_position
	await resized
	var new_pos = global_position
	
	if old_pos != new_pos and _position_tween and not _position_tween.is_running():
		var offset = old_pos - new_pos
		set_child_position(offset)
		tween_child_position(Vector2(0,0))
		pass
