class_name CubeMod
extends CardModifierComponent

const CUBE_SCENE: PackedScene = preload("res://scenes/card/card_modifier/mods/cube_mod/card_cube.tscn")


func apply(card: Card) -> void:
	card.card_texture.add_child(CUBE_SCENE.instantiate())


func remove(card: Card) -> void:
	for node in card.card_texture.get_children():
		if node is CardCube:
			card.card_texture.remove_child(node)
			return
