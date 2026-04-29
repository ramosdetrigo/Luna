@tool
class_name Card3DViewport
extends SubViewportContainer

@export var mesh: Mesh:
	set(m):
		mesh = m
		if mesh_instance_3d == null:
			await ready
		mesh_instance_3d.mesh = mesh
@onready var mesh_instance_3d = %MeshInstance3D

func _ready():
	mesh_instance_3d.mesh = mesh
