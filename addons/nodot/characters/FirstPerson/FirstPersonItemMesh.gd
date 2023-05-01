@tool
class_name FirstPersonItemMesh extends MeshInstance3D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonItem):
		warnings.append("Parent should be a FirstPersonItem")
	return warnings


func _ready() -> void:
	var viewport: FirstPersonViewport = get_parent().get_parent()
	layers = viewport.camera_cull_mask_layer
