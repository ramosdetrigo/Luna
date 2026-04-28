extends Node


# TODO: better error handling if possible
func deserialize_texture(data: Dictionary) -> Texture2D:
	# Internet link
	if data.get("format") == "url":
		return await download_image(data.get("url"))
	# Gif
	elif data.get("format") == "gif":
		var gif: GIFTexture = GIFTexture.new()
		gif.data = data.get("data")
		return gif
	# Raw image
	elif data.get("format") is int:
		var format = data.get("format")
		var bytes = data.get("data")
		var mipmaps = data.get("mipmaps")
		var width = data.get("width")
		var height = data.get("height")

		var img: Image = Image.create_from_data(width, height, mipmaps, format, bytes)
		return ImageTexture.create_from_image(img)
	return null


func serialize_url(url: String) -> Dictionary:
	if not is_url(url):
		return { }
	return { "format": "url", "url": url }


func serialize_texture(texture: Texture2D) -> Dictionary:
	if texture == null:
		return { }
	if texture is GIFTexture:
		return { "format": "gif", "data": texture.data }
	else:
		return serialize_image(texture.get_image())


func serialize_image(image: Image) -> Dictionary:
	if image == null:
		return { }
	var data = image.data.duplicate()
	data["format"] = image.get_format()
	return data


func is_url(text: String) -> bool:
	var urlRegex = RegEx.create_from_string('^(http|https)://[^ "]+$')
	return urlRegex.search(text) != null


func download_image(url: String) -> Texture2D:
	if not is_url(url):
		return null

	var response = await http_request(url)
	var result: int = response[0]
	var headers: PackedStringArray = response[2]
	var body: PackedByteArray = response[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		return null

	# Tries to get the image from the request
	for field: String in headers:
		if field.begins_with("Content-Type: image/"):
			var img_type = field.replace("Content-Type: image/", "")
			return load_image_from_buffer(img_type, body)

	# If the request has no image
	return null


func http_request(url) -> Array:
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request(url)
	var response: Array = await http.request_completed
	http.queue_free()
	return response


func load_image_from_buffer(extension: String, buffer: PackedByteArray) -> Texture2D:
	var img: Image = Image.new()
	var error: Error

	match extension.to_lower():
		"jpg", "jpeg":
			error = img.load_jpg_from_buffer(buffer)
		"png":
			error = img.load_png_from_buffer(buffer)
		"webp":
			error = img.load_webp_from_buffer(buffer)
		"svg", "svg+xml":
			error = img.load_svg_from_buffer(buffer)
		"bmp":
			error = img.load_bmp_from_buffer(buffer)
		"ktx":
			error = img.load_ktx_from_buffer(buffer)
		"gif":
			if is_gif_data_valid(buffer):
				var gif: GIFTexture = GIFTexture.new()
				gif.data = buffer
				return gif
		_:
			return null
	if error != OK:
		return null
	return ImageTexture.create_from_image(img)


# This may seem dumb, but the lib also checks for errors by
# opening the buffer with a gifreader :P
func is_gif_data_valid(data: PackedByteArray) -> bool:
	var gif_img: GIFReader = GIFReader.new()
	var gif_error: GIFReader.GIFError = gif_img.open_from_buffer(data)
	return gif_error == OK
