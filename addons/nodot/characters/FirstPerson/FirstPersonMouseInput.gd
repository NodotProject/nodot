@icon("../../../icons/mouse.svg")
class_name FirstPersonMouseInput extends Nodot

## A preconfigured set of inputs for first person mouse control

@export var enabled := true ## Is input enabled
@export var mouse_sensitivity := 0.1 ## Sensitivity of mouse movement

@onready var parent: FirstPersonCharacterBody3D = get_parent()
@onready var head: Node3D = parent.get_node("Head")

var mouse_rotation = Vector2.ZERO

func _ready():
  enable()

func _input(event):
  if enabled:
    if event is InputEventMouseMotion:
      mouse_rotation.y = event.relative.x * mouse_sensitivity
      mouse_rotation.x = event.relative.y * mouse_sensitivity

func _physics_process(delta):
  if enabled:
    var look_angle = Vector2(-mouse_rotation.x * delta, -mouse_rotation.y * delta)
    
    # Handle look left and right
    parent.rotate_object_local(Vector3(0, 1, 0), look_angle.y)
    
    # Handle look up and down
    head.rotate_object_local(Vector3(1, 0, 0), look_angle.x)
    
    head.rotation.x = clamp(head.rotation.x, -1.36, 1.4)
    head.rotation.z = 0
    head.rotation.y = 0
    mouse_rotation = Vector2.ZERO

## Disable input and release mouse
func disable():
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  enabled = false

## Enable input and capture mouse
func enable():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  enabled = true
