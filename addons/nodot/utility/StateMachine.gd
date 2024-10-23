@icon("../icons/statemachine.svg")
## A simple state machine
class_name StateMachine extends Nodot

## The initial state
@export var state: StringName

var old_state: StringName

func set_state(new_state: StringName) -> void:
	old_state = state
	state = new_state
