## A node pool implementation for efficient node reuse
## Manages a pool of nodes that can be reused instead of constantly instantiating and freeing
class_name NodePool extends Node

## The maximum number of objects allowed in the pool
@export var pool_limit: int = 10

## The node template to duplicate for the pool
@export var target_node: Node: set = _set_target_node

## The duplicate flags to use when creating new nodes (see Node.DUPLICATE_* constants)
@export var duplicate_flag: int = 15

## The parent node where new nodes should be spawned
@export var spawn_root: Node

# Internal array storing the pool of nodes
var pool: Array[Node] = []

## Sets the target node and initializes the pool
func _set_target_node(new_node: Node) -> void:
	target_node = new_node
	clear()
	_add_node_to_tree(target_node)
	pool = [target_node]
	
## Adds a node to the scene tree if it's not already in one
func _add_node_to_tree(node: Node) -> void:
	if !node.is_inside_tree():
		if is_instance_valid(spawn_root):
			spawn_root.add_child.call_deferred(node)
		else:
			add_child(node)
			
## Gets the next available node from the pool
## If the pool is at its limit, reuses the oldest node
## Otherwise, creates a new node by duplicating the target
func next() -> Node:
	var node = pool.pop_front() if pool.size() >= pool_limit else pool[0].duplicate(duplicate_flag)
	if !is_instance_valid(node): return null
	pool.append(node)
	_add_node_to_tree(node)
	
	# If this is a PooledNode, set the owner_pool reference for auto-recycling
	if node is PooledNode:
		node.owner_pool = self
	
	return node

## Clears the pool and frees all nodes
func clear():
	for node in pool:
		if is_instance_valid(node):
			# Clear owner_pool reference to prevent double-return
			if node is PooledNode:
				node.owner_pool = null
			node.queue_free()
	pool = []

## Returns a node to the pool (called automatically by PooledNode)
func return_to_pool(node: Node) -> void:
	if !node or !is_instance_valid(node):
		return
	
	# Don't add the node if it's already in the pool
	if pool.has(node):
		return
		
	# Reset the node's state if it's a PooledNode
	if node.has_method("reset_for_pool"):
		node.reset_for_pool()
	
	# Remove from current parent if it has one
	if node.get_parent():
		node.get_parent().remove_child(node)
	
	# If pool is at limit, replace the oldest node
	if pool.size() >= pool_limit:
		var old_node = pool.pop_front()
		if old_node != node and is_instance_valid(old_node):
			# Clear the owner_pool reference to prevent double-return
			if old_node is PooledNode:
				old_node.owner_pool = null
			old_node.queue_free()
	
	# Add to front of pool (most recently returned)
	pool.push_front(node)
