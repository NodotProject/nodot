## A wrapper around [AnimationTree] to add a more intuitive API.
class_name NodotAnimationTree extends AnimationTree

var _param_cache: Dictionary = {}
var _property_cache: Dictionary = {}

func _ready() -> void:
	_scan_parameters()

## Scans the [AnimationTree]'s properties and populates the parameter cache.
## This is called automatically in _ready(), but can be called again if parameters are changed at runtime.
func _scan_parameters() -> void:
	_param_cache.clear()
	_property_cache.clear()
	for p in get_property_list():
		var param_name: String = p.get("name", "")
		_property_cache[param_name] = true
		if param_name.begins_with("parameters/"):
			var sub = param_name.substr(11)
			if not sub.is_empty():
				_param_cache[sub] = param_name
	
	if has_meta("parameters/playback"):
		_param_cache["playback"] = "parameters/playback"

## Returns a list of all the friendly parameter names found in the [AnimationTree].
func list_params() -> Array:
	return _param_cache.keys()

## Returns true if a parameter with the given friendly name exists.
func has_param(friendly_name: String) -> bool:
	return _param_cache.has(friendly_name)

## Converts a friendly parameter name (e.g., "MyNode/some_param") to its full path.
func get_param_path(friendly_name: String) -> String:
	if friendly_name.begins_with("parameters/"):
		return friendly_name
	if _param_cache.has(friendly_name):
		return _param_cache[friendly_name]
	push_warning("AnimationTreeWrapper.get_param_path: unknown parameter '%s'." % friendly_name)
	return ""

## Sets the value of a parameter using its friendly name.
func set_param(param_name: String, value) -> bool:
	var path = get_param_path(param_name)
	if path.is_empty():
		if param_name.begins_with("parameters/"):
			path = param_name
		else:
			push_error("set_param: cannot resolve parameter '%s'." % param_name)
			return false
	
	if not _has_property(path):
		push_warning("set_param: property '%s' not found in AnimationTree property_list; attempting set anyway." % path)
	
	set(path, value)
	return true

## Gets the value of a parameter using its friendly name.
func get_param(param_name: String):
	var path = get_param_path(param_name)
	if path.is_empty():
		if param_name.begins_with("parameters/"):
			path = param_name
		else:
			return null
	return get(path) if _has_property(path) else null

## Gets a node from within the blend tree.
func get_blend_tree_node(friendly_name: String) -> AnimationNode:
	return tree_root.get_node(friendly_name)

func _has_property(path: String) -> bool:
	return _property_cache.has(path)

## Gets the [AnimationNodeStateMachinePlayback] object from the tree.
func get_state_machine_playback(node_name: String = "") -> AnimationNodeStateMachinePlayback:
	if node_name == "":
		var path = get_param_path("playback")
		if path.is_empty():
			push_warning("get_state_machine_playback: playback not found on AnimationTree.")
			return null
		return get(path)
	else:
		return get(get_param_path(node_name + "/playback"))

## Travels to a new state in the root [AnimationNodeStateMachine].
func travel_state(state_name: String) -> bool:
	var playback = get_state_machine_playback()
	if not playback:
		push_error("travel_state: playback object unavailable.")
		return false
	playback.travel(state_name)
	return true

## Gets the name of the current state in the root [AnimationNodeStateMachine].
func get_current_state() -> String:
	var playback = get_state_machine_playback()
	if not playback:
		return ""
	return String(playback.get_current_node())
	var cs = get_param("StateMachine.current_state")
	if cs:
		return String(cs)
	return ""

## Fires a one-shot animation.
## @param friendly_name The path to the [AnimationNodeOneShot] node.
func fire_oneshot(friendly_name: String) -> bool:
	var param_name = friendly_name + "/request"
	return set_param(param_name, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

## Aborts a one-shot animation.
## @param friendly_name The path to the [AnimationNodeOneShot] node.
func abort_oneshot(friendly_name: String) -> bool:
	var param_name = friendly_name + "/request"
	return set_param(param_name, AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)

## Sets a one_shot fadeout and fadein time.
## @param friendly_name The path to the [AnimationNodeOneShot] node.
func set_oneshot_fadetimes(friendly_name: String, fade_in_time: float = 0.0, fade_out_time: float = 0.0):
	var node: AnimationNodeOneShot = get_blend_tree_node(friendly_name)
	node.fadein_time = fade_in_time
	node.fadeout_time = fade_out_time

## Returns true if a one-shot animation is currently active.
## @param friendly_name The path to the [AnimationNodeOneShot] node.
func is_oneshot_active(friendly_name: String) -> bool:
	var param_name = friendly_name + "/active"
	return bool(get_param(param_name))

## Seeks to a specific time in an animation.
## @param node_name The path to the [Animation] node.
func request_timeseek(node_name: String, seconds: float) -> bool:
	var param_name = node_name + "/seek_request"
	return set_param(param_name, seconds)

## Sets the time scale (speed) of an animation.
## @param node_name The path to the [Animation] node.
func set_timescale(node_name: String, scale: float) -> bool:
	var param_name = node_name + "/scale"
	return set_param(param_name, scale)

## Gets the time scale (speed) of an animation.
## @param node_name The path to the [Animation] node.
func get_timescale(node_name: String) -> float:
	var param_name = node_name + "/scale"
	return get_param(param_name)

func _get_node_parameter_path(node_name: String, parameter_name: String) -> String:
	var full_parameter_name = node_name + "/" + parameter_name
	if _param_cache.has(full_parameter_name):
		return _param_cache[full_parameter_name]

	var parameter_path = "parameters/" + node_name + "/" + parameter_name
	if _has_property(parameter_path):
		_param_cache[full_parameter_name] = parameter_path
		return parameter_path

	push_warning("_get_node_parameter_path: parameter not found for node '%s', parameter '%s'." % [node_name, parameter_name])
	return ""

## Sets the blend amount for a [Blend2], [Blend3], or [BlendSpace1D] node.
func set_blend_amount(node_name: String, value: float) -> bool:
	var blend_amount_path = _get_node_parameter_path(node_name, "blend_amount")
	if not blend_amount_path.is_empty():
		set(blend_amount_path, value)
		return true

	var blend_position_path = _get_node_parameter_path(node_name, "blend_position")
	if not blend_position_path.is_empty():
		set(blend_position_path, value)
		return true

	var position_path = _get_node_parameter_path(node_name, "position")
	if not position_path.is_empty():
		set(position_path, value)
		return true

	push_warning("set_blend_amount: failed to set blend value for '%s'." % node_name)
	return false

## Sets the blend position for a [BlendSpace2D] node.
func set_blend_position(node_name: String, value: Vector2 = Vector2.ZERO) -> bool:
	var position_path = _get_node_parameter_path(node_name, "blend_position")

	if not position_path.is_empty():
		set(position_path, value)
		return true

	push_warning("set_blend_position: failed to set blend_position for '%s'." % node_name)
	return false


## Linearly interpolates the blend amount for a [Blend2], [Blend3], or [BlendSpace1D] node.
func lerp_blend_amount(node_name: String, to_value: float, weight: float) -> bool:
	var current_value = get_param(_get_node_parameter_path(node_name, "blend_amount"))
	if current_value == null:
		current_value = get_param(_get_node_parameter_path(node_name, "blend_position"))
	if current_value == null:
		current_value = get_param(_get_node_parameter_path(node_name, "position"))
	
	if current_value != null:
		var new_value = lerp(current_value, to_value, weight)
		return set_blend_amount(node_name, new_value)
	
	push_warning("lerp_blend_amount: failed to get current blend value for '%s'." % node_name)
	return false

## Linearly interpolates the blend position for a [BlendSpace2D] node.
func lerp_blend_position(node_name: String, to_value: Vector2, weight: float) -> bool:
	var current_value = get_param(_get_node_parameter_path(node_name, "blend_position"))
	if current_value != null:
		var new_value = current_value.lerp(to_value, weight)
		var position_path = _get_node_parameter_path(node_name, "blend_position")
		if not position_path.is_empty():
			set(position_path, new_value)
			return true
		return false
		
	push_warning("lerp_blend_position: failed to get current blend_position for '%s'." % node_name)
	return false


## Gets the blend amount for a [Blend2], [Blend3], or [BlendSpace1D] node.
func get_blend_amount(node_name: String) -> float:
	var value = get_param(_get_node_parameter_path(node_name, "blend_amount"))
	if value != null:
		return value

	value = get_param(_get_node_parameter_path(node_name, "blend_position"))
	if value != null:
		return value

	value = get_param(_get_node_parameter_path(node_name, "position"))
	if value != null:
		return value
	
	push_warning("get_blend_amount: failed to get blend value for '%s'." % node_name)
	return 0.0

## Gets the blend position for a [BlendSpace2D] node.
func get_blend_position(node_name: String) -> Vector2:
	var value = get_param(_get_node_parameter_path(node_name, "blend_position"))
	if value != null:
		return value
	
	push_warning("get_blend_position: failed to get position for '%s'." % node_name)
	return Vector2.ZERO

## Requests a transition in the root [AnimationNodeTransition].
func request_transition(node_name: String, transition_name: String) -> bool:
	return set_param("%s/transition_request" % node_name, transition_name)
