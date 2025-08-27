extends Control
class_name Screen

signal change_scene(scene : PackedScene, transition : int)
@export var animation_speed : float = 1.25
var tweens : Array[Tween] = []


func kill_tweens() -> void:
	for i in range(len(tweens)):
		var t = tweens.pop_front()
		t.kill()

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
		fade_tween.tween_callback(hide)
		scale_tween.tween_callback(hide)
		scale_tween.tween_callback(queue_free)
