## A node that handles mouse input for an IsometricCamera3D
class_name RTSMouseInput extends Nodot3D

@export var enabled: bool = true
## The ColorRect to use as a selection box
@export var selection_box: ColorRect = ColorRect.new()
## The associated camera (usually an IsometricCamera3D)
@export var camera: Camera3D
## Maximum projection distance (the distance from camera to the ground)
@export var max_projection_distance: float = 500.0

@export_category("Input Actions")
@export var select_action: String = "isometric_camera_select"
@export var action_action: String = "isometric_camera_action"

## Emitted when a node is selected
signal selected(node: Node)
## Emitted when multiple nodes are selected
signal selected_multiple(nodes: Array[Node])
## Emitted when an action is requested
signal action_requested(collision: Dictionary)

var selected_nodes: Array[Node] = []
var mouse_position: Vector2 = Vector2.ZERO
var select_down_position: Vector2 = Vector2.ZERO

func _init():
	register_mouse_actions()

func _ready():
	selection_box.visible = false
	if !selection_box.is_inside_tree():
		add_child(selection_box)

func _input(event):
	if !enabled: return
	
	if event is InputEventMouseMotion:
		mouse_position = event.position
		if selection_box.visible == true:
			var selection_box_size = abs(mouse_position - select_down_position)
			selection_box.set_size(selection_box_size)
			if mouse_position.x > select_down_position.x && mouse_position.y > select_down_position.y:
				selection_box.position = select_down_position
			elif mouse_position.x < select_down_position.x && mouse_position.y < select_down_position.y:
				selection_box.position = mouse_position
			elif mouse_position.x > select_down_position.x:
				selection_box.position = Vector2(mouse_position.x - selection_box_size.x, mouse_position.y)
			else:
				selection_box.position = Vector2(mouse_position.x, mouse_position.y - selection_box_size.y)
	elif event.is_action_pressed(select_action):
		select_down_position = mouse_position
		selection_box.visible = true
		selection_box.set_size(Vector2.ZERO)
	elif event.is_action_released(select_action):
		select()
		selection_box.visible = false
	elif event.is_action_pressed(action_action):
		action()

func get_3d_position(position_2d: Vector2):
	return camera.project_position(position_2d, max_projection_distance)

func select():
	deselect()
	var drag_distance = abs(select_down_position - mouse_position)
	if drag_distance < Vector2(10, 10):
		get_selectable()
	else:
		get_selectables()
		
func get_selectable():
	var collision = get_collision(mouse_position)
	if collision and collision.collider:
		var rts_selectable_node = Nodot.get_first_child_of_type(collision.collider, RTSSelectable)
		if rts_selectable_node:
			rts_selectable_node.select()
			selected_nodes.append(collision.collider)
			emit_signal("selected", collision.collider)
	
func get_selectables():
	var top_left_collision = get_collision(selection_box.position)
	var top_right_collision = get_collision(selection_box.position + Vector2(selection_box.size.x, 0.0))
	var bottom_right_collision = get_collision(selection_box.position + selection_box.size)
	var bottom_left_collision = get_collision(selection_box.position + Vector2(0.0, selection_box.size.y))
	
	if !top_left_collision or !top_right_collision or !bottom_right_collision or !bottom_left_collision: return
	
	var top_left_position = Vector2(top_left_collision.position.x, top_left_collision.position.z)
	var top_right_position = Vector2(top_right_collision.position.x, top_right_collision.position.z)
	var bottom_right_position = Vector2(bottom_right_collision.position.x, bottom_right_collision.position.z)
	var bottom_left_position = Vector2(bottom_left_collision.position.x, bottom_left_collision.position.z)
	
	var selection_box_size = abs(top_left_position - bottom_right_position)
	
	var selection_box_geometry: PackedVector2Array = [top_left_position, top_right_position, bottom_right_position, bottom_left_position]
	for selectable in get_tree().get_nodes_in_group("rts_selectable"):
		var selectable_position = Vector2(selectable.global_position.x, selectable.global_position.z)
		if Geometry2D.is_point_in_polygon(selectable_position, selection_box_geometry):
			selected_nodes.append(selectable)
			Nodot.get_first_child_of_type(selectable, RTSSelectable).select()
	emit_signal("selected_multiple", selected_nodes)
	
func get_collision(target_position: Vector2):
	var projected_position = get_3d_position(target_position)
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = camera.global_position
	params.to = projected_position

	var result = space_state.intersect_ray(params)
	return result

func action():
	var collision = get_collision(mouse_position)
	if collision and collision.collider:
		for selected_node in selected_nodes:
			var rts_selectable = Nodot.get_first_child_of_type(selected_node, RTSSelectable)
			if rts_selectable:
				rts_selectable.action(collision)
		emit_signal("action_requested", collision)
		
func deselect():
	for selected_node in selected_nodes:
		Nodot.get_first_child_of_type(selected_node, RTSSelectable).deselect()
	selected_nodes = []

func register_mouse_actions():
	var action_names = [select_action, action_action]
	var default_keys = [
		MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT
	]
	for i in action_names.size():
		var action_name = action_names[i]
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			InputManager.add_action_event_mouse(action_name, default_keys[i])
