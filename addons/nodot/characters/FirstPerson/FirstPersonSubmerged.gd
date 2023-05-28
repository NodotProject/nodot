@tool
## Assists with character water submersion controls and effects
class_name FirstPersonSubmerged extends Nodot

## The gravity to apply to the character while submerged
@export var submerged_gravity: float = 0.3
## How slow the character can move while underwater (higher = slower)
@export var submerge_speed := 2.0

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

@onready var parent: FirstPersonCharacter = get_parent()

var camera: Camera3D
var default_speed: float
var submerged_water_area: WaterArea3D
var is_submerged: bool = false
var is_head_submerged: bool = false
var water_y_position: float = 0.0
var swim_state_id: int
var surfaced_state_id: int

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings


func _init():
	var action_names = [ascend_action, descend_action]
	var default_keys = [KEY_SPACE, KEY_C]
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


func _ready():
	if "camera" in parent:
		camera = parent.camera
		
	var state: StateMachine = parent.sm
	swim_state_id = state.register_state("swim")
	surfaced_state_id = state.register_state("surfaced")
	
	state.add_valid_transition("swim", "surfaced")
	state.add_valid_transition("surfaced", "idle")
	state.add_valid_transition("idle", "swim")
	state.add_valid_transition("jump", "swim")
	state.add_valid_transition("sprint", "swim")
	state.add_valid_transition("crouch", "swim")
	state.add_valid_transition("prone", "swim")


func _physics_process(delta: float) -> void:
	if !is_submerged: return
	check_head_submerged()
	
	parent.velocity.y -= submerged_gravity * delta

	var jump_pressed: bool = Input.is_action_pressed(ascend_action)
	if jump_pressed:
		parent.velocity.y = lerp(parent.velocity.y, submerge_speed, 1.0 * delta)


## Trigger submerge states
func set_submerged(input_submerged: bool, water_area: WaterArea3D) -> void:
	is_submerged = input_submerged
	submerged_water_area = water_area
	water_y_position = water_area.water_mesh_instance.global_position.y

	if is_submerged:
		parent.sm.set_state(swim_state_id)
		emit_signal("submerged")
	else:
		if parent._is_on_floor():
			parent.sm.set_state(surfaced_state_id)
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
