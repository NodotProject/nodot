@icon("../../icons/mouse.svg")
## A preconfigured set of inputs for first person joypad control
class_name FirstPersonJoypadInput extends Nodot

## Is input enabled
@export var enabled := true
## Sensitivity of joystick movement
@export var look_sensitivity := 1.0
## The FirstPersonItemsContainer for the first person character
@export var fps_item_container: FirstPersonItemsContainer

@export_category("Input Actions")
## The input action name for selecting the next item
@export var item_next_action: String = "item_next"
## The input action name for selecting the previous item
@export var item_previous_action: String = "item_previous"
## The input action name for performing an action
@export var action_action: String = "action"
## The input action name for zooming in
@export var zoom_action: String = "zoom"
## The input action name for strafing left
@export var left_action: String = "left"
## The input action name for strafing right
@export var right_action: String = "right"
## The input action name for walking forward
@export var up_action: String = "up"
## The input action name for walking backwards
@export var down_action: String = "down"
## The input action name for reloading the current active weapon
@export var reload_action: String = "reload"
## The input action name for jumping
@export var jump_action: String = "jump"
## The input action name for sprinting
@export var sprint_action: String = "sprint"

@onready var character: FirstPersonCharacter = get_parent()

var head: Node3D
var is_editor: bool = Engine.is_editor_hint()
var look_rotation: Vector2 = Vector2.ZERO
var is_jumping: bool = false
var accelerated_jump: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings

func _ready() -> void:
	if enabled:
		enable()

	# If there is a viewport, set it
	for child in character.get_children():
		if child is FirstPersonItemsContainer:
			fps_item_container = child

	if character.has_node("Head"):
		head = character.get_node("Head")
		
	setup_input()

func _input(event: InputEvent) -> void:
	if !enabled or is_editor: return
	
	# TODO: These hard coded buttons need to be replaced with something configurable
	
	look_rotation.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * look_sensitivity
	look_rotation.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * look_sensitivity
	
	character.direction = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	
	if fps_item_container:
		if event.is_action_pressed(item_next_action):
			fps_item_container.next_item()
		elif event.is_action_pressed(item_previous_action):
			fps_item_container.previous_item()
		
		if Input.is_action_pressed(action_action):
			fps_item_container.action()
		elif Input.is_action_just_released(action_action):
			fps_item_container.release_action();
			
		if Input.is_action_just_pressed(zoom_action):
			fps_item_container.zoom()
		elif Input.is_action_just_released(zoom_action):
			fps_item_container.zoomout()


func _physics_process(delta: float) -> void:
	if is_editor or character and character.is_authority_owner() == false: return
	
	if !head or !enabled or is_editor or !character.input_enabled: return
	var look_angle: Vector2 = Vector2(look_rotation.x * delta, look_rotation.y * delta)
	character.look_angle = Vector2(-look_angle.x, -look_angle.y)

func setup_input():
	var action_names = [
		reload_action,
		jump_action,
		sprint_action,
		item_next_action,
		item_previous_action
	]
	var default_keys = [
		JOY_BUTTON_B,
		JOY_BUTTON_A,
		JOY_BUTTON_LEFT_STICK,
		JOY_BUTTON_RIGHT_SHOULDER,
		JOY_BUTTON_LEFT_SHOULDER
	]
	
	for i in action_names.size():
		var action_name = action_names[i]
		InputManager.register_action(action_name, default_keys[i], 2)
		
	var action_motion_names = [
		left_action,
		right_action,
		up_action,
		down_action,
		action_action,
		zoom_action
	]
	
	var default_motion_keys = [
		JOY_AXIS_LEFT_X,
		JOY_AXIS_LEFT_X,
		JOY_AXIS_LEFT_Y,
		JOY_AXIS_LEFT_Y,
		JOY_AXIS_TRIGGER_RIGHT,
		JOY_AXIS_TRIGGER_LEFT
	]
	
	var default_motion_values = [
		-1,
		1,
		-1,
		1,
		-1,
		-1
	]
	
	for i in action_motion_names.size():
		var action_name = action_motion_names[i]
		InputManager.register_action(action_name, default_motion_keys[i], 3, default_motion_values[i])
		
## Disable input and release mouse
func disable() -> void:
	enabled = false


## Enable input and capture mouse
func enable() -> void:
	enabled = true
