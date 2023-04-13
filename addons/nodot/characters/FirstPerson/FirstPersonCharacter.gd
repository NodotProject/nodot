## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends CharacterBody3D

@export var escape_action : String = "escape"
## Allow player input
@export var input_enabled := true
## The camera field of view
@export var fov := 75.0
## The head position
@export var head_position := Vector3.ZERO

## Triggered when submerged underwater
signal submerged
## Triggered when out of water
signal surfaced
## Triggered when the head is submerged
signal head_submerged
## Triggered when the head is surfaced
signal head_surfaced

var head: Node3D
var camera: Camera3D
var is_submerged: bool = false
var is_head_submerged: bool = false
var water_y_position: float = 0.0

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
  if is_submerged: check_head_submerged()
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
  for child in get_children():
    if child is FirstPersonKeyboardInput: child.disable()
    if child is FirstPersonMouseInput: child.disable()

## Enable player input
func enable_input() -> void:
  for child in get_children():
    if child is FirstPersonKeyboardInput: child.enable()
    if child is FirstPersonMouseInput: child.enable()

## Trigger submerge states
func set_submerged(input_submerged: bool = false, input_water_y_position: float = 0.0):
  is_submerged = input_submerged
  water_y_position = input_water_y_position
  
  if is_submerged:
    emit_signal("submerged")
  else:
    emit_signal("surfaced")

## Check if the head is submerged
func check_head_submerged():
  if !is_head_submerged and camera.global_position.y < water_y_position:
    is_head_submerged = true
    emit_signal("head_submerged")
  elif is_head_submerged and camera.global_position.y >= water_y_position:
    is_head_submerged = false
    emit_signal("head_surfaced")
    
  
