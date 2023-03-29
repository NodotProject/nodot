# Projectile3D extends RigidBody3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[speed](#speed)|`float`|`50.0`|
|[self_propelling](#self_propelling)|`bool`|`true`|
|[lifespan](#lifespan)|`float`|`0.0`|
|[destroy_on_impact](#destroy_on_impact)|`bool`|`false`|

## Variables

### speed

```gdscript
@export var speed : float = 50.0
```

The speed of the projectile

|Name|Type|Default|
|:-|:-|:-|
|`speed`|`float`|`50.0`|

### self_propelling

```gdscript
@export var self_propelling : bool = true
```

Applies the speed consistently

|Name|Type|Default|
|:-|:-|:-|
|`self_propelling`|`bool`|`true`|

### lifespan

```gdscript
@export var lifespan : float = 0.0
```

Destroys the projectile after this timespan (0.0 for never)

|Name|Type|Default|
|:-|:-|:-|
|`lifespan`|`float`|`0.0`|

### destroy_on_impact

```gdscript
@export var destroy_on_impact : bool = false
```

Destroys the projectile on impact

|Name|Type|Default|
|:-|:-|:-|
|`destroy_on_impact`|`bool`|`false`|

