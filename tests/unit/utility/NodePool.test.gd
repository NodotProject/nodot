extends VestTest

var pool: NodePool
var test_node: PooledNode

func before_case(_case):
	pool = NodePool.new()
	test_node = PooledNode.new()
	test_node.name = "TestPooledNode"

func after_case(_case):
	if is_instance_valid(pool):
		pool.clear()
		pool.queue_free()

func test_pooled_node_auto_recycle():
	# Setup pool
	pool.pool_limit = 3
	pool.target_node = test_node
	
	# Get a node from the pool
	var node1 = pool.next()
	expect_not_null(node1, "Should get a node from pool")
	expect_true(node1 is PooledNode, "Should be a PooledNode")
	expect_equal(node1.owner_pool, pool, "Should have owner_pool set")
	
	# Verify initial pool state
	expect_equal(pool.pool.size(), 1, "Pool should contain the active node")
	
	# Queue the node for deletion - should automatically return to pool
	node1.queue_free()
	
	# Process the deletion queue 
	await get_tree().process_frame
	
	# The node should have been returned to pool instead of being freed
	expect_true(is_instance_valid(node1), "Node should still be valid (not freed)")
	expect_true(pool.pool.has(node1), "Node should be back in the pool")

func test_pool_limit_with_auto_recycle():
	# Setup pool with limit of 2
	pool.pool_limit = 2
	pool.target_node = test_node
	
	# Fill the pool to its limit
	var node1 = pool.next()
	var node2 = pool.next()
	
	expect_equal(pool.pool.size(), 2, "Pool should be at its limit")
	
	# Return a node to pool
	node1.queue_free()
	await get_tree().process_frame
	
	expect_equal(pool.pool.size(), 2, "Pool size should remain at limit")
	expect_true(is_instance_valid(node1), "Returned node should still be valid")
	expect_true(pool.pool.has(node1), "Node should be in the pool")

func test_reset_for_pool_called():
	# Create a custom PooledNode that tracks reset calls
	var custom_node = CustomTestNode.new()
	custom_node.name = "CustomTestNode"
	
	pool.pool_limit = 2
	pool.target_node = custom_node
	
	var node = pool.next()
	expect_false(node.reset_called, "Reset should not be called on retrieval")
	
	# Queue for deletion to trigger return to pool
	node.queue_free()
	await get_tree().process_frame
	
	expect_true(node.reset_called, "Reset should be called when returned to pool")

func test_non_pooled_node_behavior():
	# Test that regular nodes still work with the pool
	var regular_node = Node.new()
	regular_node.name = "RegularNode"
	
	pool.pool_limit = 2
	pool.target_node = regular_node
	
	var node = pool.next()
	expect_not_null(node, "Should get a node from pool")
	expect_false(node is PooledNode, "Should not be a PooledNode")
	
	# Regular nodes should not have owner_pool set
	expect_false(node.has_property("owner_pool"), "Regular nodes should not have owner_pool")

# Helper class for testing reset_for_pool
class CustomTestNode extends PooledNode:
	var reset_called: bool = false
	
	func reset_for_pool() -> void:
		reset_called = true