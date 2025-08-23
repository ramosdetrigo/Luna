class_name PulseCheckbox
extends Button

@export var animation_speed : float = 1.0
@export var target_scale : float = 1.2
@export var label_text : String = ""
@export var is_toggled : bool = true
@onready var label : Label = $HBoxContainer/Control/Label
@onready var pulse_button : PulseButton = $HBoxContainer/C/C2/PulseButton
var scale_tween : Tween


func _ready():
	$HBoxContainer/C/C2/PulseButton.is_toggled = is_toggled
	if is_toggled:
		$HBoxContainer/C/C2/PulseButton/Icon.texture = $HBoxContainer/C/C2/PulseButton.texture_on
	else:
		$HBoxContainer/C/C2/PulseButton/Icon.texture = $HBoxContainer/C/C2/PulseButton.texture_off
	
	$HBoxContainer/Control/Label.text = label_text
	button_pressed = is_toggled


func _on_mouse_entered():
	var duration = animation_speed * ( (((label.scale.x - 1) /  (target_scale - 1)) - 1) * -1)
	
	if scale_tween != null:
		scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", Vector2(target_scale,target_scale), duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _on_mouse_exited():
	var duration = animation_speed * ((label.scale.x - 1) /  (target_scale - 1))
	
	if scale_tween != null:
		scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", Vector2(1,1), duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _pressed(on_checkbox=false):
	is_toggled = not is_toggled
	
	if on_checkbox:
		emit_signal("pressed")
	else:
		pulse_button._pressed()
	
	label.scale = Vector2(target_scale,target_scale)
	if scale_tween != null:
		scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", Vector2(1,1), animation_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)



func set_toggled(state : bool) -> void:
	is_toggled = state
	button_pressed = is_toggled
	pulse_button.set_toggled(state)
