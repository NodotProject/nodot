@tool
## Proxies local signals to global signals
class_name LocalToGlobalSignalProxy extends Nodot

var is_editor: bool = Engine.is_editor_hint()

@export_subgroup("Trigger")
## The path of the node that will emit the signal
@export var trigger_node: NodePath: # TODO: WARNING DO NOT CHANGE TYPE: https://github.com/godotengine/godot/issues/77012
	set(new_node):
		trigger_node = new_node
		if is_editor:
			actual_trigger_node = get_node(trigger_node)
			notify_property_list_changed()
@export_subgroup("Target")
## The global signal name
@export var global_signal: String = ""
## Arguments to unbind from signal
@export var unbind_count: int = 0

## The name of the signal
@export var trigger_signal: String = ""
## The actual node that will emit the signal
var actual_trigger_node: Node

func _ready():
	if is_editor: return
	
	if trigger_node:
		actual_trigger_node = get_node(trigger_node)
		notify_property_list_changed()
	
	if (
		is_instance_valid(actual_trigger_node)
		and trigger_signal != ""
		and global_signal != ""
	):
		var callback = _callback
		if unbind_count > 0:
			callback = Callable(callback.unbind(unbind_count))
		actual_trigger_node.connect(trigger_signal, callback)

func _callback():
	GlobalSignal.trigger_signal(global_signal)

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = [{
		name = "Trigger",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_SUBGROUP
	}]
	
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
		"hint_string": signal_list
	})
		
	return property_list
