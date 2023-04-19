## Connects signals to methods
class_name SignalConnector extends Nodot

## The node that will emit the signal
@export var trigger_node: Node
## The name of the signal
@export var trigger_signal: String = "interacted"
## The node that has the method
@export var target_node: Node
## The name of the method
@export var target_method: String = "action"

func _ready():
  if is_instance_valid(trigger_node) and is_instance_valid(target_node) and trigger_signal != "" and target_method != "":
    trigger_node.connect(trigger_signal, target_node[target_method])
  
