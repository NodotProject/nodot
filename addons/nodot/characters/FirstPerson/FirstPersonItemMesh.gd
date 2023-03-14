class_name FirstPersonItemMesh extends MeshInstance3D

func _ready():
  var viewport = get_parent().get_parent()
  layers = viewport.camera_cull_mask_layer
