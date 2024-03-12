@tool
## A raycast for interacting with, picking up, carrying and re-orienting objects
class_name Interaction3D extends RayCast3D

## Triggered when starting to carry an object
signal carry_started(carried_node: Node3D)
## Triggered when dropping an object that was being carried
signal carry_ended(carried_node: Node3D)
## Triggered when the interact function on an object was fired
signal interacted(interacted_node: Node3D, collision_point: Vector3, collision_normal: Vector3)

## The interact input action name
@export var interact_action: String = "interact"
## The font color of the interaction label
@export var font_color: Color = Color.WHITE
## The font size of the interaction label
@export var font_size: int = 18
## Enable the pick up functionality
@export var enable_pickup: bool = true
## The maximum mass (weight) that can be carried
@export var max_mass: float = 10.0
## The distance away from the raycast origin to carry the object
@export var carry_distance: float = 2.0
## The maximum distance away from the raycast origin before the object is dropped
@export var max_carry_distance: float = 2.0
## The force of throwing the carried body
@export var throw_force: float = 250.0;
## The Close Carry body position Node
@export var carry_position_node: Node3D;


# RigidBody3D or null being carried
var carried_body: RigidBody3D
var carried_body_gravity_scale: float = 1.0
var carried_body_width: float = 0.0
var is_close_body_carry: bool = false;
var label3d: Label3D
var last_collider: Node3D
var last_focussed_collider: Node3D;
var carried_body_prev_mask: int = 1;

func _enter_tree():
	label3d = Label3D.new()
	label3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label3d.fixed_size = true
	label3d.pixel_size = 0.001
	label3d.no_depth_test = true
	label3d.font_size = font_size
	label3d.modulate = font_color
	label3d.position.z = -2
	label3d.render_priority = 5
	label3d.outline_render_priority = 4
	label3d.no_depth_test = true
	add_child(label3d)
	
func _ready():
	if not is_multiplayer_authority(): return
	
	InputManager.register_action(interact_action, KEY_F)

func _input(event: InputEvent):
	if !enabled or !event.is_action_pressed(interact_action) or !is_multiplayer_authority(): return
		
	var collider = get_collider()
	if !is_instance_valid(collider):
		if is_instance_valid(carried_body):
			carry_end();
		return

	emit_signal("interacted", collider, get_collision_point(), get_collision_normal())
	if collider.has_method("interact"):
		collider.interact()
		GlobalSignal.trigger_signal("interacted", [collider, get_collision_point(), get_collision_normal()]);
	else:
		if is_instance_valid(carried_body):
			carry_end();
		else:
			carry_begin(collider)


func _physics_process(delta):	
	if is_instance_valid(carried_body):
		if not multiplayer.is_server(): return
		if not is_close_body_carry:
			var carry_position = global_transform.origin - global_transform.basis.z.normalized() * (carry_distance + carried_body_width)
			var current_carry_distance = carried_body.global_position.distance_to(global_position)
			if current_carry_distance > carry_distance + max_carry_distance:
				carry_end();
				return
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				throw();
				return;
			var speed = carried_body.global_position.distance_to(carry_position) * 600
			carried_body.linear_velocity = carried_body.global_transform.origin.direction_to(carry_position) * speed * delta
		else:
			var carry_position = carry_position_node.global_position;
			carried_body.set_collision_layer_value(1, false);
			carried_body.global_position = carry_position;
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var prev_carried_body = carried_body;
				throw();
				await get_tree().create_timer(0.35).timeout;
				prev_carried_body.set_collision_layer_value(1, carried_body_prev_mask);
				return;
		var rotate_speed: float = 10.0 * delta
		carried_body.global_rotation.x = lerp_angle(carried_body.global_rotation.x, 0.0, rotate_speed)
		carried_body.global_rotation.z = lerp_angle(carried_body.global_rotation.z, 0.0, rotate_speed)
		carried_body.global_rotation.y = lerp_angle(carried_body.global_rotation.y, global_rotation.y, rotate_speed)
	
		var collider = get_collider()
		if is_instance_valid(collider):
			if is_instance_valid(last_focussed_collider) and collider != last_focussed_collider:
				if last_focussed_collider.has_method("unfocussed"):
					last_focussed_collider.unfocussed();
			if collider.has_method("focussed"):
				last_focussed_collider = collider;
				collider.focussed();
		else:
			if last_focussed_collider and last_focussed_collider.has_method("unfocussed"):
					last_focussed_collider.unfocussed();
	else:
		if not is_multiplayer_authority(): return
		
		var collider = get_collider()
		if is_instance_valid(last_collider) and last_collider != collider:
			collide_ended(last_collider)
		last_collider = collider

		if is_instance_valid(collider):
			if collider.has_method("label"):
				label3d.text = collider.label()
			else:
				label3d.text = ""

			if collider.has_method("focussed"):
				collider.focussed()
		else:
			label3d.text = ""


func carry_begin(collider: Node):
	if enable_pickup and is_instance_valid(collider) and collider is RigidBody3D and collider.mass <= max_mass:
		carried_body = collider
		is_close_body_carry = carried_body.has_meta("carry_close") and carried_body.get_meta("carry_close")
		carried_body_gravity_scale = collider.gravity_scale
		var carried_body_mesh: MeshInstance3D = Nodot.get_first_child_of_type(carried_body, MeshInstance3D)
		if carried_body_mesh:
			var mesh_size = carried_body_mesh.get_aabb().size
			carried_body_width = max(mesh_size.x * carried_body_mesh.scale.x, mesh_size.y * carried_body_mesh.scale.y, mesh_size.z * carried_body_mesh.scale.z)
		carried_body.gravity_scale = 0.0
		carried_body_prev_mask = carried_body.get_collision_mask_value(1);
		emit_signal("carry_started", carried_body)
		GlobalSignal.trigger_signal("carry_started", carried_body);


func carry_end():
	if is_instance_valid(carried_body):
		if is_close_body_carry:
			carried_body.set_collision_layer_value(1, carried_body_prev_mask);
		carried_body.gravity_scale = carried_body_gravity_scale
		emit_signal("carry_ended", carried_body)
		GlobalSignal.trigger_signal("carry_ended", carried_body);
		carried_body = null


func throw():
	if is_instance_valid(carried_body):
		carried_body.gravity_scale = carried_body_gravity_scale
		carried_body.apply_force(-global_transform.basis.z * throw_force);
		emit_signal("carry_ended", carried_body);
		GlobalSignal.trigger_signal("carry_ended", carried_body);
		carried_body = null


func collide_ended(body: Node3D):
	label3d.text = ""
	if body.has_method("unfocussed"):
		body.unfocussed()
