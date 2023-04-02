@tool
@icon("../../icons/keyboard.svg")
class_name ThirdPersonKeyboardInput extends Nodot

## A preconfigured set of inputs for third person keyboard control

@export var left_action : String = "left"
@export var right_action : String = "right"
@export var up_action : String = "up"
@export var down_action : String = "down"
@export var jump_action : String = "jump"

## Is input enabled
@export var enabled = true
## How fast the character can move
@export var speed := 5.0
## How high the character can jump
@export var jump_velocity = 4.5
## Instead of turning the character, the character will strafe on left and right input action
@export var strafing := false

@onready var parent: ThirdPersonCharacter = get_parent()

var is_jumping: bool = false
var is_editor: bool = Engine.is_editor_hint()
var camera: ThirdPersonCamera

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is ThirdPersonCharacter):
    warnings.append("Parent should be a ThirdPersonCharacter")
  return warnings
  
func _ready():
  camera = parent.camera

func _physics_process(delta: float) -> void:
  if enabled and !is_editor:

    if parent.is_on_floor():
      var jump_pressed: bool = Input.is_action_just_pressed("jump")
      var sprint_pressed: bool = Input.is_action_pressed("sprint")

      # Handle Jump.
      if jump_pressed:
        parent.velocity.y = jump_velocity

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
    var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
      parent.velocity.x = direction.x * speed
      parent.velocity.z = direction.z * speed
    else:
      parent.velocity.x = move_toward(parent.velocity.x, 0, speed)
      parent.velocity.z = move_toward(parent.velocity.z, 0, speed)

## Disable input
func disable() -> void:
  enabled = false

## Enable input
func enable() -> void:
  enabled = true
