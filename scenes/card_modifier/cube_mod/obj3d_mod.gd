@tool
class_name Obj3DMod
extends CardModifier

const MESH_SCENE: PackedScene = preload("uid://bu0q0do8jxixj")

var _mesh_node: Card3DViewport
@export
var mesh: Mesh = BoxMesh.new():
	set(m):
		mesh = m
		if _mesh_node:
			_mesh_node.mesh = mesh

func _init(mod_data = null) -> void:
	if mod_data is not Dictionary:
		return
	# Loads mesh from path
	var mesh_path = mod_data.get("obj")
	if mesh_path is String:
		var new_mesh = load(mesh_path)
		if new_mesh is Mesh:
			mesh = new_mesh


func apply(card: Card) -> void:
	_mesh_node = MESH_SCENE.instantiate()
	_mesh_node.mesh = mesh
	card.card_texture.add_child(_mesh_node)
	_mesh_node.position = Vector2(-200, -200) # to center the cube. don't ask me.


func process(_card: Card, delta: float) -> void:
	if _mesh_node.mesh_instance_3d:
		_mesh_node.mesh_instance_3d.rotate_y(delta * deg_to_rad(60.0))


func remove(_card: Card) -> void:
	_mesh_node.queue_free()


func serialize() -> Dictionary:
	# TODO: define parameters and implement serialize
	return {}
