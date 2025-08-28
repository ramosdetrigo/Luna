extends RichTextLabel

@export
var wait_time: float = 1.0/45.0
var timer: float = 0.0

var _erasing: bool = false
var _target_text: String = text


func _ready() -> void:
	pass
	#set_text_instant(text)


func set_text_instant(new_text: String) -> void:
	_target_text = new_text
	text = new_text


func animate_text(new_text: String) -> void:
	_erasing = true
	_target_text = new_text


func _physics_process(delta: float) -> void:
	timer += delta
	if timer < wait_time:
		return
	
	timer = 0.0
	if _erasing:
		# apaga o último caractere do texto
		if text == "":
			_erasing = false
		else:
			text = text.erase(text.length() - 1)
	elif text.length() != _target_text.length():
		# pega o próximo caractere do texto alvo
		text = text + _target_text[text.length()]
