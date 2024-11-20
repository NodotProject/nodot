@icon("../../icons/keyboard.svg")
## Adds keyboard support to the first person character
class_name FirstPersonKeyboardInput extends Nodot

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

@onready var character: FirstPersonCharacter = get_parent()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings

func _ready():
	if enabled:
		enable()

	InputManager.bulk_register_actions_once(
		get_class(),
		[left_action, right_action, up_action, down_action],
		[KEY_A, KEY_D, KEY_W, KEY_S]
	)

func _physics_process(delta: float) -> void:
	if enabled and character.input_enabled:
		character.direction2d = Input.get_vector(left_action, right_action, up_action, down_action)

func enable():
	enabled = true
	
func disable():
	enabled = false
