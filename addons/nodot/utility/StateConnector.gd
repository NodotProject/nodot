@tool
@icon("../icons/stateconnector.svg")
## Connects state changes to methods
class_name StateConnector extends Nodot

var is_editor: bool = Engine.is_editor_hint()

@export_subgroup("State Trigger")
## The StateMachine or NodotCharacter that will change to the trigger state
@export var state_machine: Node
## The state that will trigger the method
@export var trigger_state: String

@export_subgroup("Target")
## The node that has the method
@export var target_node: Node:
	set(new_node):
		target_node = new_node
		notify_property_list_changed()
		
@export_subgroup("Argument Binding")
## Arguments to unbind from signal
@export var method_unbind_count: int = 0

## The name of the target node method to execute
var target_method: String = ""

var final_state_machine: StateMachine
var final_trigger_state_id: int = -1

func _ready():
	notify_property_list_changed()
	
	if target_method == "" or !is_instance_valid(target_node): return
	
	if state_machine is NodotCharacter3D:
		final_state_machine = state_machine.sm
	elif state_machine is StateMachine:
		final_state_machine = state_machine
		
	final_state_machine.connect("state_updated", _state_updated)

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = [{
		name = "Trigger",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_SUBGROUP
	}]
	
	var method_list = ""
	if target_node:
		var method_data = target_node.get_method_list()
		var methods = method_data.map(func(item): return item.name).filter(
			func(item): return item != ""
		)
		methods.sort()
		method_list = ",".join(methods)
			
		property_list.append_array([{
			name = "Target",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP
		}, {
			"name": "target_method",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": method_list,
		}])
		
	return property_list

func _state_updated(old_state: int, new_state: int) -> void:
	if final_trigger_state_id < 0:
		final_trigger_state_id = final_state_machine.get_id_from_name(trigger_state)
		
	if new_state == final_trigger_state_id:
		var callback = target_node[target_method]
		if method_unbind_count > 0:
			callback = Callable(target_node[target_method].unbind(method_unbind_count))
		callback.call()
			
