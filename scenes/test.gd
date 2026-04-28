extends TextureRect


func _ready() -> void:
	var t = GIFTexture.load_from_file("res://kurica.gif")
	$GIFPlayer.gif = t
