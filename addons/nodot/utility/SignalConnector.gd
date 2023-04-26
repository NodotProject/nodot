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
## Arguments to unbind from signal
@export var unbind_count: int = 0

func _ready():
  if is_instance_valid(trigger_node) and is_instance_valid(target_node) and trigger_signal != "" and target_method != "":
    var callback = target_node[target_method]
    if unbind_count > 0:
      callback = Callable(target_node[target_method].unbind(unbind_count))
    trigger_node.connect(trigger_signal, callback)
  
