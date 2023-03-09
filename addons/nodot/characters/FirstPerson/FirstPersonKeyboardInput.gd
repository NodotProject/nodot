@icon("../../../icons/keyboard.svg")
class_name FirstPersonKeyboardInput extends Nodot

## A preconfigured set of inputs for first person keyboard control

@export var enabled = true ## Is input enabled
@export var speed := 5.0 ## How fast the character can move
@export var sprint_speed_multiplier := 3.0 ## How fast the character can move while sprinting
@export var jump_velocity = 4.5 ## How high the character can jump

@onready var parent: FirstPersonCharacterBody3D = get_parent()

func _physics_process(delta):    
  if enabled:
    var final_speed = speed
    
    if parent.is_on_floor():
      # Handle Jump.
      if Input.is_action_just_pressed("jump"):
        parent.velocity.y = jump_velocity
        
      # Handle Sprint.
      if Input.is_action_pressed("sprint"):
        final_speed *= sprint_speed_multiplier        

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
      parent.velocity.x = direction.x * final_speed
      parent.velocity.z = direction.z * final_speed
    else:
      parent.velocity.x = move_toward(parent.velocity.x, 0, final_speed)
      parent.velocity.z = move_toward(parent.velocity.z, 0, final_speed)

## Disable input
func disable():
  enabled = false

## Enable input
func enable():
  enabled = true
