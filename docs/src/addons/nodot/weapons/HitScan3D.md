# HitScan3D extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`undefined`|`false`|
|[raycast](#raycast)|`RayCast3D`|-|
|[accuracy](#accuracy)|`float`|`0.0`|
|[damage](#damage)|`float`|`0.0`|
|[damage_distance_reduction](#damage_distance_reduction)|`float`|`0.0`|
|[distance](#distance)|`int`|`500`|
|[healing](#healing)|`undefined`|`false`|

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
@export var enabled = false
```

Whether to enable the hitscan or not

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`undefined`|`false`|

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
@export var accuracy := 0.0
```

The accuracy of the shot (0.0 = 100% accurate)

|Name|Type|Default|
|:-|:-|:-|
|`accuracy`|`float`|`0.0`|

### damage

```gdscript
@export var damage = 0.0
```

How much damage to deal to the target (0.0 to disable)

|Name|Type|Default|
|:-|:-|:-|
|`damage`|`float`|`0.0`|

### damage_distance_reduction

```gdscript
@export var damage_distance_reduction = 0.0
```

Damage reduction per meter of distance as a percentage (0.0 to disable)

|Name|Type|Default|
|:-|:-|:-|
|`damage_distance_reduction`|`float`|`0.0`|

### distance

```gdscript
@export var distance := 500
```

Total distance (meters) to search for hit targets

|Name|Type|Default|
|:-|:-|:-|
|`distance`|`int`|`500`|

### healing

```gdscript
@export var healing := false
```

Reverses the damage to heal instead

|Name|Type|Default|
|:-|:-|:-|
|`healing`|`undefined`|`false`|

## Functions

### action

```gdscript
func action()
```

Execute the hitscan

### aim_raycast

```gdscript
func aim_raycast()
```

Point the raycast at the target with a random offset based on accuracy

### get_hit_target

```gdscript
func get_hit_target()
```

Get the objects that the raycast is colliding with

### get_distance

```gdscript
func get_distance(object: Variant)
```

Returns the distance from the raycast origin to the target

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`object`|`Variant`|-|

