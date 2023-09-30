## A SpotLight3D that detects nodes that enter it's vision
class_name ViewCone3D extends SpotLight3D

@export var enabled: bool = true
@export var detection_group: String = "detectable"
@export_flags_3d_physics var collision_layer: int = 0

signal body_detected(body: Node3D)
signal body_lost(body: Node3D)

var detected_bodies: Array[Node] = []

func _physics_process(_delta):
	if !enabled:
		return
	
	var detected_bodies_this_pass: Array[Node] = []
	var cam_pos = global_transform.origin
	var max_distance_squared = pow(spot_range, 2)
	var max_angle = deg_to_rad(spot_angle)
	
	for body in get_tree().get_nodes_in_group(detection_group):
		var space_state = get_world_3d().direct_space_state
		var body_pos = body.global_transform.origin
		if cam_pos.distance_squared_to(body_pos) > max_distance_squared:
			continue

		var cam_facing = -global_transform.basis.z
		var cam_to_body =  cam_pos.direction_to(body_pos)
		var cam_to_body_norm = cam_to_body.normalized()
		var cos_angle = cam_to_body_norm.dot(cam_facing)
		var angle = acos(cos_angle)

		if angle < max_angle:
			var params = PhysicsRayQueryParameters3D.new()
			
			if collision_layer != 0:
				params.collision_mask = collision_layer
			params.from = cam_pos
			params.to = body_pos

			var result = space_state.intersect_ray(params)
			if result and result.collider == body:
				detected_bodies_this_pass.append(body)
				if !detected_bodies.has(body):
					detected_bodies.append(body)
					if body.has_method("detected"):
						body.detected(self)
					emit_signal("body_detected", body)
	
	if detected_bodies_this_pass.size() > 0:
		var removed_bodies: Array[Node] = []
		for detected_body in detected_bodies:
			if !detected_bodies_this_pass.has(detected_body):
				removed_bodies.append(detected_body)
				
		for removed_body in removed_bodies:
			if removed_body.has_method("undetected"):
				removed_body.undetected(self)
			emit_signal("body_lost", removed_body)
			var i = detected_bodies.find(removed_body)
			detected_bodies.remove_at(i)
