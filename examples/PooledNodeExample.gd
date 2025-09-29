## Example demonstrating the new NodePool optimization with NOTIFY_PREDELETE
## This shows how developers can use queue_free() normally while nodes get automatically recycled
extends Node

var bullet_hole_pool: NodePool

func _ready():
	# Setup the pool with our new PooledDecal
	bullet_hole_pool = NodePool.new()
	bullet_hole_pool.pool_limit = 20
	
	# Create a template pooled decal
	var template_decal = PooledDecal.new()
	template_decal.lifespan = 30.0  # Bullet holes last 30 seconds
	
	bullet_hole_pool.target_node = template_decal
	add_child(bullet_hole_pool)

func create_bullet_hole(hit_position: Vector3, hit_normal: Vector3, texture: Texture2D):
	# Get a decal from the pool
	var decal_node: PooledDecal = bullet_hole_pool.next()
	
	# Setup the decal
	var hole_size = Vector3(0.1, 0.1, 0.02)
	decal_node.setup_decal(texture, hit_position, hit_normal, hole_size)
	
	# The decal will automatically return to the pool when its lifespan expires
	# Developers can also manually call queue_free() - it will still get recycled!
	
	print("Created bullet hole at ", hit_position)
	print("Pool size: ", bullet_hole_pool.pool.size())

func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Simulate creating bullet holes
		var random_pos = Vector3(randf_range(-5, 5), randf_range(-5, 5), 0)
		var normal = Vector3.BACK
		
		# In a real game, you'd load an actual bullet hole texture
		var texture = ImageTexture.new()
		
		create_bullet_hole(random_pos, normal, texture)
		
		print("Press SPACE to create more bullet holes...")
		print("Notice how nodes are automatically recycled - no manual pool management needed!")