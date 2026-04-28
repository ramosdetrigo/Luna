@tool
class_name GlitchMod
extends CardModifier
## Glitch mod schema:
## "mod_type": "glitch"
## "character_pool": String

@export
var characters: String = "!@#$%¨&*()-=+_[]{}/?;:<>.,~^´`abcdefghijklmnopqrstuvwxyz"
@export
var min_text_length: int = 8
@export
var max_text_length: int = 14
@export
var delay: float = 0.0

var _timer: float = 0.0

func _init(mod_data = null):
	if mod_data is not Dictionary:
		return
	super(mod_data)
	var character_pool = mod_data.get("character_pool")
	if character_pool is String:
		characters = character_pool


func apply(card: Card) -> void:
	super(card)
	card.static_text.text = _random_text()


func process(card: Card, delta: float) -> void:
	_timer += delta
	if _timer > delay:
		_timer = 0.0
		card.static_text.text = _random_text()


func remove(card: Card) -> void:
	super(card)
	card.static_text.text = card.text


func _random_text() -> String:
	var output = ""
	for i in range(randi_range(min_text_length, max_text_length)):
		var c = characters[randi_range(0, len(characters) - 1)]
		output += c
	return output
