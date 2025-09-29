## Manual integration test for NodePool optimization
## Run this in a scene to verify the pooling system works correctly
extends Node

@export var test_iterations: int = 100
@export var pool_size: int = 10

var pool: NodePool
var created_count: int = 0
var recycled_count: int = 0

func _ready():
	print("=== NodePool Integration Test ===")
	test_basic_pooling()
	test_automatic_recycling()
	test_pool_limits()
	print("=== All Tests Completed ===")

func test_basic_pooling():
	print("\n1. Testing Basic Pooling...")
	
	pool = NodePool.new()
	pool.pool_limit = pool_size
	pool.target_node = TestPooledNode.new()
	
	# Get some nodes
	var nodes = []
	for i in range(5):
		var node = pool.next()
		nodes.append(node)
		print("  Got node: ", node.name, " (Pool size: ", pool.pool.size(), ")")
	
	# Verify they're all PooledNodes with owner_pool set
	for node in nodes:
		assert(node is PooledNode, "Node should be a PooledNode")
		assert(node.owner_pool == pool, "Node should have owner_pool set")
	
	print("  ✓ Basic pooling works correctly")

func test_automatic_recycling():
	print("\n2. Testing Automatic Recycling...")
	
	var node = pool.next()
	var initial_pool_size = pool.pool.size()
	print("  Initial pool size: ", initial_pool_size)
	
	# Queue the node for deletion
	node.queue_free()
	
	# Process one frame to trigger NOTIFY_PREDELETE
	await get_tree().process_frame
	
	# Check if node was returned to pool
	print("  Pool size after recycling: ", pool.pool.size())
	print("  Node still valid: ", is_instance_valid(node))
	print("  Node in pool: ", pool.pool.has(node))
	
	assert(is_instance_valid(node), "Node should still be valid after queue_free")
	assert(pool.pool.has(node), "Node should be back in the pool")
	
	print("  ✓ Automatic recycling works correctly")

func test_pool_limits():
	print("\n3. Testing Pool Limits...")
	
	var small_pool = NodePool.new()
	small_pool.pool_limit = 3
	small_pool.target_node = TestPooledNode.new()
	
	var nodes = []
	
	# Fill the pool beyond its limit
	for i in range(5):
		var node = small_pool.next()
		nodes.append(node)
	
	print("  Created 5 nodes, pool limit is 3")
	print("  Pool size: ", small_pool.pool.size())
	
	# Return nodes to pool
	for i in range(3):
		nodes[i].queue_free()
		await get_tree().process_frame
	
	print("  After returning 3 nodes, pool size: ", small_pool.pool.size())
	assert(small_pool.pool.size() <= small_pool.pool_limit, "Pool should not exceed its limit")
	
	print("  ✓ Pool limits work correctly")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("\n=== Running Stress Test ===")
		stress_test()

func stress_test():
	print("Creating and recycling ", test_iterations, " nodes...")
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(test_iterations):
		var node = pool.next()
		node.queue_free()
		await get_tree().process_frame
		
		if i % 20 == 0:
			print("  Processed ", i, " nodes, pool size: ", pool.pool.size())
	
	var end_time = Time.get_ticks_msec()
	print("Stress test completed in ", end_time - start_time, "ms")
	print("Final pool size: ", pool.pool.size())

# Simple test node for pooling
class TestPooledNode extends PooledNode:
	static var instance_counter: int = 0
	
	func _init():
		instance_counter += 1
		name = "TestNode_" + str(instance_counter)
	
	func reset_for_pool():
		# Reset any test state
		pass