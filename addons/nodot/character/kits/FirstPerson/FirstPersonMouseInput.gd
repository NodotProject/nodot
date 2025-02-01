@icon("../../icons/mouse.svg")
## Adds mouse support to the first person character
class_name FirstPersonMouseInput extends Node

## Is input enabled
@export var enabled := true
## Custom mouse cursor
@export var custom_cursor := false
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

@onready var character: FirstPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var mouse_rotation: Vector2 = Vector2.ZERO
var cursor_show_state = Input.MOUSE_MODE_VISIBLE

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings

func _init():
	InputManager.bulk_register_actions_once(
		get_class(),
		[item_next_action, item_previous_action, action_action, zoom_action],
		[MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT],
		1
	)
			
func _ready() -> void:
	if enabled:
		enable()

	if custom_cursor:
		cursor_show_state = Input.MOUSE_MODE_HIDDEN

func _input(event: InputEvent) -> void:
	if !enabled or !character.input_enabled: return
	
	if event is InputEventMouseMotion:
		mouse_rotation.y = event.relative.x * InputManager.mouse_sensitivity
		mouse_rotation.x = event.relative.y * InputManager.mouse_sensitivity

	if fps_item_container:
		if event.is_action_pressed(item_next_action):
			fps_item_container.next_item()
		elif event.is_action_pressed(item_previous_action):
			fps_item_container.previous_item()

func _physics_process(delta: float) -> void:
	if !enabled or is_editor or !character.input_enabled: return
	
	var look_angle: Vector2 = Vector2(-mouse_rotation.x * delta, -mouse_rotation.y * delta)
	character.look_angle = Vector2(look_angle.y, look_angle.x)
	mouse_rotation = Vector2.ZERO
	
	if fps_item_container:
		if Input.is_action_pressed(action_action):
			fps_item_container.action()
		if Input.is_action_just_released(action_action):
			fps_item_container.release_action();
		elif Input.is_action_just_pressed(zoom_action):
			fps_item_container.zoom()
		elif Input.is_action_just_released(zoom_action):
			fps_item_container.zoomout()

## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(cursor_show_state)
	enabled = false

## Enable input and capture mouse
func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
