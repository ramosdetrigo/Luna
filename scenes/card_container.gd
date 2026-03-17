@tool
extends Control

const CARD_SIZE: Vector2 = Vector2(534, 812)

@onready var card_texture: Sprite2D = %CardTexture

func _ready() -> void:
	_on_resized()

func _on_resized() -> void:
	var target_scale: float = size.x / CARD_SIZE.x
	card_texture.scale = Vector2(target_scale, target_scale)
