@tool
@icon("../../icons/first_person_item.svg")
class_name FirstPersonItem extends Nodot3D

## An item used in first person games. i.e sword, gun, hands.

## If the weapon is visible or not
@export var active = false
## (optional) The mesh of the weapon
@export var mesh: Mesh

var ironsight_node: FirstPersonIronSight
var magazine_node: Magazine
var hitscan_node: HitScan3D
var bullethole_node: BulletHole

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is FirstPersonViewport):
    warnings.append("Parent should be a FirstPersonViewport")
  return warnings

func _ready():
  for child in get_children():
    if child is FirstPersonIronSight:
      ironsight_node = child
    if child is Magazine:
      magazine_node = child
    if child is HitScan3D:
      hitscan_node = child
  
  connect_magazine()
  
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

## Triggered when the item is fired (i.e on left click to fire weapon)
func action():
  if magazine_node:
    magazine_node.action()

## Triggered when the zoom/ironsight button is pressed
func zoom():
  if ironsight_node: ironsight_node.zoom()

## Triggered when the zoom/ironsight button is released
func zoomout():
  if ironsight_node: ironsight_node.zoomout()

## Connect the magazine events to the hitscan node
func connect_magazine():
  if magazine_node and hitscan_node:
    magazine_node.connect("dispatched", hitscan_node.action)
  if hitscan_node and bullethole_node:
    hitscan_node.connect("target_hit", bullethole_node.action)
