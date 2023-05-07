## Connects global signals to methods
class_name GlobalSignalConnector extends Nodot

## The name of the global signal
@export var trigger_signal: String = "signal"
## The node that has the method
@export var target_node: Node
## The name of the method
@export var target_method: String = "action"


func _ready():
	if (
		is_instance_valid(target_node)
		and trigger_signal != ""
		and target_method != ""
	):
		if target_node.has_method(target_method):
			GlobalSignal.add_listener(trigger_signal, target_node, target_method)
