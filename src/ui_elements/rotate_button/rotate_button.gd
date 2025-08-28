class_name RotateButton
extends Button

@export var is_toggled : bool = false
@export var texture : CompressedTexture2D

func _ready():
	$Icon.texture = texture
	if is_toggled:
		$Icon.rotation = PI

func _pressed():
	Global.play_audio(Global.SFX[0])
	if is_toggled:
		$AnimationPlayer.play_backwards("rotate")
	else:
		$AnimationPlayer.play("rotate")
	
	is_toggled = not is_toggled
