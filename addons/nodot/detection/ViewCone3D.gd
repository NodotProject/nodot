@tool
## A SpotLight3D that detects nodes that enter it's vision
class_name ViewCone3D extends SpotLight3D

@export var enabled: bool = true
@export var detection_group: String = "detectable"
@export var detection_color: Color = Color.RED

var original_color = light_color

func _physics_process(_delta):
	var cam_pos = global_transform.origin
	var max_distance_squared = pow(spot_range, 2)
	var max_angle = deg_to_rad(spot_angle)
	light_color = original_color
	
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

			params.from = global_transform.origin
			params.to = body.global_transform.origin

			params.collide_with_bodies = true
			params.collide_with_areas = false

			var result = space_state.intersect_ray(params)
			if result and result.collider == body:
				light_color = detection_color
				if body.has_method("detected"):
					body.detected()
		
