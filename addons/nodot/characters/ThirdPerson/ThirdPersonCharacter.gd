## A CharacterBody3D for third person games
class_name ThirdPersonCharacter extends CharacterBody3D

## The input action to pause input
@export var escape_action : String = "escape"
## Allow player input
@export var input_enabled := true

var camera: ThirdPersonCamera

func _enter_tree() -> void:
  camera = ThirdPersonCamera.new()
  camera.name = "ThirdPersonCamera"
  add_child(camera)
  
func _physics_process(delta: float) -> void:
  move_and_slide()

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("escape"):
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
