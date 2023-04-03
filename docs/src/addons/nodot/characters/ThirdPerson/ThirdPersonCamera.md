# ThirdPersonCamera extends Camera3D

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[camera_offset](#camera_offset)|`0`|`Vector3(0, 2, 5)`|
|[always_in_front](#always_in_front)|`undefined`|`true`|
|[time_to_reset](#time_to_reset)|`float`|`2.0`|

## Variables

### camera_offset

```gdscript
@export var camera_offset := Vector3(0, 2, 5)
```

Camera default offset

|Name|Type|Default|
|:-|:-|:-|
|`camera_offset`|`0`|`Vector3(0, 2, 5)`|

### always_in_front

```gdscript
@export var always_in_front := true
```

Camera should move in front of objects that block vision of the character

|Name|Type|Default|
|:-|:-|:-|
|`always_in_front`|`undefined`|`true`|

### time_to_reset

```gdscript
@export var time_to_reset: float = 2.0
```

Move the camera to the initial position after some inactivity (0.0 to disable)

|Name|Type|Default|
|:-|:-|:-|
|`time_to_reset`|`float`|`2.0`|

