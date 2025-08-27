extends Control


func _ready() -> void:
	update_children_pivot()


func update_children_pivot() -> void:
	for node: Control in %ScreenHolder.get_children():
		node.pivot_offset = node.size / 2.0


func _on_resized() -> void:
	update_children_pivot()


func _on_change_scene(scene: PackedScene, transition: int) -> void:
	print("change")
	var scene_node: Screen = scene.instantiate()
	scene_node.change_scene.connect(_on_change_scene)
	%ScreenHolder.add_child(scene_node)
	scene_node.scale_fade(false)
	update_children_pivot()
