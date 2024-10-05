## A raycast for interacting with, picking up, carrying and re-orienting objects
class_name Interaction3D extends RayCast3D

## Triggered when starting to carry an object
signal carry_started(carried_node: Node3D)
## Triggered when dropping an object that was being carried
signal carry_ended(carried_node: Node3D)
## Triggered when the interact function on an object was fired
signal interacted(interacted_node: Node3D, collision_point: Vector3, collision_normal: Vector3)
## Interaction label updated
signal interaction_label_updated(message: String)

## The interact input action name
@export var interact_action: String = "interact"
## Enable the pick up functionality
@export var enable_pickup: bool = true
## The maximum mass (weight) that can be carried
@export var max_mass: float = 10.0
## The distance away from the raycast origin to carry the object
@export var carry_distance: float = 2.0
## The maximum distance away from the raycast origin before the object is dropped
@export var max_carry_distance: float = 2.0
## The force of throwing the carried body
@export var throw_force: float = 250.0
## The Close Carry body position Node
@export var carry_position_node: Node3D
## Carry collision layer
@export_flags_3d_physics var carry_collision_layer: int = 1
## Carry collision mask
@export_flags_3d_physics var carry_collision_mask: int = 1


# RigidBody3D or null being carried
var carried_body: RigidBody3D
var carried_body_width: float = 0.0
var last_collider: Node3D
var last_focussed_collider: Node3D
var carried_body_prev_mask: int = 1
var carried_body_prev_layer: int = 1
var carried_body_physics_material: PhysicsMaterial
var character: CharacterBody3D
	
func _ready():
	character = Nodot.get_first_parent_of_type(self, CharacterBody3D)
	InputManager.register_action(interact_action, KEY_F)

func _physics_process(delta: float):
	if !is_multiplayer_authority(): return
	
	var is_action_pressed: bool = character.input_states.get("mouse_action") or false
	character.input_states["interact"] = get_input()
	if character.input_states["interact"]:
		action()
	
	if is_instance_valid(carried_body):
		var point = get_collision_point()
		var carry_position = global_transform.origin - global_transform.basis.z.normalized() * (carry_distance + carried_body_width)
		var current_carry_distance = carried_body.global_position.distance_to(global_position)
		if current_carry_distance > carry_distance + max_carry_distance:
			carry_end()
			return
		if is_action_pressed:
			throw()
			return
		var speed = carried_body.global_position.distance_to(carry_position) * 600
		carried_body.linear_velocity = carried_body.global_transform.origin.direction_to(carry_position) * speed * delta
		
		var rotate_speed: float = 10.0 * delta
		carried_body.global_rotation.x = lerp_angle(carried_body.global_rotation.x, 0.0, rotate_speed)
		carried_body.global_rotation.z = lerp_angle(carried_body.global_rotation.z, 0.0, rotate_speed)
		carried_body.global_rotation.y = lerp_angle(carried_body.global_rotation.y, global_rotation.y, rotate_speed)
	
		var collider = get_collider()
		if is_instance_valid(collider):
			if is_instance_valid(last_focussed_collider) and collider != last_focussed_collider:
				if last_focussed_collider.has_method("unfocussed"):
					last_focussed_collider.unfocussed()
			if collider.has_method("focussed"):
				last_focussed_collider = collider
				collider.focussed()
		else:
			if is_instance_valid(last_focussed_collider) and last_focussed_collider.has_method("unfocussed"):
				last_focussed_collider.unfocussed()
	else:		
		var collider = get_collider()
		if is_instance_valid(last_collider) and last_collider != collider:
			collide_ended(last_collider)
		last_collider = collider

		if is_instance_valid(collider):
			if collider.has_method("label"):
				emit_signal("interaction_label_updated", collider.label())
			else:
				emit_signal("interaction_label_updated", "")

			if collider.has_method("focussed"):
				collider.focussed()
				if collider is RigidBody3D and collider.mass <= max_mass:
					emit_signal("interaction_label_updated", "Carry")
		else:
			emit_signal("interaction_label_updated", "")

func action():
	if !enabled or !is_multiplayer_authority(): return
	if character.input_states.get("mouse_action"): return
	
	var collider = get_collider()
	if collider and collider.has_meta("NonPickable") and collider.get_meta("NonPickable"): return
	if !is_instance_valid(collider):
		if is_instance_valid(carried_body):
			carry_end()
		return

	emit_signal("interacted", collider, get_collision_point(), get_collision_normal())
	if collider.has_method("interact"):
		collider.interact()
		GlobalSignal.trigger_signal("interacted", [collider, get_collision_point(), get_collision_normal()])
	else:
		if is_instance_valid(carried_body):
			carry_end()
		else:
			carry_begin(collider)

func get_input():
	return Input.is_action_just_pressed(interact_action)

func carry_begin(collider: Node):
	emit_signal("interaction_label_updated", "")
	if enable_pickup and is_instance_valid(collider) and collider is RigidBody3D and collider.mass <= max_mass:
		carried_body = collider
		var carried_body_mesh: MeshInstance3D = Nodot.get_first_child_of_type(carried_body, MeshInstance3D)
		if carried_body_mesh:
			var mesh_size = carried_body_mesh.get_aabb().size
			carried_body_width = max(mesh_size.x * carried_body_mesh.scale.x, mesh_size.y * carried_body_mesh.scale.y, mesh_size.z * carried_body_mesh.scale.z)
		carried_body_prev_layer = carried_body.collision_layer
		carried_body_prev_mask = carried_body.collision_mask
		carried_body_physics_material = carried_body.physics_material_override
		carried_body.physics_material_override = null
		carried_body.collision_layer = carry_collision_layer
		carried_body.collision_mask = carry_collision_mask
		emit_signal("carry_started", carried_body)
		GlobalSignal.trigger_signal("carry_started", carried_body)


func carry_end():
	if is_instance_valid(carried_body):
		carried_body.angular_velocity = Vector3.ZERO
		carried_body.collision_layer = carried_body_prev_layer
		carried_body.collision_mask = carried_body_prev_mask
		carried_body.physics_material_override = carried_body_physics_material
		emit_signal("carry_ended", carried_body)
		GlobalSignal.trigger_signal("carry_ended", carried_body)
		carried_body = null

func _carry_body_end():
	carried_body.collision_layer = carried_body_prev_layer
	carried_body.collision_mask = carried_body_prev_mask
	carried_body.physics_material_override = carried_body_physics_material
	emit_signal("carry_ended", carried_body)
	GlobalSignal.trigger_signal("carry_ended", carried_body)
	carried_body = null

func throw():
	if is_instance_valid(carried_body):
		carried_body.angular_velocity = Vector3.ZERO
		carried_body.apply_force(-global_transform.basis.z * throw_force)
		carry_end()

func collide_ended(body: Node3D):
	emit_signal("interaction_label_updated", "")
	if body.has_method("unfocussed"):
		body.unfocussed()
