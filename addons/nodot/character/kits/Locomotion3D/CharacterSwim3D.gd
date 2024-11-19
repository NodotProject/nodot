@tool
## Assists with character water submersion controls and effects
class_name CharacterSwim3D extends CharacterExtensionBase3D

## The gravity to apply to the character while submerged
@export var submerged_gravity: float = 0.3
## How slow the character can move while underwater
@export var submerge_speed := 3.0
## How much underwater acceleration is there
@export var submerge_acceleration := 0.04
## The depth to allow before setting the character to swim
@export var submerge_offset := 1.0
## Detect changing water heights (more performance intensive)
@export var water_height_change_detection := false

@export_subgroup("Third Person Controls")
## Turn rate. If strafing is disabled, define how fast the character will turn.
@export var turn_rate: float = 0.1

@export_category("Input Actions")
## The input action name for swimming upwards
@export var ascend_action: String = "submerge_ascend"
## The input action name for swimming downwards
@export var descend_action: String = "submerge_descend"

## Triggered when submerged underwater
signal submerged
## Triggered when out of water
signal surfaced
## Triggered when the head is submerged
signal head_submerged
## Triggered when the head is surfaced
signal head_surfaced

var submerged_water_area: WaterArea3D
var is_submerged: bool = false
var is_head_submerged: bool = false
var water_y_position: float = 0.0
var idle_state_handler: CharacterIdle3D

func setup():
	var action_names = [ascend_action, descend_action]
	var default_keys = [KEY_SPACE, KEY_CTRL]
	for i in action_names.size():
		var action_name = action_names[i]
		InputManager.register_action(action_name, default_keys[i])
		
	var joy_default_keys = [JOY_BUTTON_A, JOY_BUTTON_B]
	for i in action_names.size():
		var action_name = action_names[i]
		InputManager.register_action(action_name, joy_default_keys[i], 2)
		
	idle_state_handler = Nodot.get_first_sibling_of_type(self, CharacterIdle3D)

func enter(_old_state: StateHandler):
	character.override_movement = true
	
func exit(_old_state: StateHandler):
	character.override_movement = false

func can_exit(_new_state: StateHandler):
	return !is_submerged
		
## Handles swimming movement
func physics_process(delta: float) -> void:
	if !is_submerged: return
	if !character.input_enabled: return
	
	check_head_submerged()
	
	var water_movement_enabled: bool = (character.global_position.y + submerge_offset) < water_y_position
	var new_y_velocity = clamp(character.velocity.y - submerged_gravity * delta, -3.0, 3.0)
	character.velocity.y = lerp(character.velocity.y, new_y_velocity, submerge_acceleration)
	var ascend_pressed: bool = Input.is_action_pressed(ascend_action)
	var descend_pressed: bool = Input.is_action_pressed(descend_action)
	if ascend_pressed:
		if is_head_submerged or water_movement_enabled or character.is_on_wall():
			character.velocity.y = lerp(character.velocity.y, submerge_speed, delta)
		else:
			character.velocity.y = lerp(character.velocity.y, -submerge_speed * 2.0, delta)
	elif descend_pressed:
		character.velocity.y = lerp(character.velocity.y, -submerge_speed, delta)
	
	var basis: Basis
	if character.camera:
		basis = character.current_camera.global_transform.basis
	else:
		basis = character.transform.basis
	character.direction3d = (basis * Vector3(character.direction2d.x, 0, character.direction2d.y))
	
	if character.direction3d != Vector3.ZERO:
		var final_speed: float = submerge_speed * 2.0 if character._is_on_floor() else submerge_speed
		character.velocity.x = lerp(character.velocity.x, character.direction3d.x * final_speed, submerge_acceleration)
		character.velocity.z = lerp(character.velocity.z, character.direction3d.z * final_speed, submerge_acceleration)
		
	character.move_and_slide()
	
	if (character.global_position.y + submerge_offset) < water_y_position:
		state_machine.transition(idle_state_handler.name)

## Trigger submerge states
func set_submerged(input_submerged: bool, water_area: WaterArea3D) -> void:
	water_y_position = water_area.water_mesh_instance.global_position.y
	submerged_water_area = water_area
	is_submerged = input_submerged

	if is_submerged:
		state_machine.transition(name)
		submerged.emit()
	else:
		is_head_submerged = false
		submerged_water_area.revert()
		head_surfaced.emit()
		state_machine.transition(idle_state_handler.name)
		surfaced.emit()

## Check if the head (camera) is submerged
func check_head_submerged() -> void:
	var final_water_y_position: float = water_y_position
	
	if water_height_change_detection and submerged_water_area:
		final_water_y_position = submerged_water_area.water_mesh_instance.global_position.y + 0.15
		
	if !is_head_submerged and character.camera.global_position.y < final_water_y_position:
		is_head_submerged = true
		submerged_water_area.invert()
		head_submerged.emit()
	elif is_head_submerged and character.camera.global_position.y >= final_water_y_position:
		is_head_submerged = false
		submerged_water_area.revert()
		head_surfaced.emit()
