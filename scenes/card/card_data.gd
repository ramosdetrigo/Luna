@tool
extends Node


const TEXTURES: Dictionary[StringName, String] = {
	&"white_front": "uid://du0agvqxdn2oy",
	&"white_back": "uid://3i1vrj47g4ae",
	&"black_front": "uid://fnmsykomv66w",
	&"black_back": "uid://ds311i05q56nr",
	&"A": "uid://chcttv6dg6kr1",
	&"big": "uid://bvg7uq8agr8l1",
	&"abelhas": "uid://chcttv6dg6kr1",
	&"bolsonaro": "uid://djekilda433ru",
	&"brasil": "uid://8a1rvrksj0mx",
	&"bunda": "uid://bg5xj130ycw4a",
	&"felps_bombado": "uid://yr2wv7j4a3cs",
	&"pau": "uid://2ixd0l7tvpom",
}

const MAIN_TEXTURES: Dictionary[StringName, CompressedTexture2D] = {
	&"white_front": preload(TEXTURES[&"white_front"]),
	&"white_back": preload(TEXTURES[&"white_back"]),
	&"black_front": preload(TEXTURES[&"black_front"]),
}


const GRADIENTS: Dictionary[String, Gradient] = {
	"AROACE": preload("uid://dwjs35fa16x6x"),
	"AROMANTIC": preload("uid://dae1biehv85f4"),
	"ASEXUAL" : preload("uid://q0oc3eap4q2n"),
	"BISEXUAL" : preload("uid://ovsqk053rybw"),
	"DEMISEXUAL" : preload("uid://c45ssesfu2vc"),
	"GAY" : preload("uid://v0dl8p057d6h"),
	"LESBIAN" : preload("uid://dl6urtyf2jyps"),
	"LGBT" : preload("uid://dbt0m1xngjiuw"),
	"NONBINARY" : preload("uid://bmuy44q2gekoc"),
	"PANSEXUAL" : preload("uid://cikll1nkhdxvr"),
	"TRANS" : preload("uid://dgb6fuvsq3vq3"),
}


var CARDS: Dictionary[Array, Array] = {
	["Cubo."]: [CubeMod.new()],
	["Lésbica.", "Lésbicas.", "Lexo sésbico."]: [TextGradientMod.new(GRADIENTS["LESBIAN"])],
	["Bissexuais.", "Bissexual."]: [TextGradientMod.new(GRADIENTS["BISEXUAL"])],
	["Trans.", "Direitos trans!"]: [TextGradientMod.new(GRADIENTS["TRANS"])],
	["Demissexuais.", "Demissexual."]: [TextGradientMod.new(GRADIENTS["DEMISEXUAL"])],
	["Não-binários.", "Não-binário.", "Enbies.", "NB.", "NBs."]: [TextGradientMod.new(GRADIENTS["NONBINARY"])],
	["Pansexuais.", "Pansexual."]: [TextGradientMod.new(GRADIENTS["PANSEXUAL"])],
	["Assexuais.", "Assexual."]: [TextGradientMod.new(GRADIENTS["ASEXUAL"])],
	["Arromânticos.", "Arromântico."]: [TextGradientMod.new(GRADIENTS["AROMANTIC"])],
	["Aroaces.", "Aroace."]: [TextGradientMod.new(GRADIENTS["AROACE"])],
	# TODO: arco-íris
	["Arco-íris!", "LGTV.", "LGBT.", "Gays."]: [TextGradientMod.new(GRADIENTS["LGBT"])],
	["Homens gays."]: [TextGradientMod.new(GRADIENTS["GAY"])],
	["<A>"]: [BasicMod.new(TEXTURES["A"], 10)],
	["<Abelhas>"]: [BasicMod.new(TEXTURES["abelhas"], 1)],
	["<Bolsonaro>"]: [BasicMod.new(TEXTURES["bolsonaro"], 10)],
	["<Brasil>"]: [BasicMod.new(TEXTURES["brasil"], 10)],
	["<Bunda>"]: [BasicMod.new(TEXTURES["bunda"], 10)],
	["<Carta preta>"]: [BasicMod.new(TEXTURES["black_front"], -1, "Carta preta.", Color.WHITE)],
	["<Felps bombado>"]: [BasicMod.new(TEXTURES["felps_bombado"], 10)],
	["<O tamanho dessa carta>"]: [BasicMod.new(TEXTURES["big"], -1, "O tamanho dessa carta.")],
	["<Pau>"]: [BasicMod.new(TEXTURES["pau"], 10)],
	["<glitch_text>"]: [GlitchMod.new()],
}


func get_card_modifier(card: Card, card_text: String) -> CardModifier:
	for l in CARDS:
		if card_text in l:
			return CardModifier.new(card, CARDS[l])
	return null
