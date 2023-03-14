class_name FirstPersonItemMesh extends MeshInstance3D

func _ready():
  var camera: Camera3D = find_parent("Camera3D")
  layers = camera.cull_mask
