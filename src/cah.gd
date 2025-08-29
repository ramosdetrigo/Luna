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
