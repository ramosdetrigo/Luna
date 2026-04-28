@tool
extends Node

const MAIN_TEXTURES: Dictionary[String, Texture2D] = {
	"white_front": preload("uid://du0agvqxdn2oy"),
	"white_back": preload("uid://3i1vrj47g4ae"),
	"black_front": preload("uid://fnmsykomv66w"),
}

var CARD_MODS: Dictionary[String, GDScript] = {
	"basic": CardModifier,
	"glitch": GlitchMod,
	"gradient": GradientMod,
	"3dobj": CubeMod,
}
