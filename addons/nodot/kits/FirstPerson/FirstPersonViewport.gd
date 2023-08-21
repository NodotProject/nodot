## Creates a viewport that can be used for first person items. For example hands and guns.
class_name FirstPersonViewport extends SubViewportContainer

## The character the viewport is attached to
@export var character: FirstPersonCharacter
## Which cull mask layers to give the camera
@export_flags_3d_render var camera_cull_mask_layer: int = 2
## The viewport cameras field of view
@export var fov: float = 75.0
## (optional) The first person viewport camera
@export var viewport_camera: Camera3D
## The input action name for reloading the current active weapon
@export var reload_action: String = "reload"

var character_camera: Camera3D
var viewport: SubViewport

signal item_change(item: FirstPersonItem)

var item_changing: bool = false
var active_item_index: int = 0


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !(get_parent() is FirstPersonCharacter):
		warnings.append("Parent should be a FirstPersonCharacter")
	return warnings


func _enter_tree() -> void:
		
	var subviewport: SubViewport = SubViewport.new()
	subviewport.name = "SubViewport"
	subviewport.transparent_bg = true
	subviewport.handle_input_locally = false
	
	var camera3d: Camera3D = Camera3D.new()
	camera3d.name = "Camera3D"
	camera3d.cull_mask = camera_cull_mask_layer
	camera3d.fov = fov
	
	subviewport.add_child(camera3d)
	add_child(subviewport)
	
	viewport = subviewport
	viewport_camera = camera3d

func _ready() -> void:
	# Move existing children to be a child of the camera
	for child in get_children():
		if "transform" in child and not child is SubViewport:
			var saved_transform: Transform3D = child.transform
			child.reparent(viewport_camera, true)

	if is_instance_valid(VideoManager):
		VideoManager.connect("window_resized", _on_window_resized)
		VideoManager.bump()

func _process(delta: float) -> void:
	if !viewport_camera or !character.is_authority(): return
	
	viewport_camera.global_transform = character.camera.global_transform
	viewport_camera.rotation.z = 0.0
	
func _input(event: InputEvent) -> void:
	if not character.is_authority(): return
	
	if InputMap.has_action(reload_action) and event.is_action_pressed(reload_action):
		reload()


func _on_window_resized(new_size: Vector2) -> void:
	if not character.is_authority(): return
	viewport.size = new_size


## Select the next item
func next_item() -> void:
	change_item(active_item_index + 1)


## Select the previous item
func previous_item() -> void:
	change_item(active_item_index - 1)


## Get the active item if there is one
## TODO: Typehint this when nullable static types are supported. https://github.com/godotengine/godot-proposals/issues/162
func get_active_item():
	if not character.is_authority(): return
	
	var items = Nodot.get_children_of_type(viewport_camera, FirstPersonItem)
	for item in items:
		if item.active:
			return item


## Get all FirstPersonItems
func get_all_items() -> Array:
	return Nodot.get_children_of_type(viewport_camera, FirstPersonItem)


## Change which item is active.
func change_item(new_index: int) -> void:
	var items: Array = get_all_items()
	var item_count: int = items.size()
	if item_count == 0: return
	if item_changing == true: return
	item_changing = true
	
	if new_index >= item_count - 1:
		active_item_index = item_count - 1
	elif new_index <= 0:
		active_item_index = 0
	else:
		active_item_index = new_index
		
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item:
		await (active_item as FirstPersonItem).deactivate()
	
	await items[active_item_index].activate()
	item_changing = false
	emit_signal("item_change", items[active_item_index])

func action() -> void:
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("action"):
		(active_item as FirstPersonItem).action()


func zoom() -> void:
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("zoom"):
		(active_item as FirstPersonItem).zoom()


func zoomout() -> void:
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("zoomout"):
		(active_item as FirstPersonItem).zoomout()


func reload() -> void:
	# TODO: Typehint this when nullable static types are supported.
	# https://github.com/godotengine/godot-proposals/issues/162
	var active_item = get_active_item()
	if active_item and active_item.has_method("reload"):
		(active_item as FirstPersonItem).reload()

func hide():
	if viewport and viewport_camera:
		viewport_camera.current = false
		viewport_camera.visible = false

func show():
	if viewport and viewport_camera:
		viewport_camera.current = true
		viewport_camera.visible = true
