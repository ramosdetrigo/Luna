@tool
class_name CardData
extends Resource

@export_multiline
var text: String = ""
@export
var modifiers: Array[CardModifier] = []


func _init(json_data = null) -> void:
	# Case 1: plain text
	if json_data is String:
		text = json_data
		return
	# Case 2: modded card
	elif json_data is Dictionary:
		text = json_data.get("text", "")
		var mods = json_data.get("modifiers")
		if mods is Array:
			for mod_data: Dictionary in mods:
				var mod_script: GDScript = CAHConsts.CARD_MODS[mod_data["mod_type"]]
				modifiers.push_back(mod_script.new(mod_data))
