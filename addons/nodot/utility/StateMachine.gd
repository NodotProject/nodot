@icon("../icons/statemachine.svg")
## A simple state machine
class_name StateMachine extends Nodot

## The initial state
@export var state: int = 0: set = _on_state_changed
## Valid state transitions is an array of int tuples with old state and new (i.e [[2, 4], [2, 5]])
@export var valid_transitions: Array[Array] = []

## Triggered when the state changes
signal state_updated(old_state: int, new_state: int)

var old_state: int = 0
var state_names = []

func _init():
	old_state = state
	
func _on_state_changed(new_state: int):
	if !_check_transition_valid(state, new_state):
		return
	
	old_state = state
	state = new_state
	emit_signal("state_updated", old_state, new_state)

func _check_transition_valid(old_state: int, new_state: int) -> bool:
	if old_state == new_state:
		return false
		
	if valid_transitions.size() > old_state:
		var transitions = valid_transitions[old_state]
		if transitions.has(new_state):
			return true
		else:
			return false
	else:
		return true

## Add a transition validator. `from` can be a single string or int.  `to` can be either a single in or an array of strings or ints
func add_valid_transition(from, to) -> void:
	var from_id = from
	if from is int:
		from_id = from
	elif from is String:
		from_id = state_names.find(from)
		if from_id < 0:
			from_id = register_state(from)
		
	var to_ids = to
	if to is int:
		to_ids = to
	if to is String:
		to_ids = state_names.find(to)
		if to_ids < 0:
			to_ids = register_state(to)
			
	if to is Array:
		to_ids = []
		for t in to:
			if !to_ids.has(t):
				if t is int:
					to_ids.append(t)
				if t is String:
					var found_t = state_names.find(t)
					if found_t < 0:
						found_t = register_state(t)
					to_ids.append(found_t)
		
	if valid_transitions.size() > from_id:
		if to_ids is Array:
			for t in to_ids:
				if !valid_transitions[from_id].has(t):
					valid_transitions[from_id].append(t)
		else:
			if !valid_transitions[from_id].has(to_ids):
				valid_transitions[from_id].append(to_ids)

## Register a new state
func register_state(new_state_name: String) -> int:
	var existing_id = state_names.find(new_state_name)
	if existing_id < 0:
		state_names.append(new_state_name)
		valid_transitions.append([])
		return valid_transitions.size() - 1
	return existing_id 

func get_id_from_name(state_name: String) -> int:
	var id = state_names.find(state_name)
	if id < 0:
		push_error("Attempted to get id of %s before it was registered" % state_name)
	return id

func get_name_from_id(id: int) -> String:
	return state_names[id]

func set_state(new_state: int) -> void:
	state = new_state
