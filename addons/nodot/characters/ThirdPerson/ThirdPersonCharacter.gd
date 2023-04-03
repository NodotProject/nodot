## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends CharacterBody3D

## The input action to pause input
@export var escape_action : String = "escape"
## Allow player input
@export var input_enabled: bool = true

var camera: ThirdPersonCamera
  
func _physics_process(delta: float) -> void:
  move_and_slide()

func _enter_tree() -> void:
  # Set up camera container
  for child in get_children():
    if child is ThirdPersonCamera:
      var node3d = Node3D.new()
      node3d.name = "ThirdPersonCameraContainer"
      add_child(node3d)
      child.reparent(node3d, true)
      camera = child

func _input(event: InputEvent) -> void:
  if event.is_action_pressed(escape_action):
    if input_enabled:
      disable_input()
      input_enabled = false
    else:
      enable_input()
      input_enabled = true

## Disable player input
func disable_input() -> void:
  if has_node("FirstPersonKeyboardInput"):
    get_node("FirstPersonKeyboardInput").disable()
  if has_node("FirstPersonMouseInput"):
    get_node("FirstPersonMouseInput").disable()

## Enable player input
func enable_input() -> void:
  if has_node("FirstPersonKeyboardInput"):
    get_node("FirstPersonKeyboardInput").enable()
  if has_node("FirstPersonMouseInput"):
    get_node("FirstPersonMouseInput").enable()
