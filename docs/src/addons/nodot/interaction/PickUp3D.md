# PickUp3D extends RayCast3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[pickup_action](#pickup_action)|`String`|`"interact"`|
|[max_mass](#max_mass)|`float`|`10.0`|
|[carry_distance](#carry_distance)|`float`|`2.0`|

## Variables

### pickup_action

```gdscript
@export var pickup_action: String = "interact"
```

The interact input action name

|Name|Type|Default|
|:-|:-|:-|
|`pickup_action`|`String`|`"interact"`|

### max_mass

```gdscript
@export var max_mass: float = 10.0
```

The maximum mass (weight) that can be carried

|Name|Type|Default|
|:-|:-|:-|
|`max_mass`|`float`|`10.0`|

### carry_distance

```gdscript
@export var carry_distance: float = 2.0
```

The distance away from the raycast origin to carry the object

|Name|Type|Default|
|:-|:-|:-|
|`carry_distance`|`float`|`2.0`|

