## A Node to move other nodes from one place to another (any maybe even back again)
@tool
class_name Mover3D extends Nodot3D

signal destination_reached
signal origin_reached
signal moving_to_destination
signal moving_to_origin

## The node to move
@export var target_node: Node
## Only move once
@export var one_shot: bool = false
## The destination position
@export var destination_position = Vector3.ZERO
## The destination rotation
@export var destination_rotation = Vector3.ZERO
## Movement speed
@export var movement_speed: float = 10.0

@onready var original_position = target_node.position
@onready var original_rotation = target_node.rotation
var activated = false
var target_reached = true

func _physics_process(delta: float):
  if target_node:
    var speed = movement_speed * delta
    var destination_rotation_radians = Vector3(deg_to_rad(destination_rotation.x), deg_to_rad(destination_rotation.y), deg_to_rad(destination_rotation.z))
    if activated:
      if destination_position:
        ## TODO: Add a linear motion option
        target_node.position = lerp(target_node.position, destination_position, speed)
      if destination_rotation:
        target_node.rotation = lerp(target_node.rotation, destination_rotation_radians, speed)
      if !target_reached and target_node.position == destination_position and target_node.rotation == destination_rotation_radians:
        emit_signal("destination_reached")
        target_reached = true
    elif !one_shot:
      if destination_position:
        target_node.position = lerp(target_node.position, original_position, speed)
      if destination_rotation:
        target_node.rotation = lerp(target_node.rotation, original_rotation, speed)
      if !target_reached and target_node.position == original_position and target_node.rotation == original_rotation:
        emit_signal("origin_reached")
        target_reached = true

func action():
  target_reached = false
  activated = !activated
  if activated:
    emit_signal("moving_to_destination")
  else:
    emit_signal("moving_to_origin")

func activate():
  if !activated: emit_signal("moving_to_destination")
  activated = true

func deactivate():
  if activated: emit_signal("moving_to_origin")
  activated = false
