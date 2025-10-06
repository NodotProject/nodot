## A pooled decal node that automatically returns to the pool when freed
## Example usage for bullet holes and other temporary decals
class_name PooledDecal extends PooledNode

@export var decal: Decal
@export var lifespan: float = 10.0

var lifetime_timer: Timer

func _ready():
	if !decal:
		decal = Decal.new()
		add_child(decal)
	
	# Setup lifetime timer
	lifetime_timer = Timer.new()
	lifetime_timer.wait_time = lifespan
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.one_shot = true
	add_child(lifetime_timer)

func _on_lifetime_expired():
	# This will trigger the automatic return to pool via NOTIFY_PREDELETE
	queue_free()

func setup_decal(texture: Texture2D, position: Vector3, normal: Vector3, size: Vector3) -> void:
	decal.texture_albedo = texture
	global_position = position
	decal.size = size
	
	# Align with surface normal
	if normal != Vector3.ZERO:
		global_basis = Basis(Quaternion(Vector3.UP, normal))
	
	# Start the lifetime timer if it exists
	if lifetime_timer:
		lifetime_timer.start()

## Reset the decal state when returned to pool
func reset_for_pool() -> void:
	# Stop and reset timer
	if lifetime_timer:
		lifetime_timer.stop()
	
	# Clear decal properties
	if decal:
		decal.texture_albedo = null
		decal.texture_emission = null
		decal.texture_normal = null
		decal.size = Vector3.ONE
	
	# Reset transform
	global_position = Vector3.ZERO
	global_rotation = Vector3.ZERO
	global_basis = Basis.IDENTITY