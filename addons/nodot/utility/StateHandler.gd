@tool
@icon("../icons/statehandler.svg")
class_name StateHandler extends Nodot

## Base class for states to be used with [StateMachine].
##
## Simplified version of the StateMachine from Netfox: https://github.com/foxssake/netfox
##
## Provides multiple callback methods for a state's lifecycle, which can be 
## overridden by extending classes.
## [br][br]
## Must have a [StateMachine] as a parent.

## The [StateMachine] this state belongs to.
## [br][br]
## [i]read-only[/i]
var state_machine: StateMachine:
	get: return _state_machine

var _state_machine: StateMachine

## Callback to input logic.
##
## This method is called by the [StateMachine] during input event.
## [br][br]
## [i]override[/i] to implement input logic
func input(event: InputEvent) -> void:
	pass

## Callback to process logic.
##
## This method is called by the [StateMachine] during the process frame to update game state.
## [br][br]
## [i]override[/i] to implement game logic
func process(delta: float) -> void:
	pass

## Callback to physics logic.
##
## This method is called by the [StateMachine] during the physics frame to update game state.
## [br][br]
## [i]override[/i] to implement game logic
func physics_process(delta: float) -> void:
	pass

## Callback for entering the state.
##
## This method is called whenever the state machine enters this state.
## [br][br]
## [i]override[/i] to react to state transitions
func enter(previous_state: StateHandler) -> void:
	pass

## Callback for entering the state.
##
## This method is called whenever the state machine exits this state.
## [br][br]
## [i]override[/i] to react to state transitions
func exit(next_state: StateHandler) -> void:
	pass

## Callback for validating state transitions while entering.
##
## Whenever the [StateMachine] attempts to enter this state, it will 
## call this method to ensure that the transition is valid.
## [br][br]
## If this method returns true, the transition is valid and the state machine 
## will enter this state. Otherwise, the transition is invalid, and nothing 
## happens.
## [br][br]
## [i]override[/i] to implement custom transition validation logic
func can_enter(previous_state: StateHandler) -> bool:
	# Add your validation logic here
	# Return true if the state machine can transition to the next state
	return true

## Callback for validating state transitions while exiting.
##
## Whenever the [StateMachine] attempts to exit this state, it will 
## call this method to ensure that the transition is valid.
## [br][br]
## If this method returns true, the transition is valid and the state machine
## will exit this state. Otherwise, the transition is invalid, and nothing
## happens.
## [br][br]
## [i]override[/i] to implement custom transition validation logic
func can_exit(next_state: StateHandler) -> bool:
	# Add your validation logic here
	# Return true if the state machine can transition to the next state
	return true

func _get_configuration_warnings():
	return [] if get_parent() is StateMachine else ["This state should be a child of a StateMachine."]

func _ready():
	if _state_machine == null and get_parent() is StateMachine:
		_state_machine = get_parent()
		_state_machine._available_states[name] = self

func _physics_process(delta: float) -> void:
	if !state_machine or state_machine.state != name: return
	physics_process(delta)
	
func _process(delta: float) -> void:
	if !state_machine or state_machine.state != name: return
	process(delta)

func _input(event: InputEvent) -> void:
	if state_machine.state != name: return
	input(event)
