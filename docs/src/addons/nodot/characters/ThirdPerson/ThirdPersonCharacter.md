# ThirdPersonCharacter extends CharacterBody3D

A CharacterBody3D for third person games

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[escape_action](#escape_action)|`String`|`"escape"`|
|[input_enabled](#input_enabled)|`undefined`|`true`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[disable_input](#disable_input)|||
|[enable_input](#enable_input)|||

## Variables

### escape_action

```gdscript
@export var escape_action : String = "escape"
```

The input action to pause input

|Name|Type|Default|
|:-|:-|:-|
|`escape_action`|`String`|`"escape"`|

### input_enabled

```gdscript
@export var input_enabled := true
```

Allow player input

|Name|Type|Default|
|:-|:-|:-|
|`input_enabled`|`undefined`|`true`|

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

