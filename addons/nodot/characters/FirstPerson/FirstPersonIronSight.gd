class_name FirstPersonIronSight extends Nodot3D

## Whether ironsight zoom is allowed
@export var enabled := true
## The speed to move the camera to the ironsight location
@export var zoom_speed := 1.0
## The ironsight field of view
@export var fov := 75
## Whether to enable a scope view after ironsight zoom is complete
@export var enable_scope := false
## The scope texture that will cover the screen
@export var scope_texture: Texture2D
## The scope field of view
@export var scope_fov := 45
