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

var direction: Vector3 = Vector3.ZERO
var fly_doubletap_timeleft: float = 0.0

func ready():
	setup()
	
func _on_enabled_changed(new_value: bool):
	enabled = new_value
	setup()
	
func setup():
	if !enabled:
		return
		
	InputManager.register_action(left_action, KEY_A)
	InputManager.register_action(right_action, KEY_D)
	InputManager.register_action(up_action, KEY_W)
	InputManager.register_action(down_action, KEY_S)
	InputManager.register_action(descend_action, KEY_CTRL)
	InputManager.register_action(ascend_action, KEY_SPACE)
	
	handled_states = ["idle", "jump", "fly", "land"]

func can_enter() -> bool:
	return ["idle", "jump", "fly", "land"].has(sm.old_state)

func enter() -> void:
	if not is_authority(): return
	
	if sm.state == &"land":
		fly_doubletap_timeleft = 0.0
		sm.set_state(&"idle")

func physics(delta: float) -> void:
	if not is_authority(): return
	
	if fly_doubletap_timeleft > 0.0:
		fly_doubletap_timeleft -= delta
	
	if sm.state == &"idle" or sm.state == &"jump":
		if Input.is_action_just_pressed(ascend_action):
			if fly_doubletap_timeleft > 0.0:
				sm.set_state(&"fly")
			elif fly_doubletap_timeleft <= 0.0:
				fly_doubletap_timeleft = double_tap_time
	else:
		if sm.state == &"fly":
			if land_on_ground and character.was_on_floor:
				sm.set_state(&"land")
				
			if Input.is_action_just_pressed(ascend_action):
				if fly_doubletap_timeleft > 0.0:
					sm.set_state(&"land")
				elif fly_doubletap_timeleft <= 0.0:
					fly_doubletap_timeleft = double_tap_time
					
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
