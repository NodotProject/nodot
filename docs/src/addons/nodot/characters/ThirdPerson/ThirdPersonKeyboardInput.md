# ThirdPersonKeyboardInput extends Nodot

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`undefined`|`true`|
|[speed](#speed)|`float`|`5.0`|
|[turn_rate](#turn_rate)|`float`|`0.1`|
|[jump_velocity](#jump_velocity)|`float`|`4.5`|
|[strafing](#strafing)|`undefined`|`false`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[face_target](#face_target)|`Vector3`|-|
|[disable](#disable)|||
|[enable](#enable)|||

## Variables

### enabled

```gdscript
@export var enabled = true
```

Is input enabled

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`undefined`|`true`|

### speed

```gdscript
@export var speed := 5.0
```

How fast the character can move

|Name|Type|Default|
|:-|:-|:-|
|`speed`|`float`|`5.0`|

### turn_rate

```gdscript
@export var turn_rate := 0.1
```

How fast the player turns to face a direction

|Name|Type|Default|
|:-|:-|:-|
|`turn_rate`|`float`|`0.1`|

### jump_velocity

```gdscript
@export var jump_velocity = 4.5
```

How high the character can jump

|Name|Type|Default|
|:-|:-|:-|
|`jump_velocity`|`float`|`4.5`|

### strafing

```gdscript
@export var strafing := false
```

Instead of turning the character, the character will strafe on left and right input action

|Name|Type|Default|
|:-|:-|:-|
|`strafing`|`undefined`|`false`|

## Functions

### face_target

```gdscript
func face_target(target_position: Vector3, weight: float) -> void
```

Turn to face the target. Essentially lerping look_at

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`target_position`|`Vector3`|-|
|`weight`|`float`|-|

### disable

```gdscript
func disable() -> void
```

Disable input

### enable

```gdscript
func enable() -> void
```

Enable input

