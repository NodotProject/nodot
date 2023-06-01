@tool
## Connects signals to methods
class_name SignalConnector extends Nodot

var is_editor: bool = Engine.is_editor_hint()

@export_subgroup("Trigger")
## Whether to use global signals as the trigger
@export var use_global_signal: bool = false:
	set(new_value):
		use_global_signal = new_value
		notify_property_list_changed()

@export_subgroup("Target")
## The node that has the method
@export var target_node: Node:
	set(new_node):
		target_node = new_node
		if is_editor:
			notify_property_list_changed()

@export_subgroup("Argument Binding")
## Arguments to unbind from signal
@export var method_unbind_count: int = 0

## The path of the node that will trigger the signal
var trigger_node: Node:
	set(new_node):
		trigger_node = new_node
		if is_editor:
			notify_property_list_changed()

## The name of the signal
var trigger_signal: String = ""
## The name of the target node method to execute
var target_method: String = ""

func _ready():
	notify_property_list_changed()
	
	if target_method == "" or !is_instance_valid(target_node): return
	
	if use_global_signal:
		if trigger_signal != "":
			GlobalSignal.add_listener(trigger_signal, target_node, target_method)
	else:
		if target_method == "":
			return
		var callback = target_node[target_method]
		if method_unbind_count > 0:
			callback = Callable(target_node[target_method].unbind(method_unbind_count))
		trigger_node.connect(trigger_signal, callback)

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
		if trigger_node:
			var signal_data = trigger_node.get_signal_list()
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
