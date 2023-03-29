class_name FirstPersonCharacter extends CharacterBody3D

## A CharacterBody3D for first person games
##
## This CharacterBody3D creates a head and camera node.

@export var input_enabled : bool = true ## Allow player input
@export var fov : float = 75.0 ## The camera field of view
@export var head_position : Vector3 = Vector3.ZERO ## The head position

var head: Node3D
var camera: Camera3D

func _enter_tree() -> void:
  head = Node3D.new()
  head.name = "Head"
  camera = Camera3D.new()
  camera.name = "Camera3D"
  head.add_child(camera)
  add_child(head)

func _ready() -> void:
  camera.fov = fov

  if has_node("Head"):
    head = get_node("Head")
    camera = get_node("Head/Camera3D")

  if has_node("HeadPosition"):
    var head_position_node: Node = get_node("HeadPosition")
    head.position = head_position_node.position
    head_position_node.queue_free()
  else:
    head.position = head_position

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
