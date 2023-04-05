# HitScan3D extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`bool`|`false`|
|[raycast](#raycast)|`RayCast3D`|-|
|[accuracy](#accuracy)|`float`|`0.0`|
|[damage](#damage)|`float`|`0.0`|
|[damage_distance_reduction](#damage_distance_reduction)|`float`|`0.0`|
|[distance](#distance)|`float`|`500`|
|[applied_force](#applied_force)|`float`|`1.0`|
|[healing](#healing)|`bool`|`false`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[action](#action)|||
|[aim_raycast](#aim_raycast)|||
|[get_hit_target](#get_hit_target)|||
|[get_distance](#get_distance)|`Variant`|-|

## Variables

### enabled

```gdscript
@export var enabled: bool = false
```

Whether to enable the hitscan or not

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`bool`|`false`|

### raycast

```gdscript
@export var raycast: RayCast3D
```

Which raycast to use

|Name|Type|Default|
|:-|:-|:-|
|`raycast`|`RayCast3D`|-|

### accuracy

```gdscript
@export var accuracy : float = 0.0
```

The accuracy of the shot (0.0 = 100% accurate)

|Name|Type|Default|
|:-|:-|:-|
|`accuracy`|`float`|`0.0`|

### damage

```gdscript
@export var damage: float = 0.0
```

How much damage to deal to the target (0.0 to disable)

|Name|Type|Default|
|:-|:-|:-|
|`damage`|`float`|`0.0`|

### damage_distance_reduction

```gdscript
@export var damage_distance_reduction: float = 0.0
```

Damage reduction per meter of distance as a percentage (0.0 to disable)

|Name|Type|Default|
|:-|:-|:-|
|`damage_distance_reduction`|`float`|`0.0`|

### distance

```gdscript
@export var distance : float = 500
```

Total distance (meters) to search for hit targets

|Name|Type|Default|
|:-|:-|:-|
|`distance`|`float`|`500`|

### applied_force

```gdscript
@export var applied_force: float = 1.0
```

Amount of applied force to a RigidBody3D on impact

|Name|Type|Default|
|:-|:-|:-|
|`applied_force`|`float`|`1.0`|

### healing

```gdscript
@export var healing : bool = false
```

Reverses the damage to heal instead

|Name|Type|Default|
|:-|:-|:-|
|`healing`|`bool`|`false`|

## Functions

### action

```gdscript
func action()
```

Execute the hitscan TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162

### aim_raycast

```gdscript
func aim_raycast() -> void
```

Point the raycast at the target with a random offset based on accuracy

### get_hit_target

```gdscript
func get_hit_target()
```

Get the objects that the raycast is colliding with TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162

### get_distance

```gdscript
func get_distance(object: Variant) -> float
```

Returns the distance from the raycast origin to the target

**Returns**: `float`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`object`|`Variant`|-|

