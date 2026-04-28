class_name GlitchMod
extends CardModifier

var characters: String = "!@#$%¨&*()-=+_[]{}/?;:<>.,~^´`abcdefghijklmnopqrstuvwxyz"


func apply(card: Card) -> void:
	super(card)
	var character_pool = json_data.get("character_pool")
	if character_pool is String:
		characters = character_pool
	card.static_text.text = _random_text()


func process(card: Card, _delta: float) -> void:
	super(card, _delta)
	card.static_text.text = _random_text()


func _random_text() -> String:
	var output = ""
	for i in range(randi_range(8, 14)):
		var c = characters[randi_range(0, len(characters) - 1)]
		output += c
	return output
