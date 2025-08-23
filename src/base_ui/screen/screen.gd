extends Control
class_name Screen


@export var animation_speed : float = 1.25
var tweens : Array[Tween] = []


func kill_tweens() -> void:
	for i in range(len(tweens)):
		var t = tweens.pop_front()
		t.kill()

func slide_up(leaving:bool=false) -> void:
	kill_tweens()
	var position_tween = get_tree().create_tween()
	tweens.push_back(position_tween)
	if not leaving:
		position.y = get_viewport().size.y
		position_tween.tween_property(self, "position", Vector2(0,0), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		position_tween.tween_property(self, "position", Vector2(0,-get_viewport().size.y), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	fade(leaving)

func slide_down(leaving:bool=false) -> void:
	kill_tweens()
	var position_tween = get_tree().create_tween()
	tweens.push_back(position_tween)
	if not leaving:
		position.y = -get_viewport().size.y
		position_tween.tween_property(self, "position", Vector2(0,0), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		position_tween.tween_property(self, "position", Vector2(0,get_viewport().size.y), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	fade(leaving)
	await position_tween.finished

func slide_left(leaving:bool=false) -> void:
	kill_tweens()
	var position_tween = get_tree().create_tween()
	tweens.push_back(position_tween)
	if not leaving:
		position.x = get_viewport().size.x
		position_tween.tween_property(self, "position", Vector2(0,0), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		position_tween.tween_property(self, "position", Vector2(-get_viewport().size.x,0), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	fade(leaving)

func slide_right(leaving:bool=false) -> void:
	kill_tweens()
	var position_tween = get_tree().create_tween()
	tweens.push_back(position_tween)
	if not leaving:
		position.x = -get_viewport().size.x
		position_tween.tween_property(self, "position", Vector2(0,0), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		position_tween.tween_property(self, "position", Vector2(get_viewport().size.x,0), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	fade(leaving)

func fade(leaving:bool=false) -> void:
	#kill_tweens()
	var fade_tween = get_tree().create_tween()
	tweens.push_back(fade_tween)
	if not leaving:
		modulate = Color.TRANSPARENT
		fade_tween.tween_property(self, "modulate", Color.WHITE, animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		fade_tween.tween_callback(queue_free)

func scale_fade(leaving:bool=false) -> void:
	kill_tweens()
	var scale_tween = get_tree().create_tween()
	var fade_tween = get_tree().create_tween()
	if not leaving:
		scale = Vector2(0.25,0.25)
		scale_tween.tween_property(self, "scale", Vector2(1,1), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		modulate = Color.TRANSPARENT
		fade_tween.tween_property(self, "modulate", Color.WHITE, animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		scale_tween.tween_property(self, "scale", Vector2(0.25,0.25), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, animation_speed*0.75).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		scale_tween.tween_callback(queue_free)
