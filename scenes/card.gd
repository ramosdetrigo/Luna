@tool
class_name Card
extends AspectRatioContainer

enum CardType {
	WHITE,
	BLACK
}

const CARD_TEXTURES: Dictionary[StringName, CompressedTexture2D] = {
	&"WhiteFront": preload("uid://bh1wjx00rc4ff"),
	&"WhiteBack": preload("uid://b0pg7e2eaag27"),
	&"BlackFront": preload("uid://cdvowps1pk6f7"),
}

const CARD_TEXTURE_PATHS: Dictionary[StringName, StringName] = {
	&"A": &"uid://dnseg6tysrahm",
	&"big": &"uid://sbb0urccfasg",
	&"abelhas": &"uid://8li6o8xo3ob2",
	&"bolsonaro": &"uid://hn065orkgkqj",
	&"brasil": &"uid://d4c1earvlqfs2",
	&"bunda": &"uid://bx43m0gor77wn",
	&"felps": &"uid://de5bs16pe5j77",
	&"pau": &"uid://7tca80ivbv5v",
}

var SPECIAL_CARDS: Dictionary[String, SpecialCards.SpecialCard] = {
	"Lésbicas.": SpecialCards.Lesbica.new(),
	"Trans.": SpecialCards.Trans.new(),
	"LGTV.": SpecialCards.LGBTCard.new(),
}

@onready var editable_text: TextEdit = %EditableText
@onready var static_text: RichTextLabel = %StaticText
@onready var card_texture: Sprite2D = %CardTexture
@onready var static_text_container: SubViewportContainer = %StaticTextContainer


@export_multiline var text: String = "" : set = set_text
@export var card_type: CardType = CardType.WHITE : set = set_card_type
@export var flipped: bool = false : set = flip
@export var texture_override: CompressedTexture2D = null :
	set(texture):
		texture_override = texture
		_update_texture()

# TODO: Card height override + get_card_height

var special_card_node: Node = null :
	set(node):
		if special_card_node != null:
			remove_child(special_card_node)
		special_card_node = node
		add_child(special_card_node)

## Sets the card's text
func set_text(t: String) -> void:
	text = t
	if not editable_text: await ready
	editable_text.text = t
	static_text.text = t
	
	# Card reset
	texture_override = null
	static_text_container.material = null
	set_card_type(card_type)
	
	# Special card check
	var special_card: SpecialCards.SpecialCard = SPECIAL_CARDS.get(text)
	print(text)
	if special_card != null:
		special_card_node = special_card
		if not special_card.texture_path.is_empty():
			# NOTE: Target for optimization (ResourceLoader.load etc)
			texture_override = load(special_card.texture_path)
		print("special_card")
		special_card.post_init(self)
	else:
		special_card_node = null


## Sets the card's type and automatically changes its texture and text color
func set_card_type(type: CardType) -> void:
	card_type = type
	if type == CardType.WHITE:
		set_text_color(Color.BLACK)
	else:
		set_text_color(Color.WHITE)
	_update_texture()


## Change text color for both static and editable text
func set_text_color(color: Color) -> void:
	if not static_text: await ready
	static_text.add_theme_color_override("default_color", color)
	editable_text.add_theme_color_override("font_color", color)
	editable_text.add_theme_color_override("font_readonly_color", color)


## Sets the card's texture
func set_texture(texture: CompressedTexture2D) -> void:
	if not card_texture: await ready
	card_texture.texture = texture


## Loads the card's texture from a path
func set_texture_from_path(path: StringName) -> void:
	set_texture(load(path))


func flip(f: bool = not flipped) -> void:
	flipped = f
	_update_texture()


func _update_texture() -> void:
	if flipped: # Optimization: we don't use black flipped cards
		set_texture(CARD_TEXTURES["WhiteBack"])
	elif texture_override != null:
		set_texture(texture_override)
	elif card_type == CardType.WHITE:
		set_texture(CARD_TEXTURES["WhiteFront"])
	else: 
		set_texture(CARD_TEXTURES["BlackFront"])
