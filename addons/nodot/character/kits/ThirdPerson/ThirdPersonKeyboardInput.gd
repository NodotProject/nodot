@tool
@icon("../../icons/keyboard.svg")
## A preconfigured set of inputs for third person keyboard control
class_name ThirdPersonKeyboardInput extends Node

## Is input enabled
@export var enabled := true

@export_subgroup("Input Actions")
## The input action name for strafing left
@export var left_action: String = "left"
## The input action name for strafing right
@export var right_action: String = "right"
## The input action name for moving forward
@export var up_action: String = "up"
## The input action name for moving backwards
@export var down_action: String = "down"

@onready var character: ThirdPersonCharacter = get_parent()

var is_editor: bool = Engine.is_editor_hint()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is ThirdPersonCharacter):
		warnings.append("Parent should be a ThirdPersonCharacter")
	return warnings

func _ready():
	if enabled:
		enable()
	
	if is_editor: return
	
	InputManager.register_action(left_action, KEY_A)
	InputManager.register_action(right_action, KEY_D)
	InputManager.register_action(up_action, KEY_W)
	InputManager.register_action(down_action, KEY_S)

func _physics_process(delta: float) -> void:
	if !character: return
	if is_editor: return
	if not character.is_multiplayer_authority(): return
	
	if enabled and character.input_enabled:
		character.direction2d = Input.get_vector(left_action, right_action, up_action, down_action)
		if character.direction2d.length() > 0.0:
			character.camera.time_since_last_move = 0.0

func enable():
	enabled = true
	
func disable():
	enabled = false
