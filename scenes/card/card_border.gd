@tool
extends Sprite2D

@export var fade_time: float = 1.0

var fade_tween: Tween


func fade_in() -> void:
	_reset_tween()
	show()
	fade_tween.tween_property(self, "modulate", Color.WHITE, fade_time)


func fade_out() -> void:
	_reset_tween()
	fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_time)
	fade_tween.tween_callback(hide)


func _reset_tween() -> void:
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
