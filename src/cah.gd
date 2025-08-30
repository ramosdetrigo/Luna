extends Node

const CARD_SCENE: PackedScene = preload("res://src/card_ui/card/card.tscn")
const CARD_GROUP_SCENE: PackedScene = preload("res://src/card_ui/card_group/card_group.tscn")

# 534,812: base card image resolution
const CARD_IMAGE_SIZE: Vector2 = Vector2(534, 812)

# Shader material that fixes that stupid emoji bug
const TEXTEDIT_MATERIAL = preload("res://src/card_ui/card/text_edit_material.tres")
# Base gradient material for special cards
const BASE_GRADIENT_MATERIAL = preload("res://src/card_ui/card/gradient_material.tres")

# Color gradients for special cards
const gradients: Array[Gradient] = [
	preload("res://src/card_ui/card/gradients/aroace.tres"),     # 0
	preload("res://src/card_ui/card/gradients/aromantic.tres"),  # 1
	preload("res://src/card_ui/card/gradients/asexual.tres"),    # 2
	preload("res://src/card_ui/card/gradients/bisexual.tres"),   # 3
	preload("res://src/card_ui/card/gradients/demisexual.tres"), # 4
	preload("res://src/card_ui/card/gradients/lesbian.tres"),    # 5
	preload("res://src/card_ui/card/gradients/lgbt.tres"),       # 6
	preload("res://src/card_ui/card/gradients/nonbinary.tres"),  # 7
	preload("res://src/card_ui/card/gradients/pansexual.tres"),  # 8
	preload("res://src/card_ui/card/gradients/trans.tres")       # 9
]
# Lookup table for special cards that use gradients
const gradient_cards: Dictionary[String, Gradient] = {
	"Aroaces.": gradients[0],
	"Arromânticos.": gradients[1],
	"Assexuais.": gradients[2],
	"Bissexuais.": gradients[3],
	"Demissexuais.": gradients[4],
	"Lésbicas.": gradients[5],
	"LGTV.": gradients[6],
	"Gays.": gradients[6],
	"Viado.": gradients[6],
	"Arco-íris!": gradients[6],
	"Não-binários.": gradients[7],
	"Pansexuais.": gradients[8],
	"Trans.": gradients[9],
}

# All card textures. Preloading them cause we're gonna use them all anyway
# and it really isn't all that heavy on RAM.
const textures: Array[CompressedTexture2D] = [
	preload("res://assets/images/cards/black_front.png"),   # 0
	preload("res://assets/images/cards/black_back.png"),    # 1
	preload("res://assets/images/cards/white_front.png"),   # 2
	preload("res://assets/images/cards/white_back.png"),    # 3
	preload("res://assets/images/cards/A.png"),             # 4
	preload("res://assets/images/cards/big.png"),           # 5
	preload("res://assets/images/cards/blood.png"),         # 6
	preload("res://assets/images/cards/bolsonaro.png"),     # 7
	preload("res://assets/images/cards/brasil.png"),        # 8
	preload("res://assets/images/cards/felps_bombado.png"), # 9
	preload("res://assets/images/cards/pau.png"),           # 10
]
# Lookup table for custom cards that use specific textures.
const custom_cards: Dictionary[String, Dictionary] = {
	"<glitch_text>": {"text": "r@^^()5", "texture": textures[2]},
	"<A>": {"text": "", "texture": textures[4]},
	"<O tamanho dessa carta>": {"text": "O tamanho dessa carta.", "texture": textures[5]},
	"<As abelhas chegaram>": {"text": "", "texture": textures[6]},
	"<Bolsonaro>": {"text": "", "texture": textures[7]},
	"<Brasil>": {"text": "", "texture": textures[8]},
	"<Felps bombado>": {"text": "", "texture": textures[9]},
	"<Pau>": {"text": "", "texture": textures[10]}
}


# Wraps emojis in white color BBCode
func wrap_emojis(text: String) -> String:
	const wrap_in = "<:!in!:>"
	const wrap_out = "<:!out!:>"
	const wrap_out_in = wrap_out + wrap_in
	var out := ""
	var i := 0
	while i < text.length():
		var ch = text.substr(i, 1)

		# quick regex check for base emoji
		if RegEx.create_from_string("[\\p{Extended_Pictographic}]").search(ch):
			var cluster = ch
			i += 1
			# absorb modifiers, ZWJ sequences, variation selectors
			while i < text.length():
				var next = text.substr(i, 1)
				var cp = next.unicode_at(0)
				# Zero Width Joiner → continue cluster
				if cp == 0x200D:
					cluster += next
					i += 1
					if i < text.length():
						cluster += text.substr(i, 1)
						i += 1
					continue
				# Fitzpatrick skin tones
				elif cp >= 0x1F3FB and cp <= 0x1F3FF:
					cluster += next
					i += 1
					continue
				# Variation Selector-16 (emoji presentation)
				elif cp == 0xFE0F:
					cluster += next
					i += 1
					continue
				else:
					break
			out += wrap_in + cluster + wrap_out
		else:
			out += ch
			i += 1
	out = out.replace(wrap_out_in, "")
	out = out.replace(wrap_in, "[color=#ffffff]")
	out = out.replace(wrap_out, "[/color]")
	return out
