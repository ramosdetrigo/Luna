class_name GlitchMod
extends CardModifierComponent


static func _random_text() -> String:
	const characters = "!@#$%¨&*()-=+_[]{}/?;:<>.,~^´`abcdefghijklmnopqrstuvwxyz"
	var output = ""
	for i in range(randi_range(8, 14)):
		var c = characters[randi_range(0, len(characters) - 1)]
		output += c
	return output


func apply(card: Card) -> void:
	card.static_text.text = _random_text()


func process(card: Card, _delta: float) -> void:
	card.static_text.text = _random_text()
