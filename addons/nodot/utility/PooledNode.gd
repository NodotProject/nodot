## A base class for nodes that can be automatically recycled by a NodePool
## Nodes extending this class will automatically return to their pool when queue_free() is called
class_name PooledNode extends Node

## The NodePool that owns this node (set automatically when retrieved from pool)
var owner_pool: NodePool

## Override notification to catch NOTIFY_PREDELETE
func _notification(what: int) -> void:
	if what == NOTIFY_PREDELETE and is_queued_for_deletion() and owner_pool and is_instance_valid(owner_pool):
		# Cancel the free operation and return to pool
		cancel_free()
		owner_pool.return_to_pool(self)

## Called when the node is returned to the pool
## Override this method to reset the node's state
func reset_for_pool() -> void:
	# Default implementation - can be overridden by subclasses
	pass