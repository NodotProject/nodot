@icon("../icons/statehandler.svg")
## A node to handle and control events from a state machine
class_name StateHandler extends Nodot

## Enable/disable this node.
@export var enabled : bool = true
## The StateMachine to attach this handler to
@export var sm: StateMachine
## Run process/physics even when the state is unhandled
@export var ignore_handled_states: bool = false

var is_editor: bool = Engine.is_editor_hint()
var handled_states: Array[String] = []
var state_ids: Dictionary = {}

func _ready():
	if !enabled:
		return
	
	if !sm and get_parent() is StateMachine:
		sm = get_parent()
		
	sm.connect("state_updated", state_updated)
	ready()
	
func _physics_process(delta):
	if is_editor or !enabled or !sm or sm.state < 0 or (!ignore_handled_states and !handles_state(sm.state)):
		return
		
	physics(delta)
	
func _process(delta):
	if is_editor or !enabled or !sm or sm.state < 0 or (!ignore_handled_states and !handles_state(sm.state)):
		return
		
	process(delta)
	
func _input(event: InputEvent) -> void:		
	input(event)

## Registers a set of states that the node handles
func register_handled_states(new_states: Array[String]):
	for state_name in new_states:
		var state_id = sm.register_state(state_name)
		state_ids[state_name] = state_id
		handled_states.append(state_name)

## Checks whether this node handles a certain state
func handles_state(state: Variant) -> bool:
	if state is String:
		return handled_states.has(state)
	if state is int:
		return state_ids.values().has(state)
	return false
	
## Extend this placeholder. This is where your logic will be run when the node becomes ready.
func ready() -> void:
	pass
	
## Extend this placeholder. This is where your logic will be run every physics frame.
func physics(delta: float) -> void:
	pass
	
## Extend this placeholder. This is where your logic will be run every process frame.
func process(delta: float) -> void:
	pass

## Extend this placeholder. This is where your logic will be run for every input.
func input(event: InputEvent) -> void:
	pass
	
## Extend this placeholder. This is triggered whenever the character state is updated.
func state_updated(old_state: int, new_state: int) -> void:
	pass
