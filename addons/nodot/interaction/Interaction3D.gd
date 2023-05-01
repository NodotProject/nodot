@tool
## A raycast for interacting with, picking up, carrying and re-orienting objects
class_name Interaction3D extends RayCast3D

## Triggered when starting to carry an object
signal carry_started(carried_node: Node3D)
## Triggered when dropping an object that was being carried
signal carry_ended(carried_node: Node3D)
## Triggered when the interact function on an object was fired
signal interacted(interacted_node: Node3D)

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

# RigidBody3D or null being carried
var carried_body
var label3d: Label3D
var last_collider: Node3D


func _enter_tree():
	label3d = Label3D.new()
	label3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label3d.fixed_size = true
	label3d.no_depth_test = true
	label3d.font_size = font_size
	label3d.modulate = font_color
	label3d.position.z = -2
	add_child(label3d)


func _input(event: InputEvent):
	if event.is_action_pressed(interact_action):
		if is_instance_valid(carried_body):
			carried_body.gravity_scale = 1.0
			emit_signal("carry_ended", carried_body)
			carried_body = null
		else:
			var collider = get_collider()
			if is_instance_valid(collider) and collider.has_method("interact"):
				collider.interact()
				emit_signal("interacted", collider)
			elif enable_pickup and collider is RigidBody3D and collider.mass <= max_mass:
				carried_body = collider
				carried_body.gravity_scale = 0.0
				emit_signal("carry_started", carried_body)


func _physics_process(delta):
	if is_instance_valid(carried_body):
		var carry_position = global_transform.origin
		carry_position -= global_transform.basis.z.normalized() * carry_distance
		carried_body.global_transform.origin = lerp(
			carried_body.global_transform.origin, carry_position, 10.0 * delta
		)
		carried_body.rotation = lerp(carried_body.rotation, Vector3.ZERO, 10.0 * delta)
	else:
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


func collide_ended(body: Node3D):
	label3d.text = ""
	if body.has_method("unfocussed"):
		body.unfocussed()
