@tool
## Executes a method and/or triggers a signal when an input action is pressed
class_name InputActionConnector extends Nodot

## Whether the node functionality is enabled
@export var enabled: bool = true
## The input action to listen to
@export var input_action: String

@export_subgroup("Target")
## (optional) The target node with a method to execute
@export var target_node: Node:
	set(new_node):
		target_node = new_node
		notify_property_list_changed()
		
@export_subgroup("Argument Binding")
## Arguments to unbind from signal
@export var method_unbind_count: int = 0

## Triggered when the input action is activated
signal input_action_pressed

## The name of the target node method to execute
var target_method: String = ""

func _ready():
	notify_property_list_changed()
	
func _input(event):
	if event.is_action_pressed(input_action):
		emit_signal("input_action_pressed")
		if is_instance_valid(target_node) and target_node.has_method(target_method):
			var callback = target_node[target_method]
			if method_unbind_count > 0:
				callback = Callable(target_node[target_method].unbind(method_unbind_count))
			callback.call()

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	
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
