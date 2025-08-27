extends HSlider

signal hard_value_changed(value : int)
var value_tween : Tween
var scale_tween : Tween


func _ready():
	$HardSlider.value = value
	$HardSlider.min_value = min_value
	$HardSlider.max_value = max_value
	$HardSlider.step = step
	
	step = 0


func _on_hard_slider_value_changed(new_value):
	hard_value_changed.emit(new_value)
	if value_tween != null:
		value_tween.kill()
	value_tween = get_tree().create_tween()
	value_tween.tween_property(self, "value", new_value, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


#func _on_hard_slider_mouse_entered():
	#if scale_tween != null:
		#scale_tween.kill()
	#scale_tween = get_tree().create_tween()
	#scale_tween.tween_property(self, "scale", Vector2(1.0125,1.0125), 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
#
#
#func _on_hard_slider_mouse_exited():
	#if scale_tween != null:
		#scale_tween.kill()
	#scale_tween = get_tree().create_tween()
	#scale_tween.tween_property(self, "scale", Vector2(1,1), 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
