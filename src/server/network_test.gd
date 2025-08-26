extends Node2D

@export
var server: Server

func _ready() -> void:
	var arr1 = {
		"nome": "joao",
		"cartas": []
	}
	var arr2 = {
		"nome": "joao",
		"cartas": []
	}
	for i in range(3):
		arr1.cartas.push_back("banana")
	for i in range(3):
		arr2.cartas.push_back("banana")
	var arr3 = {
		"nome": "joao",
		"cartas": []
	}
	
	var dict: Dictionary[Dictionary, int] = {}
	dict.set(arr1, 1)
	dict.set(arr2, 2)
	dict.set(arr3, 3)
	
	print(dict.get(arr1))
	print(dict.get(arr2))
	print(dict.get(arr3))
