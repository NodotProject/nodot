# Explosion3D extends Nodot3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[effect_time](#effect_time)|`float`|`1.0`|
|[force_range](#force_range)|`float`|`10.0`|
|[max_force](#max_force)|`float`|`3.0`|
|[damage_range](#damage_range)|`float`|`5.0`|
|[max_damage](#max_damage)|`float`|`100.0`|
|[min_damage](#min_damage)|`float`|`0.0`|
|[healing](#healing)|`undefined`|`false`|

## Variables

### effect_time

```gdscript
@export var effect_time := 1.0
```

How long to play the effect

|Name|Type|Default|
|:-|:-|:-|
|`effect_time`|`float`|`1.0`|

### force_range

```gdscript
@export var force_range := 10.0
```

Range to apply force

|Name|Type|Default|
|:-|:-|:-|
|`force_range`|`float`|`10.0`|

### max_force

```gdscript
@export var max_force := 3.0
```

Maximum force to apply

|Name|Type|Default|
|:-|:-|:-|
|`max_force`|`float`|`3.0`|

### damage_range

```gdscript
@export var damage_range := 5.0
```

Range to apply damage

|Name|Type|Default|
|:-|:-|:-|
|`damage_range`|`float`|`5.0`|

### max_damage

```gdscript
@export var max_damage := 100.0
```

Maximum damage to receive (closer to the center = higher damage)

|Name|Type|Default|
|:-|:-|:-|
|`max_damage`|`float`|`100.0`|

### min_damage

```gdscript
@export var min_damage := 0.0
```

Minimum damage to receive

|Name|Type|Default|
|:-|:-|:-|
|`min_damage`|`float`|`0.0`|

### healing

```gdscript
@export var healing := false
```

Heals instead of damages

|Name|Type|Default|
|:-|:-|:-|
|`healing`|`undefined`|`false`|

