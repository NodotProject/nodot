# NodePool Optimization with NOTIFY_PREDELETE

## Overview

Nodot's NodePool has been enhanced with an automatic node recycling system that leverages Godot's `NOTIFY_PREDELETE` notification. This optimization allows developers to use `queue_free()` normally while nodes are automatically returned to the pool for reuse, eliminating the need for manual pool management.

## Key Benefits

- **Transparent Pooling**: Game code doesn't need to be aware of the pool
- **Simplified Usage**: Developers can use `queue_free()` as normal
- **Automatic Recycling**: Nodes are automatically returned to the pool instead of being destroyed
- **Better Performance**: Reduces memory allocations and improves performance
- **Backward Compatible**: Works alongside existing NodePool implementations

## Implementation

### PooledNode Base Class

The `PooledNode` class provides automatic pool return functionality:

```gdscript
extends PooledNode

func _ready():
    # Your initialization code here
    pass

func reset_for_pool():
    # Override this to reset node state when returned to pool
    position = Vector3.ZERO
    rotation = Vector3.ZERO
    # Reset any custom properties
```

### Enhanced NodePool

The NodePool automatically sets up pooled nodes and handles returns:

```gdscript
var pool = NodePool.new()
pool.pool_limit = 20
pool.target_node = PooledDecal.new()  # Any PooledNode subclass

# Get a node from the pool
var node = pool.next()  # Automatically sets owner_pool reference

# Use the node normally
node.position = Vector3(10, 0, 0)

# When done, simply queue for deletion - it will return to pool automatically!
node.queue_free()  # Node is recycled, not destroyed
```

## Usage Examples

### Basic Pooled Node

```gdscript
class_name MyPooledEffect extends PooledNode

@export var effect_duration: float = 2.0
var timer: Timer

func _ready():
    timer = Timer.new()
    timer.wait_time = effect_duration
    timer.timeout.connect(_on_effect_finished)
    timer.one_shot = true
    add_child(timer)

func start_effect():
    timer.start()
    # Play animations, particles, etc.

func _on_effect_finished():
    # This will automatically return the node to the pool
    queue_free()

func reset_for_pool():
    # Reset state when returned to pool
    timer.stop()
    position = Vector3.ZERO
    # Reset any other properties
```

### Pooled Decal (Bullet Holes)

```gdscript
var bullet_hole_pool = NodePool.new()
bullet_hole_pool.pool_limit = 50
bullet_hole_pool.target_node = PooledDecal.new()

func create_bullet_hole(hit_position: Vector3, hit_normal: Vector3, texture: Texture2D):
    var decal: PooledDecal = bullet_hole_pool.next()
    decal.setup_decal(texture, hit_position, hit_normal, Vector3(0.1, 0.1, 0.02))
    
    # Decal will automatically return to pool after its lifespan
    # No manual cleanup needed!
```

### Projectiles with Auto-Pooling

```gdscript
class_name PooledProjectile extends PooledNode

@export var speed: float = 50.0
@export var lifetime: float = 5.0

func _ready():
    # Setup projectile physics
    get_tree().create_timer(lifetime).timeout.connect(queue_free)

func fire(direction: Vector3):
    # Apply velocity, start movement
    velocity = direction * speed

func _on_impact():
    # Handle collision effects
    queue_free()  # Automatically returns to pool

func reset_for_pool():
    # Reset projectile state
    velocity = Vector3.ZERO
    position = Vector3.ZERO
    # Reset any damage effects, trails, etc.
```

## Migration Guide

### From Traditional NodePool

**Before (Manual Management):**
```gdscript
# Old way - manual pool management
var node = pool.next()
# ... use node ...
# Manually return to pool
if node.get_parent():
    node.get_parent().remove_child(node)
pool.add_to_pool(node)  # Manual return method
```

**After (Automatic):**
```gdscript
# New way - automatic pooling
var node = pool.next()  # Must be a PooledNode
# ... use node ...
node.queue_free()  # Automatically returns to pool!
```

### Updating Existing Systems

1. **Change your template node** to extend `PooledNode` instead of `Node`
2. **Implement `reset_for_pool()`** to clean up state
3. **Replace manual pool returns** with `queue_free()` calls
4. **Remove cleanup timers** - let node lifespan handle it

## Technical Details

### How It Works

1. When `pool.next()` is called on a `PooledNode`, the pool sets `node.owner_pool = pool`
2. When `queue_free()` is called on the node, `NOTIFY_PREDELETE` is triggered
3. The `PooledNode._notification()` method catches this and calls `cancel_free()`
4. The node calls `owner_pool.return_to_pool(self)` to return itself
5. The pool calls `reset_for_pool()` and removes the node from its parent
6. The node is added back to the pool for reuse

### Pool Behavior

- Pool maintains its size limit by replacing oldest nodes when full
- Nodes are prevented from being added multiple times
- Invalid nodes are automatically cleaned up
- Compatible with both pooled and regular nodes

## Best Practices

1. **Always implement `reset_for_pool()`** to ensure clean state
2. **Use reasonable lifespans** to prevent memory buildup
3. **Test with different pool sizes** to find optimal performance
4. **Prefer composition over inheritance** for complex pooled objects
5. **Document pooled node behavior** for team members

## Compatibility

- **Godot Version**: Requires Godot 4.0+
- **Backward Compatibility**: Existing NodePool code continues to work
- **Performance**: No overhead for non-pooled nodes
- **Memory**: Reduced allocations with automatic recycling