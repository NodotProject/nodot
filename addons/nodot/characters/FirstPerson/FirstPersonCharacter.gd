## A CharacterBody3D for first person games
class_name FirstPersonCharacter extends CharacterBody3D

## Allow player input
@export var input_enabled := true
## The camera field of view
@export var fov := 75.0
## The head position
@export var head_position := Vector3.ZERO
## Gravity strength
@export var gravity: float = 9.8
## Apply gravity even when the character is on the floor
@export var always_apply_gravity: bool = false

@export_category("Input Actions")
## The input action name for pausing the game
@export var escape_action: String = "escape"

## Triggered when the game is paused
signal paused
## Triggered when the game is unpaused
signal unpaused

var head: Node3D
var camera: Camera3D = Camera3D.new()
var submerge_handler: FirstPersonSubmerged
var keyboard_input: FirstPersonKeyboardInput


func _enter_tree() -> void:
	head = Node3D.new()
	head.name = "Head"
	camera.name = "Camera3D"
	head.add_child(camera)
	add_child(head)

	submerge_handler = Nodot.get_first_child_of_type(self, FirstPersonSubmerged)
	keyboard_input = Nodot.get_first_child_of_type(self, FirstPersonKeyboardInput)


func _ready() -> void:
	camera.fov = fov

	if has_node("Head"):
		head = get_node("Head")
		camera = get_node("Head/Camera3D")

	if has_node("HeadPosition"):
		var head_position_node: Node = get_node("HeadPosition")
		head.position = head_position_node.position
		head_position_node.queue_free()
	else:
		head.position = head_position


func _physics_process(delta: float) -> void:
	if always_apply_gravity or !is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(escape_action):
		if input_enabled:
			pause()
		else:
			unpause()


## Pause the game
func pause():
	disable_input()
	input_enabled = false
	emit_signal("paused")


## Unpause the game
func unpause():
	enable_input()
	input_enabled = true
	emit_signal("unpaused")


## Disable player input
func disable_input() -> void:
	for child in get_children():
		if child is FirstPersonKeyboardInput:
			child.disable()
		if child is FirstPersonMouseInput:
			child.disable()


## Enable player input
func enable_input() -> void:
	for child in get_children():
		if child is FirstPersonKeyboardInput:
			child.enable()
		if child is FirstPersonMouseInput:
			child.enable()
