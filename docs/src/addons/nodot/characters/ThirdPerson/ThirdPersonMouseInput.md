# ThirdPersonMouseInput extends Nodot

## Table of contents

### Variables

|Name|Type|Default|
|:-|:-|:-|
|[camera_rotate_action](#camera_rotate_action)|`String`|`"camera_rotate"`|
|[enabled](#enabled)|`undefined`|`true`|
|[mouse_sensitivity](#mouse_sensitivity)|`float`|`0.1`|
|[lock_camera_rotation](#lock_camera_rotation)|`undefined`|`false`|
|[lock_character_rotation](#lock_character_rotation)|`undefined`|`false`|
|[vertical_clamp](#vertical_clamp)|`-1.36`|`Vector2(-1.36, 1.4)`|

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[disable](#disable)|||
|[enable](#enable)|||

## Variables

### camera_rotate_action

```gdscript
@export var camera_rotate_action : String = "camera_rotate"
```

Input action for enabling camera rotation

|Name|Type|Default|
|:-|:-|:-|
|`camera_rotate_action`|`String`|`"camera_rotate"`|

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

### lock_camera_rotation

```gdscript
@export var lock_camera_rotation := false
```

Enable camera movement only while camera_rotate_action input action is pressed

|Name|Type|Default|
|:-|:-|:-|
|`lock_camera_rotation`|`undefined`|`false`|

### lock_character_rotation

```gdscript
@export var lock_character_rotation := false
```

Rotate the ThirdPersonCharacter with the camera

|Name|Type|Default|
|:-|:-|:-|
|`lock_character_rotation`|`undefined`|`false`|

### vertical_clamp

```gdscript
@export var vertical_clamp := Vector2(-1.36, 1.4)
```

Restrict vertical look angle

|Name|Type|Default|
|:-|:-|:-|
|`vertical_clamp`|`-1.36`|`Vector2(-1.36, 1.4)`|

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

