@tool
@icon("../../icons/mouse.svg")
class_name FirstPersonMouseInput extends Nodot

## A preconfigured set of inputs for first person mouse control

@export var item_next_action : String = "item_next"
@export var item_previous_action : String = "item_previous"
@export var action_action : String = "action"
@export var zoom_action : String = "zoom"

## Is input enabled
@export var enabled := true
## Sensitivity of mouse movement
@export var mouse_sensitivity := 0.1

@onready var parent: FirstPersonCharacter = get_parent()
@onready var fps_viewport: FirstPersonViewport

var head: Node3D
var is_editor: bool = Engine.is_editor_hint()
var mouse_rotation: Vector2 = Vector2.ZERO

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is FirstPersonCharacter):
    warnings.append("Parent should be a FirstPersonCharacter")
  return warnings

func _ready() -> void:
  enable()

  # If there is a viewport, set it
  for child in parent.get_children():
    if child is FirstPersonViewport:
      fps_viewport = child

  if parent.has_node("Head"):
    head = parent.get_node("Head")

func _input(event: InputEvent) -> void:
  if enabled:
    if event is InputEventMouseMotion:
      mouse_rotation.y = event.relative.x * mouse_sensitivity
      mouse_rotation.x = event.relative.y * mouse_sensitivity

    if fps_viewport:
      if event.is_action_pressed(item_next_action):
        fps_viewport.next_item()
      elif event.is_action_pressed(item_previous_action):
        fps_viewport.previous_item()

func _physics_process(delta: float) -> void:
  if enabled and !is_editor:
    var look_angle: Vector2 = Vector2(-mouse_rotation.x * delta, -mouse_rotation.y * delta)

    # Handle look left and right
    parent.rotate_object_local(Vector3(0, 1, 0), look_angle.y)

    # Handle look up and down
    head.rotate_object_local(Vector3(1, 0, 0), look_angle.x)

    head.rotation.x = clamp(head.rotation.x, -1.36, 1.4)
    head.rotation.z = 0
    head.rotation.y = 0
    mouse_rotation = Vector2.ZERO

    if fps_viewport:
      if Input.is_action_pressed(action_action):
        fps_viewport.action()
      elif Input.is_action_just_pressed(zoom_action):
        fps_viewport.zoom()
      elif Input.is_action_just_released(zoom_action):
        fps_viewport.zoomout()

## Disable input and release mouse
func disable() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  enabled = false

## Enable input and capture mouse
func enable() -> void:
  if !Engine.is_editor_hint():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  enabled = true
