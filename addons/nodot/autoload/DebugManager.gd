## A global tool to store debug data for NodotDebug nodes
extends Node

var debug_nodes: UniqueSet = UniqueSet.new()
var data: Storage = Storage.new()

func register(node: NodotDebug):
	debug_nodes.add(node)

func unregister(node: NodotDebug):
	debug_nodes.remove(node)

var supported_types = [StateMachine]

func _physics_process(delta):
	var items: Array[NodotDebug] = debug_nodes.items
	for node in items:
		if !node.enabled or !is_instance_valid(node) or !is_instance_valid(node.target_node):
			unregister(node)
			continue

		if node.target_node is StateMachine:
			process_state_machine(node)
		else:
			process_other(node)
			
func process_other(node: NodotDebug):
	var uid = node.get_path()
	var custom_fields = node.custom_watch_fields
	var target_node = node.target_node
	var values = get_custom_field_values(target_node, custom_fields)
	data.set(uid, values)

func process_state_machine(node: NodotDebug):
	var uid = node.get_path()
	var custom_fields = node.custom_watch_fields
	var target_node: StateMachine = node.target_node
	var values = get_custom_field_values(target_node, custom_fields)
	values.current_state = target_node.get_name_from_id(target_node.current_state)
	values.node_type = "StateMachine"
	data.set(uid, values)
	
func get_custom_field_values(node: Node, keys: Array[String]):
	var values: Dictionary = {}
	for property in node.get_property_list():
		if keys.has(property.name):
			values[property] = node.get(property.name)
			
	return values
