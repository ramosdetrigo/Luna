extends Control
class_name Screen

@warning_ignore("unused_signal") # it is fucking used in OTHER SCENES. ugh.
signal change_scene(scene : PackedScene)
@export var animation_speed : float = 1.25

var tween_list: Array[Tween] = []


func kill_tweens() -> void:
	var tween = tween_list.pop_back()
	while tween:
		tween.kill()
		tween = tween_list.pop_back()


func fade(leaving: bool = false, delete: bool = true) -> void:
	kill_tweens()
	var fade_tween = create_tween()
	tween_list.push_back(fade_tween)
	if leaving:
		fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		fade_tween.tween_callback(hide)
		if delete:
			fade_tween.tween_callback(queue_free)
	else:
		modulate = Color.TRANSPARENT
		show()
		fade_tween.tween_property(self, "modulate", Color.WHITE, animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func scale_fade(leaving:bool=false, delete:bool=true) -> void:
	var scale_tween = create_tween()
	var fade_tween = create_tween()
	if leaving:
		scale_tween.tween_property(self, "scale", Vector2(0.25,0.25), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, animation_speed*0.75).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		fade_tween.tween_callback(hide)
		scale_tween.tween_callback(hide)
		if delete:
			fade_tween.tween_callback(queue_free)
	else:
		scale = Vector2(0.0, 0.0)
		scale_tween.tween_property(self, "scale", Vector2(1,1), animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		modulate = Color.TRANSPARENT
		show()
		fade_tween.tween_property(self, "modulate", Color.WHITE, animation_speed).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
