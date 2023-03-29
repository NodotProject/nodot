# FirstPersonMouseInput extends Nodot

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[enabled](#enabled)|`undefined`|`true`|
|[mouse_sensitivity](#mouse_sensitivity)|`float`|`0.1`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[disable](#disable)|||
|[enable](#enable)|||

## Variables

### enabled

```gdscript
@export var enabled := true
```

Is input enabled

|Name|Type|Default|
|:-|:-|:-|
|`enabled`|`undefined`|`true`|

### mouse_sensitivity

```gdscript
@export var mouse_sensitivity := 0.1
```

Sensitivity of mouse movement

|Name|Type|Default|
|:-|:-|:-|
|`mouse_sensitivity`|`float`|`0.1`|

## Functions

### disable

```gdscript
func disable() -> void
```

Disable input and release mouse

### enable

```gdscript
func enable() -> void
```

Enable input and capture mouse

