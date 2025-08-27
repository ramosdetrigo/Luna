class_name FloatingButton
extends Button

@export var animation_speed : float = 1.0
@export var target_scale : float = 1.2
@onready var label : Label = $Label
var scale_tween : Tween
var color_tween : Tween


func _ready():
	$Label.theme = theme
	$Label.text = text
	text = ""


func _on_mouse_entered():
	var duration = animation_speed * ( (((label.scale.x - 1) /  (target_scale - 1)) - 1) * -1)
	
	if scale_tween != null: scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", Vector2(target_scale,target_scale), duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _on_mouse_exited():
	var duration = animation_speed * ((label.scale.x - 1) /  (target_scale - 1))
	
	if scale_tween != null: scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", Vector2(1,1), duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _on_pressed():
	label.scale = Vector2(target_scale,target_scale)
	
	if scale_tween != null: scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", Vector2(1,1), animation_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func show_fading():
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	if color_tween != null:
		color_tween.kill()
	color_tween = get_tree().create_tween()
	color_tween.tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func hide_fading():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if color_tween != null:
		color_tween.kill()
	color_tween = get_tree().create_tween()
	color_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await color_tween.finished
	hide()
