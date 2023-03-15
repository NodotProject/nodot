@tool
@icon("../../icons/first_person_item.svg")
class_name FirstPersonItem extends Nodot3D

## An item used in first person games. i.e sword, gun, hands.

## If the weapon is visible or not
@export var active = false
## (optional) The mesh of the weapon
@export var mesh: Mesh

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is FirstPersonViewport):
    warnings.append("Parent should be a FirstPersonViewport")
  return warnings

func _ready():
  if mesh:
    var camera_cull_mask_layer: int = get_parent().camera_cull_mask_layer
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.layers = camera_cull_mask_layer
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

func action():
  print("fire")
  
func zoom():
  print("zoom")
