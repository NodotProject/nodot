@tool
## Assists with character water submersion controls and effects
class_name CharacterSwim3D extends CharacterExtensionBase3D

## The gravity to apply to the character while submerged
@export var submerged_gravity: float = 0.3
## How slow the character can move while underwater
@export var submerge_speed := 1.0
## The depth to allow before setting the character to swim
@export var submerge_offset := 1.0

@export_subgroup("Third Person Controls")
## Turn rate. If strafing is disabled, define how fast the character will turn.
@export var turn_rate: float = 0.1

@export_category("Input Actions")
## The input action name for strafing left
@export var left_action: String = "left"
## The input action name for strafing right
@export var right_action: String = "right"
## The input action name for moving forward
@export var up_action: String = "up"
## The input action name for moving backwards
@export var down_action: String = "down"
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

var direction: Vector3 = Vector3.ZERO
var camera: Camera3D
var default_speed: float
var submerged_water_area: WaterArea3D
var is_submerged: bool = false
var is_head_submerged: bool = false
var water_y_position: float = 0.0
var third_person_camera_container: Node3D

var swim_idle_state_id: int
var swim_state_id: int
var surfaced_state_id: int

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is NodotCharacter3D):
		warnings.append("Parent should be a NodotCharacter3D")
	return warnings


func _init():
	var action_names = [ascend_action, descend_action]
	var default_keys = [KEY_SPACE, KEY_C]
	for i in action_names.size():
		var action_name = action_names[i]
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			InputManager.add_action_event_key(action_name, default_keys[i])


func ready():
	if "camera" in character:
		camera = character.camera
		
	
	register_handled_states(["swim_idle", "swim", "surfaced"])
	
	swim_idle_state_id = sm.get_id_from_name("swim_idle")
	swim_state_id = sm.get_id_from_name("swim")
	surfaced_state_id = sm.get_id_from_name("idle")
	
	sm.add_valid_transition("swim_idle", ["swim", "idle"])
	sm.add_valid_transition("swim", ["swim_idle", "idle"])
	sm.add_valid_transition("idle", "swim_idle")
	sm.add_valid_transition("walk", "swim_idle")
	sm.add_valid_transition("jump", "swim_idle")
	sm.add_valid_transition("sprint", "swim_idle")
	sm.add_valid_transition("crouch", "swim_idle")
	sm.add_valid_transition("prone", "swim_idle")
	
	if third_person_camera:
		third_person_camera_container = third_person_camera.get_parent()


func physics(delta: float) -> void:
	if !is_submerged: return
	check_head_submerged()
	
	var character_offset_position = character.global_position.y + submerge_offset
	
	if sm.state == swim_state_id or sm.state == swim_idle_state_id:
		swim(delta)
		if character_offset_position > water_y_position:
			sm.set_state(surfaced_state_id)
	elif character_offset_position < water_y_position:
		sm.set_state(swim_idle_state_id)
		
## Handles swimming movement
func swim(delta: float) -> void:
	if !character.input_enabled:
		return
		
	var input_dir = Input.get_vector(left_action, right_action, up_action, down_action)
	var basis: Basis
	if third_person_camera:
		basis = third_person_camera.global_transform.basis
	else:
		basis = character.transform.basis
	direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		sm.set_state(swim_state_id)
	else:
		sm.set_state(swim_idle_state_id)
		
	character.velocity.y -= submerged_gravity * delta
	var jump_pressed: bool = Input.is_action_pressed(ascend_action)
	if jump_pressed:
		character.velocity.y = lerp(character.velocity.y, submerge_speed, delta)
	
	if direction == Vector3.ZERO:
		character.velocity.x = move_toward(character.velocity.x, 0, 0.1)
		character.velocity.z = move_toward(character.velocity.z, 0, 0.1)
	else:
		character.velocity.x = lerp(character.velocity.x, direction.x * submerge_speed, 0.025)
		character.velocity.z = lerp(character.velocity.z, direction.z * submerge_speed, 0.025)
		
		if third_person_camera:
			var cached_rotation = third_person_camera_container.global_rotation
			face_target(character.position + direction, turn_rate)
			third_person_camera_container.global_rotation = cached_rotation
		
	character.move_and_slide()

## Trigger submerge states
func set_submerged(input_submerged: bool, water_area: WaterArea3D) -> void:
	water_y_position = water_area.water_mesh_instance.global_position.y
	submerged_water_area = water_area
	is_submerged = input_submerged

	if is_submerged:
		emit_signal("submerged")
	else:
		emit_signal("surfaced")


## Check if the head (camera) is submerged
func check_head_submerged() -> void:
	if !is_head_submerged and camera.global_position.y < water_y_position:
		is_head_submerged = true
		submerged_water_area.water_mesh_instance.mesh.flip_faces = true
		emit_signal("head_submerged")
	elif is_head_submerged and camera.global_position.y >= water_y_position:
		is_head_submerged = false
		submerged_water_area.water_mesh_instance.mesh.flip_faces = false
		emit_signal("head_surfaced")
