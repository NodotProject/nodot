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
		_apply_mouse_look(event as InputEventMouseMotion)

	if fps_item_container:
		if event.is_action_pressed(item_next_action):
			fps_item_container.next_item()
		elif event.is_action_pressed(item_previous_action):
			fps_item_container.previous_item()

func _physics_process(_delta: float) -> void:
	if !enabled or is_editor or !character.input_enabled: return
	
	if fps_item_container:
		if Input.is_action_pressed(action_action):
			fps_item_container.action()
		if Input.is_action_just_released(action_action):
			fps_item_container.release_action();
		elif Input.is_action_just_pressed(zoom_action):
			fps_item_container.zoom()
		elif Input.is_action_just_released(zoom_action):
			fps_item_container.zoomout()

## Turn the view by one mouse event, IMMEDIATELY (not buffered to the physics tick).
## - Per event: Godot already coalesces a frame's motion into one event, so the view turns
##   every rendered frame with no added latency. The old path stored the motion with `=`
##   and consumed it once per physics tick, so above 60 fps every frame but the last in a
##   tick was DROPPED (at 144 fps ~58% of hand motion, varying with frame timing), the
##   view stepped at 60 Hz on high-refresh screens and lagged a tick behind the hand.
## - screen_relative, not relative: relative is divided by the canvas_items stretch scale,
##   so sensitivity changed with the window size.
## - Zoom-matched: the camera's live FOV vs the character's resting FOV scales the turn so
##   ADS/scopes keep the hip view's on-screen speed (InputManager.zoom_factor).
func _apply_mouse_look(event: InputEventMouseMotion) -> void:
	if is_editor or not character.is_multiplayer_authority():
		return
	var zoom := 1.0
	if character.camera != null:
		zoom = InputManager.zoom_factor(character.camera.fov, character.fov)
	var look: Vector2 = InputManager.look_radians(event.screen_relative, zoom)
	character.rotate_look(-look.x, -look.y)

## Disable input and release mouse
func disable() -> void:
	Input.set_mouse_mode(cursor_show_state)
	enabled = false

## Enable input and capture mouse
func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enabled = true
