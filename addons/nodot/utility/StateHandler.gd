@icon("../icons/statehandler.svg")
## A node to handle and control events from a state machine
class_name StateHandler extends Nodot

## Enable/disable this node.
@export var enabled: bool = true
## The id of the state
@export var handled_states: Array[StringName] = []
## The StateMachine to attach this handler to
@export var sm: StateMachine

var old_state: StringName

func _ready():
	if !enabled:
		return
	
	if !sm and get_parent() is StateMachine:
		sm = get_parent()
		
	ready()
	
func _physics_process(delta):
	if !enabled or !sm or !handled_states.has(sm.state):
		return
		
	physics(delta)
	
func _process(delta):
	if !enabled or !sm:
		return
	
	if _is_state_active():
		process(delta)
	
func _input(event: InputEvent) -> void:
	input(event)

func _is_state_active() -> bool:
	var is_state_active: bool = handled_states.has(sm.state)

	if sm.state != old_state:
		if is_state_active and can_enter():
			enter()
		elif !is_state_active:
			exit()
		old_state = sm.state
	return is_state_active

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

func enter():
	pass
	
func exit():
	pass

## Test if the state can be changed
func can_enter() -> bool:
	return true
