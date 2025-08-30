extends Node2D





func _ready():
	var text = "asd😄🍉asd   as  dsad🐰🍋asd🏳️‍⚧️🇨🇾sda  🏳‍🟧‍⬛‍🟧sad👨🏾‍❤️‍💋‍👨🏼 🙅   🙅🙅adsdas🙅🏿🫃🫃🏻"
	print(text)
	var wrapped_text = CAH.wrap_emojis(text)
	
	print(wrapped_text)
	
	DisplayServer.clipboard_set(wrapped_text)
	get_tree().quit()
