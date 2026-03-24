class_name CustomImageContainer
extends MarginContainer

enum ImageType {
	NO_IMAGE,
	STATIC,
	ANIMATED,
}

@export var static_image: TextureRect
@export var animated_image: GIFPlayer
@export var image_type: ImageType = ImageType.NO_IMAGE
@export var image_url: String = "" : set = set_image_url


#func _ready() -> void:
	#await set_image_url("https://media.tenor.com/AbHVaTiljsMAAAAM/kurica.gif") # watsap


func get_image_data() -> Dictionary:
	if image_url != "":
		return ImageLoader.serialize_url(image_url)
	match image_type:
		ImageType.STATIC:
			return ImageLoader.serialize_texture(static_image.texture)
		ImageType.ANIMATED:
			return ImageLoader.serialize_texture(animated_image.gif)
		_:
			return {}


func set_image(image: Texture2D) -> void:
	remove_image()
	if image == null:
		return
	elif image is GIFTexture:
		_set_animated(image)
	else:
		_set_static(image)


func set_image_url(url: String) -> void:
	var image: Texture = await ImageLoader.download_image(url)
	set_image(image)


# TODO: better error handling if possible
func set_image_data(data: Dictionary) -> void:
	if data.get("format") == "url":
		image_url = data.get("url")
	var texture: Texture2D = await ImageLoader.deserialize_texture(data)
	set_image(texture)


func _set_static(image: Texture2D) -> void:
	image_type = ImageType.STATIC
	static_image.texture = image


func _set_animated(gif: GIFTexture) -> void:
	image_type = ImageType.ANIMATED
	animated_image.gif = gif


func remove_image() -> void:
	image_type = ImageType.NO_IMAGE
	static_image.texture = null
	animated_image.gif = null
