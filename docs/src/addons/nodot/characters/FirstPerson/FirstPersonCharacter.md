# FirstPersonCharacter extends CharacterBody3D

A CharacterBody3D for first person games

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[input_enabled](#input_enabled)|`undefined`|`true`|
|[fov](#fov)|`float`|`75.0`|
|[head_position](#head_position)|`Vector3`|`Vector3.ZERO`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[disable_input](#disable_input)|||
|[enable_input](#enable_input)|||

## Variables

### input_enabled

```gdscript
@export var input_enabled := true
```

Allow player input

|Name|Type|Default|
|:-|:-|:-|
|`input_enabled`|`undefined`|`true`|

### fov

```gdscript
@export var fov := 75.0
```

The camera field of view

|Name|Type|Default|
|:-|:-|:-|
|`fov`|`float`|`75.0`|

### head_position

```gdscript
@export var head_position := Vector3.ZERO
```

The head position

|Name|Type|Default|
|:-|:-|:-|
|`head_position`|`Vector3`|`Vector3.ZERO`|

## Functions

### disable_input

```gdscript
func disable_input() -> void
```

Disable player input

### enable_input

```gdscript
func enable_input() -> void
```

Enable player input

