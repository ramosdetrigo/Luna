class_name CardModifier
extends Node

var mods: Array
var card: Card

func _init(target_card: Card, modifiers: Array) -> void:
	mods = modifiers
	card = target_card

func apply() -> void:
	for mod in mods:
		mod.apply(card)

func _process(delta: float) -> void:
	for mod in mods:
		mod.process(card, delta)
