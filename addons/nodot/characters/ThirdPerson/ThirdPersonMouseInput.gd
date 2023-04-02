@tool
@icon("../../icons/mouse.svg")
class_name ThirdPersonMouseInput extends Nodot

## Input action for enabling camera rotation
@export var camera_rotate_action : String = "camera_rotate"

## Is input enabled
@export var enabled := true
## Sensitivity of mouse movement
@export var mouse_sensitivity := 0.1
## Disable camera movement while camera_rotate_action input action is not pressed
@export var lock_camera_rotation := false

@onready var parent: ThirdPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var mouse_rotation: Vector2 = Vector2.ZERO
var camera: ThirdPersonCamera

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is ThirdPersonCharacter):
    warnings.append("Parent should be a ThirdPersonCharacter")
  return warnings

func _ready() -> void:
  enable()
  camera = parent.camera

func _input(event: InputEvent) -> void:
  if enabled:
    if event is InputEventMouseMotion:
      mouse_rotation.y = event.relative.x * mouse_sensitivity
      mouse_rotation.x = event.relative.y * mouse_sensitivity

func _physics_process(delta: float) -> void:
  if enabled and !is_editor and Input.is_action_pressed("camera_rotate"):
    var look_angle: Vector2 = Vector2(-mouse_rotation.x * delta, -mouse_rotation.y * delta)

    # Handle look left and right
    parent.rotate_object_local(Vector3(0, 1, 0), look_angle.y)

    # Handle look up and down
    camera.rotate_object_local(Vector3(1, 0, 0), look_angle.x)

    camera.rotation.x = clamp(camera.rotation.x, -1.36, 1.4)
    mouse_rotation = Vector2.ZERO

## Disable input and release mouse
func disable() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  enabled = false

## Enable input and capture mouse
func enable() -> void:
  if !Engine.is_editor_hint():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  enabled = true
