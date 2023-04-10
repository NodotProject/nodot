## A Node to move other nodes from one place to another (any maybe even back again)
@tool
class_name Mover3D extends Nodot3D

## Destination position/rotation has been reached
signal destination_reached
## Original position/rotation has been reached
signal origin_reached
## Started moving towards the destination
signal moving_to_destination
## Started moving towards the origin
signal moving_to_origin
## Movement towards any target position/rotation has started
signal movement_started
## Movement towards any target position/rotation has completed
signal movement_ended

## The node to move
@export var target_node: Node
## Only move once
@export var one_shot: bool = false
## Automatically start movement
@export var auto_start: bool = false
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

func _ready():
  if auto_start:
    action()

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
      if !target_reached and target_node.position.is_equal_approx(destination_position) and target_node.rotation.is_equal_approx(destination_rotation_radians):
        target_reached = true
        emit_signal("destination_reached")
        emit_signal("movement_ended")
    elif !one_shot:
      if destination_position:
        target_node.position = lerp(target_node.position, original_position, speed)
      if destination_rotation:
        target_node.rotation = lerp(target_node.rotation, original_rotation, speed)
      if !target_reached and target_node.position.is_equal_approx(original_position) and target_node.rotation.is_equal_approx(original_rotation):
        target_reached = true
        emit_signal("origin_reached")
        emit_signal("movement_ended")

func action():
  target_reached = false
  activated = !activated
  if activated:
    emit_signal("moving_to_destination")
  else:
    emit_signal("moving_to_origin")
  emit_signal("movement_started")

func activate():
  if !activated:
    emit_signal("moving_to_destination")
    emit_signal("movement_started")
  activated = true

func deactivate():
  if activated:
    emit_signal("moving_to_origin")
    emit_signal("movement_started")
  activated = false
