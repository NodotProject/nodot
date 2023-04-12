@tool
## A node to position a weapon down the line of sight
class_name FirstPersonIronSight extends Nodot3D

## Whether ironsight zoom is allowed
@export var enabled : bool = true
## The speed to move the camera to the ironsight location
@export var zoom_speed : float = 10.0
## The ironsight field of view
@export var fov : float = 75.0
## Whether to enable a scope view after ironsight zoom is complete
@export var enable_scope : bool = false
## The scope texture that will cover the screen
@export var scope_texture: Texture2D
## The scope field of view
@export var scope_fov : float = 45.0

@onready var parent: FirstPersonItem = get_parent()

var initial_position : Vector3 = Vector3.INF
var ironsight_target : Vector3 = Vector3.INF
var viewport_camera: Camera3D

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is FirstPersonItem):
    warnings.append("Parent should be a FirstPersonItem")
  return warnings

func _ready() -> void:
  viewport_camera = parent.get_parent().viewport_camera

func _physics_process(delta: float) -> void:
  if ironsight_target == Vector3.INF:
    if initial_position != Vector3.INF:
      parent.position = lerp(parent.position, initial_position, zoom_speed * delta)
  else:
    parent.position = lerp(parent.position, ironsight_target, zoom_speed * delta)

## Initiates the ironsight zoom and shows scope when it approximately reaches its destination
func zoom() -> void:
  if initial_position == Vector3.INF:
    initial_position = parent.position
  ironsight_target = Vector3.ZERO - position
  if parent.crosshair_node:
    parent.crosshair_node.visible = false
  if enable_scope and parent.position.is_equal_approx(ironsight_target):
    scope()

## Initiates ironsight zoom out
func zoomout() -> void:
  ironsight_target = Vector3.INF
  if parent.crosshair_node:
    parent.crosshair_node.visible = true
  if enable_scope:
    unscope()

## Show the scope image and set the field of view
func scope() -> void:
  # TODO: show scope image
  viewport_camera.fov = scope_fov

## Hide the scope image and reset the field of view
func unscope() -> void:
  # TODO: hide scope image
  viewport_camera.fov = fov

## Restores all states to default
func deactivate() -> void:
  if initial_position != Vector3.INF:
    parent.position = initial_position
  zoomout()
