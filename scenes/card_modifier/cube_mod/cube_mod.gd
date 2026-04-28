# TODO: 3DObjMod
class_name CubeMod
extends CardModifier

const CUBE_SCENE: PackedScene = preload("uid://bu0q0do8jxixj")


func apply(card: Card) -> void:
	super(card)
	card.card_texture.add_child(CUBE_SCENE.instantiate())


func remove(card: Card) -> void:
	super(card)
	for node in card.card_texture.get_children():
		if node is CardCube:
			card.card_texture.remove_child(node)
			return
