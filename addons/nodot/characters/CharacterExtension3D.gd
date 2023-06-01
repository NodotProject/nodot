# A base node to add extension logic to NodotCharacter3D
class_name CharacterExtensionBase3D extends Nodot

## Enable/disable this node.
@export var enabled : bool = true
## The NodotCharacter3D to apply this node to
@export var character: NodotCharacter3D
## Run action even when the state is unhandled
@export var action_unhandled_states: bool = false

var is_editor: bool = Engine.is_editor_hint()
var sm: StateMachine
var handled_states: Array[String] = []
var state_ids: Dictionary = {}
var direction: Vector3 = Vector3.ZERO
var third_person_camera: ThirdPersonCamera

func _enter_tree():
	if not character:
		var parent = get_parent()
		if parent is NodotCharacter3D:
			character = parent
		else:
			enabled = false
			return
			
	if character.camera is ThirdPersonCamera:
		third_person_camera = character.camera
	
	sm = character.sm
	sm.connect("state_updated", state_updated)
	
func _physics_process(delta):
	if is_editor or !enabled or !sm or sm.state < 0 or (!action_unhandled_states and !handles_state(sm.state)):
		return
		
	action(delta)
	
func _input(event: InputEvent) -> void:
	if !InputManager.enabled:
		return
		
	input(event)

## Registers a set of states that the node handles
func register_handled_states(new_states: Array[String]):
	for state_name in new_states:
		var state_id = sm.register_state(state_name)
		state_ids[state_name] = state_id
		handled_states.append(state_name)

## Checks whether this node handles a certain state
func handles_state(state: Variant) -> bool:
	if state is String:
		return handled_states.has(state)
	if state is int:
		return state_ids.values().has(state)
	return false

## Turn to face the target. Essentially lerping look_at
func face_target(target_position: Vector3, weight: float) -> void:
	# First look directly at the target
	var initial_rotation = character.rotation
	character.look_at(target_position)
	character.rotation.x = initial_rotation.x
	character.rotation.z = initial_rotation.z
	# Then lerp the next rotation
	var target_rot = character.rotation
	character.rotation.y = lerp_angle(initial_rotation.y, target_rot.y, weight)
	
## Extend this placeholder. This is where your logic will be run every physics frame.
func action(delta: float) -> void:
	pass

## Extend this placeholder. This is where your logic will be run for every input.
func input(event: InputEvent) -> void:
	pass
	
## Extend this placeholder. This is triggered whenever the character state is updated.
func state_updated(old_state: int, new_state: int) -> void:
	pass
