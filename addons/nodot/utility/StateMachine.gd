@tool
@icon("../icons/statemachine.svg")
class_name StateMachine extends Nodot

## A state machine.
##
## Simplified version of the StateMachine from Netfox: https://github.com/foxssake/netfox
##
## To implement states, extend the [StateHandler] class and add it as a child
## node.

## Name of the current state.
## 
## Can be an empty string if no state is active. Only modify directly if you
## need to skip [method transition]'s callbacks.
@export var state: StringName = "":
	get: return _state_object.name if _state_object != null else ""
	set(v): _set_state(v)

## Emitted during state transitions.
##
## This signal is emitted whenever a transition happens during rollback, which 
## means it may be emitted multiple times for the same transition if it gets 
## resimulated during rollback.
signal on_state_changed(old_state: StateHandler, new_state: StateHandler)

var _state_object: StateHandler = null
var _available_states: Dictionary = {}

## Transition to a new state specified by [param new_state_name].
##
## Finds the given state by name and transitions to it if possible. The new 
## state's [method StateHandler.can_enter] callback decides if it can be
## entered from the current state.
## [br][br]
## Upon transitioning, [method StateHandler.exit] is called on the old state,
## and [method StateHandler.enter] is called on the new state. In addition, 
## [signal on_state_changed] is emitted.
## [br][br]
## Does nothing if transitioning to the currently active state. Emits a warning
## and does nothing when transitioning to an unknown state.
func transition(new_state_name: StringName) -> void:
	if state == new_state_name:
		return
	
	if not _available_states.has(new_state_name):
		printerr("Attempted to transition from state '%s' into unknown state '%s'" % [state, new_state_name])
		return
		
	var new_state: StateHandler = _available_states[new_state_name]
	if _state_object:
		if !_state_object.can_exit(new_state) or !new_state.can_enter(_state_object):
			return
	
		_state_object.exit(new_state)
	
	var _previous_state: StateHandler = _state_object
	_state_object = new_state
	on_state_changed.emit(_previous_state, new_state)
	_state_object.enter(_previous_state)

func _input(event: InputEvent) -> void:
	if _state_object:
		_state_object.input(event)

func _process(delta: float) -> void:
	if _state_object:
		_state_object.process(delta)

func _physics_process(delta: float) -> void:
	if _state_object:
		_state_object.physics_process(delta)

func _set_state(new_state: StringName) -> void:
	if not new_state:
		return
	
	if not _available_states.has(new_state):
		printerr("Attempted to jump to unknown state: %s" % [new_state])
		return
	
	_state_object = _available_states[new_state]
