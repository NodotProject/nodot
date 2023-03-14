class_name FirstPersonItem extends Nodot3D

## An item used in first person games. i.e sword, gun, hands.

@export var active = false ## If the weapon is visible or not
@export var mesh: Mesh ## (optional) The mesh of the weapon

func _enter_tree():
  if mesh:
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    add_child(mesh_instance)
  
  visible = active

## Async function to activate the weapon. i.e animate it onto the screen. 
func activate():
  active = true
  visible = true

## Async function to deactivate the weapon. i.e animate it off of the screen.
func deactivate():
  active = false
  visible = false
