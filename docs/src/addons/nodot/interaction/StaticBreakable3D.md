# StaticBreakable3D extends StaticBody3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[replacement_node](#replacement_node)|`Node3D`|-|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[action](#action)|||
|[find_closest_child](#find_closest_child)|||
|[save_impulse](#save_impulse)|`Vector3`|-|

## Variables

### replacement_node

```gdscript
@export var replacement_node: Node3D
```

A node to replace the breakable with that contains all the smaller parts

|Name|Type|Default|
|:-|:-|:-|
|`replacement_node`|`Node3D`|-|

## Functions

### action

```gdscript
func action() -> void
```

Perform the break

### find_closest_child

```gdscript
func find_closest_child()
```

Find the closest child to the saved_impulse_position (hit position)

### save_impulse

```gdscript
func save_impulse(impulse_direction: Vector3, impulse_position: Vector3, _origin_position: Vector3) -> void
```

Used to save data from impact events

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`impulse_direction`|`Vector3`|-|
|`impulse_position`|`Vector3`|-|
|`_origin_position`|`Vector3`|-|

