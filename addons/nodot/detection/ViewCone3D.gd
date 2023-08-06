## A SpotLight3D that detects nodes that enter it's vision
class_name ViewCone3D extends SpotLight3D

@export var enabled: bool = true
@export var detection_group: String = "detectable"
@export_flags_3d_physics var collision_layer: int = 0

signal body_detected(body: Node3D)
signal body_lost(body: Node3D)

var detected = false
var last_detected_body: Node3D

func _physics_process(_delta):
	if !enabled:
		return
	
	var detected_this_pass = false
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
				detected_this_pass = true
				if !detected:
					detected = true
					if body.has_method("detected"):
						body.detected()
					last_detected_body = body
					emit_signal("body_detected", body)
	
	if detected_this_pass == false and detected == true:
		detected = false
		emit_signal("body_lost", last_detected_body)
