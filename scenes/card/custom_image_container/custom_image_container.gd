@tool
class_name CustomImageContainer
extends MarginContainer


@export var static_image: TextureRect
@export var animated_image: AnimatedSprite2D
@export_enum("static", "animated") var image_type


func set_image(image: CompressedTexture2D) -> void:
	static_image.image = image


func remove_image() -> void:
	static_image.texture = null
