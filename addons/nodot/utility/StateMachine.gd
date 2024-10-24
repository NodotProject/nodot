@icon("../icons/statemachine.svg")
## A simple state machine
class_name StateMachine extends Nodot

## The initial state
@export var state: StringName

signal state_updated(old_state: StringName, new_state: StringName)

var old_state: StringName

func set_state(new_state: StringName) -> void:
	old_state = state
	if old_state != new_state:
		state_updated.emit(old_state, new_state)
	state = new_state
