# FirstPersonKeyboardInput extends Nodot

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`undefined`|`true`|
|[speed](#speed)|`float`|`5.0`|
|[sprint_speed_multiplier](#sprint_speed_multiplier)|`float`|`3.0`|
|[jump_velocity](#jump_velocity)|`float`|`4.5`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
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

### sprint_speed_multiplier

```gdscript
@export var sprint_speed_multiplier := 3.0
```

How fast the character can move while sprinting

|Name|Type|Default|
|:-|:-|:-|
|`sprint_speed_multiplier`|`float`|`3.0`|

### jump_velocity

```gdscript
@export var jump_velocity = 4.5
```

How high the character can jump

|Name|Type|Default|
|:-|:-|:-|
|`jump_velocity`|`float`|`4.5`|

## Functions

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

