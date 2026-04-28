class_name GlitchMod
extends CardModifier
## Glitch mod schema:
## "mod_type": "glitch"
## "character_pool": String

var characters: String = "!@#$%¨&*()-=+_[]{}/?;:<>.,~^´`abcdefghijklmnopqrstuvwxyz"


func _init(mod_data: Dictionary):
	super(mod_data)
	var character_pool = mod_data.get("character_pool")
	if character_pool is String:
		characters = character_pool


func apply(card: Card) -> void:
	super(card)
	card.static_text.text = _random_text()


func process(card: Card, _delta: float) -> void:
	card.static_text.text = _random_text()


func _random_text() -> String:
	var output = ""
	for i in range(randi_range(8, 14)):
		var c = characters[randi_range(0, len(characters) - 1)]
		output += c
	return output
