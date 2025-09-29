# SprayPattern Node

The `SprayPattern` node is a reusable, customizable Godot 4.5 node that defines and manages recoil and spray behaviors for firearms. It integrates seamlessly with existing `Weapon`, `Magazine`, and `FirstPersonItem` nodes.

## Features

- **Customizable Spray Control**: Uses `Curve2D` resources to define spray patterns where x-axis represents shots fired and y-axis represents recoil offset
- **Stateful Recoil Tracking**: Tracks current shot index and heat level for pattern progression
- **Randomness Support**: Configurable pitch and yaw randomness for realistic spray variation
- **Automatic Recovery**: View recenters after shooting stops with configurable speed
- **Time-based Reset**: Pattern resets after configurable cooldown period
- **Loop Support**: Patterns can loop or stop at the end
- **Signal Integration**: Emits signals for synchronization with camera and weapon systems

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `base_curve` | Curve2D | auto-generated | The spray pattern curve (x=shot index, y=recoil offset) |
| `recovery_speed` | float | 5.0 | Speed at which view recenters after shooting stops |
| `apply_speed` | float | 10.0 | Speed at which recoil is applied |
| `randomness_pitch` | float | 0.1 | Additive randomness for vertical recoil |
| `randomness_yaw` | float | 0.1 | Additive randomness for horizontal recoil |
| `reset_after_ms` | int | 500 | Time in milliseconds before pattern resets |
| `loop_pattern` | bool | false | Whether the pattern loops when it reaches the end |

## Signals

- `spray_offset_updated(offset: Vector2, shot_index: int)` - Emitted when recoil is applied
- `pattern_reset()` - Emitted when the spray pattern resets after cooldown

## Usage

### Basic Setup

1. Add a `SprayPattern` node as a child of your `FirstPersonItem`
2. Create or assign a `Curve2D` resource to define your spray pattern
3. The `FirstPersonItem` will automatically detect and connect the spray pattern to magazine discharge events

```gdscript
# Example: Creating a spray pattern in code
var spray_pattern = SprayPattern.new()
var curve = Curve2D.new()

# Define spray pattern points (x=shot number, y=recoil strength)
curve.add_point(Vector2(0.0, 0.0))    # First shot: no recoil
curve.add_point(Vector2(1.0, 0.2))    # Second shot: small upward recoil
curve.add_point(Vector2(2.0, 0.5))    # Third shot: medium upward recoil
curve.add_point(Vector2(3.0, 1.0))    # Fourth shot: strong upward recoil

spray_pattern.base_curve = curve
spray_pattern.randomness_pitch = 0.1  # Add some vertical randomness
spray_pattern.randomness_yaw = 0.05   # Add some horizontal randomness
```

### Integration with Camera

Connect to the `spray_offset_updated` signal to apply recoil to your camera:

```gdscript
# In your camera controller or weapon manager
first_person_item.spray_offset_updated.connect(_on_spray_offset_updated)

func _on_spray_offset_updated(offset: Vector2, shot_index: int):
    # Apply offset to camera rotation (offset.x = pitch, offset.y = yaw)
    camera.rotation.x += offset.x * recoil_sensitivity
    camera.rotation.y += offset.y * recoil_sensitivity
```

### Integration with Bullet Direction

The same offset should be applied to bullet raycast direction for synchronization:

```gdscript
# In your HitScan3D or projectile system
func apply_spray_offset(direction: Vector3, spray_offset: Vector2) -> Vector3:
    # Apply spray offset to bullet direction
    var pitch_rotation = spray_offset.x
    var yaw_rotation = spray_offset.y
    
    # Create rotation matrix and apply to direction
    var rotation = Vector3(pitch_rotation, yaw_rotation, 0.0)
    return direction.rotated(Vector3.UP, yaw_rotation).rotated(Vector3.RIGHT, pitch_rotation)
```

## Weapon Examples

### SMG Pattern
```gdscript
# Short, fast pattern with high randomness
spray_pattern.recovery_speed = 8.0
spray_pattern.randomness_pitch = 0.15
spray_pattern.randomness_yaw = 0.1
spray_pattern.reset_after_ms = 300
spray_pattern.loop_pattern = true
```

### Assault Rifle Pattern
```gdscript
# Longer pattern with predictable spray
spray_pattern.recovery_speed = 4.0
spray_pattern.randomness_pitch = 0.05
spray_pattern.randomness_yaw = 0.03
spray_pattern.reset_after_ms = 800
spray_pattern.loop_pattern = false
```

### Shotgun Pattern
```gdscript
# Strong initial kick, minimal pattern
spray_pattern.apply_speed = 20.0
spray_pattern.recovery_speed = 6.0
spray_pattern.randomness_pitch = 0.3
spray_pattern.randomness_yaw = 0.2
spray_pattern.reset_after_ms = 1000
```

## API Reference

### Methods

- `get_next_offset() -> Vector2` - Get the next offset in the spray pattern
- `reset_pattern() -> void` - Manually reset the spray pattern
- `get_current_offset() -> Vector2` - Get the current accumulated offset
- `get_current_shot_index() -> int` - Get the current shot index in the pattern

### Notes

- The SprayPattern automatically integrates with Magazine discharge events when used as a child of FirstPersonItem
- Offsets are cumulative - each shot adds to the total recoil
- Recovery gradually moves the offset back to zero when not shooting
- Pattern resets automatically after the specified cooldown period