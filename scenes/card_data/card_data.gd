@tool
class_name CardData
extends Resource

var text: String = ""
var modifiers: Array[CardModifier] = []


func _init(json_data) -> void:
	# Case 1: plain text
	if json_data is String:
		text = json_data
		return

	# Case 2: modded card
	json_data = json_data as Dictionary
	text = json_data.get("text")
	var mods = json_data.get("modifiers")
	if mods is Array:
		for mod_data: Dictionary in mods:
			match mod_data["mod_type"]:
				"glitch":
					modifiers.push_back(GlitchMod.new(mod_data))
				"gradient":
					modifiers.push_back(GradientMod.new(mod_data))
				"3dobj":
					modifiers.push_back(CubeMod.new(mod_data))
				"base":
					modifiers.push_back(CardModifier.new(mod_data))
