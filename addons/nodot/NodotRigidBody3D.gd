class_name NodotRigidBody3D extends RigidBody3D

func focussed() -> void:
  for child in get_children():
    if child.has_method("focussed"):
      child.focussed()
      
func unfocussed() -> void:
  for child in get_children():
    if child.has_method("unfocussed"):
      child.unfocussed()
