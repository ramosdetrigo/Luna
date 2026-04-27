class_name CardCube
extends SubViewportContainer

@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mesh_instance_3d.rotate_y(delta * deg_to_rad(60.0))
