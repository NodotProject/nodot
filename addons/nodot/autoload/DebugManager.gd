## A global tool to store debug data for NodotDebug nodes
extends Node

signal debug_node_added(debug_node: NodotDebug)
signal debug_node_removed(debug_node: NodotDebug)

var debug_nodes: UniqueSet = UniqueSet.new()
var data: Storage = Storage.new()

func register(node: NodotDebug):
	debug_nodes.add(node)
	emit_signal("debug_node_added", node)

func unregister(node: NodotDebug):
	debug_nodes.remove(node)
	emit_signal("debug_node_removed", node)

var supported_types = [StateMachine]

func _physics_process(delta):
	var items = debug_nodes.items
	for node in items:
		if !node.enabled or !is_instance_valid(node) or !is_instance_valid(node.target_node):
			unregister(node)
			continue

		if node.target_node is StateMachine:
			process_state_machine(node)
		else:
			process_other(node)
			
func process_other(node: NodotDebug):
	var uid = str(node.get_path())
	var custom_fields = node.custom_watch_fields
	var target_node = node.target_node
	var values = get_custom_field_values(target_node, custom_fields)
	data.setItem(uid, values)

func process_state_machine(node: NodotDebug):
	var uid = str(node.get_path())
	var custom_fields = node.custom_watch_fields
	var target_node: StateMachine = node.target_node
	var values = get_custom_field_values(target_node, custom_fields)
	values.current_state = target_node.get_name_from_id(target_node.current_state)
	values.node_type = "StateMachine"
	data.setItem(uid, values)
	
func get_custom_field_values(node: Node, keys: Array[String]):
	var values: Dictionary = {}
	for property in node.get_property_list():
		if keys.has(property.name):
			values[property.name] = node.get(property.name)
			
	return values
