@tool
## A node to position a weapon down the line of sight
class_name FirstPersonIronSight extends Nodot3D

## Whether ironsight zoom is allowed
@export var enabled: bool = true
## The speed to move the camera to the ironsight location
@export var zoom_speed: float = 10.0
## The ironsight field of view
@export var fov: float = 75.0
## Whether to enable a scope view after ironsight zoom is complete
@export var enable_scope: bool = false
## The scope texture that will cover the screen
@export var scope_texture: Texture2D
## The scope field of view
@export var scope_fov: float = 45.0

@onready var parent: FirstPersonItem = get_parent()

var is_editor: bool = Engine.is_editor_hint()
var initial_position: Vector3 = Vector3.INF
var ironsight_target: Vector3 = Vector3.INF
var character_camera: Camera3D
var is_scoped: bool = false
var scope_sprite: Sprite2D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonItem):
		warnings.append("Parent should be a FirstPersonItem")
	return warnings


func _ready() -> void:
	character_camera = parent.get_parent().character.camera
	
	if !is_editor and is_instance_valid(VideoManager):
		VideoManager.connect("window_resized", _on_window_resized)
		VideoManager.bump()
		
	if scope_texture:
		var sprite2d: Sprite2D = Sprite2D.new()
		sprite2d.name = "ScopeTexture"
		sprite2d.set_texture(scope_texture)
		sprite2d.visible = false
		scope_sprite = sprite2d
		add_child(sprite2d)


func _physics_process(delta: float) -> void:
	if ironsight_target == Vector3.INF:
		if initial_position != Vector3.INF:
			parent.position = lerp(parent.position, initial_position, zoom_speed * delta)
			if enable_scope and is_scoped:
				unscope()
	else:
		parent.position = lerp(parent.position, ironsight_target, zoom_speed * delta)
		if enable_scope and !is_scoped and parent.position.is_equal_approx(ironsight_target):
			scope()
		
func _on_window_resized(new_size: Vector2) -> void:
	if scope_sprite:
		var size: Vector2 = scope_sprite.get_texture().get_size()
		var scale_factor = new_size / size
		scope_sprite.scale = scale_factor
		scope_sprite.position = new_size / 2

## Initiates the ironsight zoom and shows scope when it approximately reaches its destination
func zoom() -> void:
	if initial_position == Vector3.INF:
		initial_position = parent.position
	ironsight_target = Vector3.ZERO - position
	if parent.crosshair_node:
		parent.crosshair_node.visible = false
	if enable_scope and parent.position.is_equal_approx(ironsight_target):
		scope()


## Initiates ironsight zoom out
func zoomout() -> void:
	ironsight_target = Vector3.INF
	if parent.crosshair_node:
		parent.crosshair_node.visible = true
	if enable_scope:
		unscope()


## Show the scope image and set the field of view
func scope() -> void:
	is_scoped = true
	character_camera.fov = scope_fov
	scope_sprite.visible = true
	var viable_siblings = get_visible_siblings()
	for sibling in viable_siblings:
		sibling.visible = false


## Hide the scope image and reset the field of view
func unscope() -> void:
	is_scoped = false
	character_camera.fov = fov
	scope_sprite.visible = false
	var viable_siblings = get_visible_siblings()
	for sibling in viable_siblings:
		sibling.visible = true
	

## Gets all siblings that could be in the way of the scope
func get_visible_siblings():
	var viable_siblings: Array[Node3D] = []
	var siblings = Nodot.get_children_of_type(get_parent(), Node3D)
	for sibling in siblings:
		if sibling is BulletHole:
			continue
		if sibling is HitScan3D:
			continue
		if sibling is FirstPersonIronSight:
			continue
		viable_siblings.append(sibling)
	return viable_siblings


## Restores all states to default
func deactivate() -> void:
	if initial_position != Vector3.INF:
		parent.position = initial_position
	zoomout()
