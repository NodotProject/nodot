## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends CharacterBody3D

## Allow player input
@export var input_enabled := true
## The camera field of view
@export var fov := 75.0
## The head position
@export var head_position := Vector3.ZERO

var head: Node3D
var camera: Camera3D

func _enter_tree():
  head = Node3D.new()
  head.name = "Head"
  camera = Camera3D.new()
  camera.name = "Camera3D"
  head.add_child(camera)
  add_child(head)
  
func _ready():
  camera.fov = fov
  
  if has_node("Head"):
    head = get_node("Head")
    camera = get_node("Head/Camera3D")
    
  if has_node("HeadPosition"):
    var head_position_node = get_node("HeadPosition")
    head.position = head_position_node.position
    head_position_node.queue_free()
  else:
    head.position = head_position

func _physics_process(delta):
  move_and_slide()
  
func _input(event):
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
