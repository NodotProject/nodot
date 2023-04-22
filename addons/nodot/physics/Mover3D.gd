@tool
## A Node to move other nodes from one place to another (any maybe even back again)
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
@export var destination_position: Vector3
## The destination rotation
@export var destination_rotation: Vector3
## Time until destination
@export var time_to_destination: float = 1.0
## Time until origin
@export var time_to_origin: float = 1.0
## Transition type (https://docs.godotengine.org/en/4.0/classes/class_tween.html)
@export_enum("TRANS_LINEAR", "TRANS_SINE", "TRANS_QUINT", "TRANS_QUART", "TRANS_QUAD", "TRANS_EXPO", "TRANS_ELASTIC", "TRANS_CUBIC", "TRANS_CIRC", "TRANS_BOUNCE", "TRANS_BACK") var transition_type: int = 0

@onready var original_position = target_node.position
@onready var original_rotation = target_node.rotation

var activated = false

func _ready():
  if auto_start:
    action()

## Perform the move toggling between destination and origin
func action():
  activated = !activated
  if activated:
    move_to_destination()
  else:
    move_to_origin()

## Perform the move but only towards the destination
func activate():
  move_to_destination()

## Perform the move but only towards the origin
func deactivate():
  move_to_origin()
  
func move_to_destination():
  activated = true
  var destination_tween = _create_tween(_on_destination_reached)
  var destination_rotation_radians = Vector3(deg_to_rad(destination_rotation.x), deg_to_rad(destination_rotation.y), deg_to_rad(destination_rotation.z))
  if destination_position:
    destination_tween.parallel().tween_property(target_node, "position", destination_position, time_to_destination).set_trans(transition_type)
  destination_tween.parallel().tween_property(target_node, "rotation", destination_rotation_radians, time_to_destination).set_trans(transition_type)
  destination_tween.play()
  emit_signal("moving_to_destination")
  emit_signal("movement_started")
  
func move_to_origin():
  activated = false
  var origin_tween = _create_tween(_on_origin_reached)
  if original_position:
    origin_tween.parallel().tween_property(target_node, "position", original_position, time_to_origin).set_trans(transition_type)
  origin_tween.parallel().tween_property(target_node, "rotation", original_rotation, time_to_origin).set_trans(transition_type)
  origin_tween.play()
  emit_signal("moving_to_origin")
  emit_signal("movement_started")
  
func _create_tween(callback: Callable) -> Tween:
  var tween = get_tree().create_tween()
  tween.connect("finished", callback)
  return tween

func _on_destination_reached():
  emit_signal("destination_reached")
  emit_signal("movement_ended")
  
func _on_origin_reached():
  emit_signal("origin_reached")
  emit_signal("movement_ended")
    
