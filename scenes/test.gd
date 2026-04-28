extends TextureRect


func _ready() -> void:
	print(CAHConsts.CARD_MODS)
	var t = GIFTexture.load_from_file("res://kurica.gif")
	$GIFPlayer.gif = t
