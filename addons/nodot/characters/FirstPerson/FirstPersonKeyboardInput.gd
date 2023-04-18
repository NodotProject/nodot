@tool
@icon("../../icons/keyboard.svg")
## A preconfigured set of inputs for first person keyboard control
class_name FirstPersonKeyboardInput extends Nodot

@export var left_action : String = "left"
@export var right_action : String = "right"
@export var up_action : String = "up"
@export var down_action : String = "down"
@export var reload_action : String = "reload"
@export var jump_action : String = "jump"
@export var sprint_action : String = "sprint"

## Is input enabled
@export var enabled := true
## Only allow WASD movement
@export var direction_movement_only := false
## How fast the character can move
@export var speed := 5.0
## How fast the character can move while sprinting (higher = faster)
@export var sprint_speed_multiplier := 3.0
## How high the character can jump
@export var jump_velocity := 4.5

@onready var parent: FirstPersonCharacter = get_parent()
@onready var fps_viewport: FirstPersonViewport

var is_editor: bool = Engine.is_editor_hint()
var is_jumping: bool = false
var accelerated_jump: bool = false

func _get_configuration_warnings() -> PackedStringArray:
  var warnings: PackedStringArray = []
  if !(get_parent() is FirstPersonCharacter):
    warnings.append("Parent should be a FirstPersonCharacter")
  return warnings

func _init():
  var action_names = [left_action, right_action, up_action, down_action, reload_action, jump_action, sprint_action, "escape"]
  var default_keys = [KEY_A, KEY_D, KEY_W, KEY_S, KEY_R, KEY_SPACE, KEY_SHIFT, KEY_ESCAPE]
  for i in action_names.size():
    var action_name = action_names[i]
    if not InputMap.has_action(action_name):
      var default_key = default_keys[i]
      add_action_to_input_map(action_name, default_key)

func add_action_to_input_map(action_name, default_key):
  var input_key = InputEventKey.new()
  input_key.keycode = default_key
  InputMap.add_action(action_name)
  InputMap.action_add_event(action_name, input_key)

func _ready() -> void:
  # If there is a viewport, set it
  for child in parent.get_children():
    if child is FirstPersonViewport:
      fps_viewport = child

func _input(event: InputEvent) -> void:
  if fps_viewport and event.is_action_pressed("reload"):
    fps_viewport.reload()

func _physics_process(delta: float) -> void:
  if enabled and !is_editor:
    var final_speed: float = speed
    
    if !direction_movement_only and parent.is_on_floor():
      var jump_pressed: bool = Input.is_action_just_pressed(jump_action)
      var sprint_pressed: bool = Input.is_action_pressed(sprint_action)

      # Handle Jump.
      if jump_pressed:
        parent.velocity.y = jump_velocity

      # Handle Sprint.
      if sprint_pressed:
        final_speed *= sprint_speed_multiplier

      # Handle a sprint jump
      if sprint_pressed and jump_pressed:
        accelerated_jump = true

      if !sprint_pressed:
        accelerated_jump = false

    elif accelerated_jump:
      final_speed *= sprint_speed_multiplier

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
    var direction = (parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
      parent.velocity.x = direction.x * final_speed
      parent.velocity.z = direction.z * final_speed
    else:
      parent.velocity.x = move_toward(parent.velocity.x, 0, final_speed)
      parent.velocity.z = move_toward(parent.velocity.z, 0, final_speed)

## Disable input
func disable() -> void:
  enabled = false

## Enable input
func enable() -> void:
  enabled = true
