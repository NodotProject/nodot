@tool
## Connects signals to methods
class_name SignalConnector extends Nodot

var is_editor: bool = Engine.is_editor_hint()

@export_subgroup("Trigger")
## Whether to use global signals as the trigger
@export var use_global_signal: bool = false:
	set(new_value):
		use_global_signal = new_value
		if is_editor:
			actual_trigger_node = get_node(trigger_node)
		notify_property_list_changed()

@export_subgroup("Target")
## The node that has the method
@export var target_node: NodePath: # WARNING DO NOT CHANGE TYPE: https://github.com/godotengine/godot/issues/77012
	set(new_node):
		target_node = new_node
		if is_editor:
			actual_target_node = get_node(target_node)
			notify_property_list_changed()

@export_subgroup("Argument Binding")
## Arguments to unbind from signal
@export var method_unbind_count: int = 0

## The path of the node that will trigger the signal
var trigger_node: NodePath: # WARNING DO NOT CHANGE TYPE: https://github.com/godotengine/godot/issues/77012
	set(new_node):
		trigger_node = new_node
		if is_editor:
			actual_trigger_node = get_node(trigger_node)
			notify_property_list_changed()
## The node that will emit the signal
var actual_trigger_node: Node

## The name of the signal
var trigger_signal: String = ""
## The path of the node that will execute the method
var actual_target_node: Node
## The name of the target node method to execute
var target_method: String = ""

func _ready():
	if trigger_node:
		actual_trigger_node = get_node(trigger_node)
	if target_node:
		actual_target_node = get_node(target_node)
	notify_property_list_changed()
	
	if target_method == "" or !is_instance_valid(actual_target_node): return
	
	if use_global_signal:
		if trigger_signal != "":
			GlobalSignal.add_listener(trigger_signal, actual_target_node, target_method)
	else:
		if target_method == "":
			return
		var callback = actual_target_node[target_method]
		if method_unbind_count > 0:
			callback = Callable(actual_target_node[target_method].unbind(method_unbind_count))
		actual_trigger_node.connect(trigger_signal, callback)

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = [{
		name = "Trigger",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_SUBGROUP
	}]
	
	if use_global_signal:
		property_list.append({
			"name": "trigger_signal",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": ""
		})
	else:
		property_list.append({
			"name": "trigger_node",
			"type": TYPE_NODE_PATH,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_NODE_PATH_VALID_TYPES
		})
		
		var signal_list = ""
		if actual_trigger_node:
			var signal_data = actual_trigger_node.get_signal_list()
			var signals: Array = signal_data.map(func(item): return item.name).filter(
				func(item): return item != ""
			)
			signals.sort()
			signal_list = ",".join(signals)

		property_list.append({
			"name": "trigger_signal",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": signal_list,
		})
	
	var method_list = ""
	if actual_target_node:
		var method_data = actual_target_node.get_method_list()
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
