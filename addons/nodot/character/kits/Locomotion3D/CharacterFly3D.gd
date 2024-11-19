## A node to manage Flying movement of a NodotCharacter3D
class_name CharacterFly3D extends CharacterExtensionBase3D

## The new movement speed
@export var movement_speed: float = 5.0
## Effects how fast it takes to reach the movement speed
@export var acceleration: float = 10.0
## Stop flying when the character is on the ground
@export var land_on_ground: bool = true
## Double tap sensitivity for enabling/disabling fly mode
@export var double_tap_time: float = 0.3

@export_subgroup("Input Actions")
## The input action name for strafing left
@export var left_action: String = "left"
## The input action name for strafing right
@export var right_action: String = "right"
## The input action name for moving forward
@export var up_action: String = "up"
## The input action name for moving backwards
@export var down_action: String = "down"
## The input action name for descending
@export var descend_action: String = "crouch"
## The input action name for ascending
@export var ascend_action: String = "jump"

var idle_state_handler: CharacterIdle3D
var direction: Vector3 = Vector3.ZERO
var fly_doubletap_timeleft: float = 0.0
	
func setup():
	InputManager.register_action(left_action, KEY_A)
	InputManager.register_action(right_action, KEY_D)
	InputManager.register_action(up_action, KEY_W)
	InputManager.register_action(down_action, KEY_S)
	InputManager.register_action(descend_action, KEY_CTRL)
	InputManager.register_action(ascend_action, KEY_SPACE)
	idle_state_handler = Nodot.get_first_sibling_of_type(self, CharacterIdle3D)

func enter(_old_state: StateHandler):
	character.override_movement = true
	
func exit(_old_state: StateHandler):
	character.override_movement = false
	fly_doubletap_timeleft = 0.0
	
func _physics_process(delta: float) -> void:
	if fly_doubletap_timeleft > 0.0:
		fly_doubletap_timeleft -= delta
		
	if Input.is_action_just_pressed(ascend_action):
		if fly_doubletap_timeleft > 0.0:
			if state_machine.state == name:
				state_machine.transition(idle_state_handler.name)
			else:
				state_machine.transition(name)
		elif fly_doubletap_timeleft <= 0.0:
			fly_doubletap_timeleft = double_tap_time

func physics_process(delta: float) -> void:
	if land_on_ground and character.was_on_floor:
		state_machine.transition(idle_state_handler.name)
			
	var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
	var basis: Basis
	if third_person_camera:
		basis = character.current_camera.global_transform.basis
	else:
		basis = character.transform.basis
	direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed(descend_action):
		direction.y = -1.0
	if Input.is_action_pressed(ascend_action):
		direction.y = 1.0
	
	if direction == Vector3.ZERO:
		character.velocity = lerp(character.velocity, Vector3.ZERO, acceleration * delta)
	else:
		character.velocity.x = lerp(character.velocity.x, direction.x * movement_speed, acceleration * delta)
		character.velocity.y = lerp(character.velocity.y, direction.y * movement_speed, acceleration * delta)
		character.velocity.z = lerp(character.velocity.z, direction.z * movement_speed, acceleration * delta)
	
	character.move_and_slide()
